-- =====================================================
-- Задача: Комплексный анализ заказов пользователей
-- Тема: Многоуровневая агрегация с CTE и JOIN

-- Цель: Рассчитать ключевые метрики пользователей на основе их заказов
--        - количество заказов, средний размер, стоимость и экстремумы

-- Используемые операторы:
-- CTE (WITH) - создание временных таблиц для сложных расчетов
-- LEFT JOIN - объединение таблиц пользователей, заказов и цен
-- UNNEST - преобразование массивов товаров в отдельные строки
-- Агрегатные функции: COUNT, AVG, SUM, MIN, MAX
-- GROUP BY - группировка по пользователям
-- =====================================================
WITH order_details AS (
  SELECT 
    ua.user_id, 
    ua.order_id, 
    array_length(o.product_ids, 1) as order_size, 
    po.order_price 
  FROM 
    user_actions ua 
    LEFT JOIN orders o ON ua.order_id = o.order_id 
    LEFT JOIN (
      SELECT 
        o.order_id, 
        SUM(p.price) AS order_price 
      FROM 
        (
          SELECT 
            order_id, 
            UNNEST(product_ids) AS product_id 
          FROM 
            orders
        ) AS o 
        LEFT JOIN products AS p ON o.product_id = p.product_id 
      GROUP BY 
        o.order_id
    ) AS po ON ua.order_id = po.order_id 
  WHERE 
    ua.order_id NOT IN (
      SELECT 
        order_id 
      FROM 
        user_actions 
      WHERE 
        action = 'cancel_order'
    )
) 
SELECT 
  user_id, 
  COUNT(order_id) AS orders_count, 
  ROUND(
    AVG(order_size), 
    2
  ) AS avg_order_size, 
  SUM(order_price) AS sum_order_value, 
  ROUND(
    AVG(order_price), 
    2
  ) AS avg_order_value, 
  MIN(order_price) AS min_order_value, 
  MAX(order_price) AS max_order_value 
FROM 
  order_details 
GROUP BY 
  user_id 
ORDER BY 
  user_id 
LIMIT 
  1000

-- Логика решения:
-- 1. CTE order_details: Подготовка детализированных данных
--    • Объединение user_actions, orders и расчет стоимости заказов
--    • Фильтрация неотмененных заказов через подзапрос
--    • Расчет размера заказа через array_length(product_ids, 1)
--    • LEFT JOIN гарантирует сохранение всех неотмененных заказов
--
-- 2. ПОДЗАПРОС В CTE: Расчет стоимости заказов
--    • UNNEST(product_ids) - денормализация массивов товаров
--    • LEFT JOIN products - добавление цен товаров
--    • SUM(p.price) - агрегация стоимости по заказам
--    • GROUP BY o.order_id - группировка на уровне заказов
--
-- 3. ОСНОВНОЙ ЗАПРОС: Агрегация по пользователям
--    • COUNT(order_id) - подсчет количества успешных заказов
--    • AVG(order_size) - среднее количество товаров в заказе
--    • SUM(order_price) - общая стоимость всех покупок
--    • AVG(order_price) - средняя стоимость заказа
--    • MIN/MAX(order_price) - экстремальные значения стоимости
--
-- 4. ФИЛЬТРАЦИЯ: Только неотмененные заказы
--    • WHERE order_id NOT IN (canceled_orders) - исключение отмен
--    • Обеспечивает корректность бизнес-метрик

-- Пример результата:
-- user_id | orders_count | avg_order_size | sum_order_value | avg_order_value | min_order_value | max_order_value
-- 1001    | 3            | 2.33           | 657.50          | 219.17          | 149.00          | 278.80
-- 1002    | 2            | 1.50           | 378.90          | 189.45          | 150.00          | 228.90
-- 1003    | 1            | 3.00           | 429.70          | 429.70          | 429.70          | 429.70
