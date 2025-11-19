-- =====================================================
-- Задача: Расчет медианной стоимости заказов
-- Тема: Оконные функции для вычисления статистических показателей

-- Цель: Рассчитать медианную стоимость всех заказов без использования встроенных квантилей
--        с ручной обработкой сценариев для четного и нечетного количества заказов

-- Условия:
-- • Исключить отмененные заказы из расчета
-- • Реализовать алгоритм медианы для обоих сценариев (четное/нечетное количество)
-- • Не использовать встроенные функции для квантилей
-- • Вернуть одно значение - медианную стоимость
-- =====================================================
WITH order_prices AS (
  SELECT 
    orders.order_id, 
    SUM(products.price) AS order_price 
  FROM 
    orders CROSS 
    JOIN UNNEST(orders.product_ids) AS product_id_value 
    LEFT JOIN products ON products.product_id = product_id_value 
  WHERE 
    orders.order_id NOT IN (
      SELECT 
        order_id 
      FROM 
        user_actions 
      WHERE 
        action = 'cancel_order'
    ) 
  GROUP BY 
    orders.order_id
), 
numbered_prices AS (
  SELECT 
    order_price, 
    ROW_NUMBER() OVER (
      ORDER BY 
        order_price
    ) AS row_num, 
    COUNT(*) OVER() AS total_count 
  FROM 
    order_prices
) 
SELECT 
  ROUND(
    CASE WHEN total_count % 2 = 1 THEN (
      SELECT 
        order_price 
      FROM 
        numbered_prices 
      WHERE 
        row_num = (total_count + 1) / 2
    ) ELSE (
      SELECT 
        AVG(order_price) 
      FROM 
        numbered_prices 
      WHERE 
        row_num IN (total_count / 2, total_count / 2 + 1)
    ) END, 
    2
  ) AS median_price 
FROM 
  numbered_prices 
LIMIT 
  1
-- Логика решения:
-- 1. CTE order_prices: Подготовка данных о стоимости заказов
--    • UNNEST(product_ids) + LEFT JOIN products - разворачивание товаров и получение цен
--    • Фильтрация отмененных заказов через подзапрос NOT IN
--    • GROUP BY order_id + SUM(price) - расчет общей стоимости каждого заказа
--    • Результат: таблица order_id → order_price
--
-- 2. CTE numbered_prices: Подготовка к расчету медианы
--    • ROW_NUMBER() OVER (ORDER BY order_price) - нумерация заказов по возрастанию стоимости
--    • COUNT(*) OVER() - общее количество заказов (нужно для определения четности)
--    • Результат: order_price, row_num (порядковый номер), total_count (общее количество)
--
-- 3. Финальный SELECT: Вычисление медианы через подзапросы
--    • total_count % 2 = 1 - проверка на нечетность количества заказов
--    • Нечетный случай: подзапрос выбирает заказ на позиции (total_count + 1) / 2
--    • Четный случай: подзапрос вычисляет среднее заказов на позициях total_count/2 и total_count/2 + 1
--    • ROUND(..., 2) - округление до двух знаков для денежного формата
--    • LIMIT 1 - гарантия одного результата (все строки numbered_prices идентичны по total_count)

-- Пример результата:
-- median_price
-- 1420.50