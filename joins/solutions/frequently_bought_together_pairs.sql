-- =====================================================
-- Задача: Анализ часто покупаемых вместе пар товаров
-- Тема: SELF JOIN для генерации комбинаций и анализ ассоциативных правил

-- Цель: Выявить пары товаров, которые чаще всего покупаются вместе в одном заказе
--        и отсортировать их по частоте совместного появления

-- Условия:
-- • Учитывать только неотмененные заказы
-- • Пары товаров представлять в виде отсортированных массивов
-- • Исключать дублирующиеся пары (A-B и B-A считаются одной парой)
-- • Сортировать по убыванию частоты и возрастанию названий пар
-- =====================================================
WITH order_products AS (
  SELECT 
    DISTINCT order_id, 
    UNNEST(product_ids) AS product_id 
  FROM 
    orders 
  WHERE 
    order_id NOT IN (
      SELECT 
        order_id 
      FROM 
        user_actions 
      WHERE 
        action = 'cancel_order'
    )
), 
product_names AS (
  SELECT 
    op.order_id, 
    p.name 
  FROM 
    order_products op 
    JOIN products p ON op.product_id = p.product_id
), 
product_combinations AS (
  SELECT 
    pn1.order_id, 
    LEAST(pn1.name, pn2.name) AS product1, 
    GREATEST(pn1.name, pn2.name) AS product2 
  FROM 
    product_names pn1 
    JOIN product_names pn2 ON pn1.order_id = pn2.order_id 
    AND pn1.name < pn2.name
) 
SELECT 
  ARRAY[product1, 
  product2] AS pair, 
  COUNT(*) AS count_pair 
FROM 
  product_combinations 
GROUP BY 
  product1, 
  product2 
ORDER BY 
  count_pair DESC, 
  pair ASC

-- Логика решения:
-- 1. CTE order_products: Подготовка и очистка данных
--    • UNNEST(product_ids) - денормализация массивов товаров в отдельные строки
--    • Фильтрация отмененных заказов через подзапрос NOT IN
--    • Результат: таблица связи "заказ-товар" в реляционном формате
--
-- 2. CTE product_pairs: Генерация уникальных пар товаров
--    • SELF JOIN order_products - соединение таблицы самой с собой
--    • Условие op1.order_id = op2.order_id - товары из одного заказа
--    • Условие op1.product_id < op2.product_id - исключение дублей (A-B vs B-A)
--    • LEAST/GREATEST - гарантия консистентного порядка товаров в паре
--    • JOIN products дважды - получение наименований для обоих товаров
--
-- 3. ФИНАЛЬНЫЙ ЗАПРОС: Агрегация и ранжирование пар
--    • ARRAY[product1, product2] - формирование пары как отсортированного массива
--    • COUNT(*) - подсчет частоты встречаемости каждой уникальной пары
--    • GROUP BY product1, product2 - агрегация на уровне уникальных пар
--    • ORDER BY count_pair DESC, pair ASC - сортировка по популярности и алфавиту

-- Пример результата:
-- pair               | count_pair
-- {Молоко,Хлеб}      | 156
-- {Сахар,Чай}        | 142
-- {Кофе,Печенье}     | 128
-- {Масло,Хлеб}       | 115
-- {Сыр,Хлеб}         | 103