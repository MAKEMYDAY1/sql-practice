-- =====================================================
-- Задача: Анализ первых заказов пользователей по дням
-- Тема: Понимание разницы между созданными и неотменёнными заказами

-- Цель: Отслеживать динамику привлечения новых пользователей через анализ их первых неотменённых заказов
-- =====================================================
WITH first_orders AS (
  SELECT 
    user_id, 
    MIN(time):: DATE AS first_order_date 
  FROM 
    user_actions 
  WHERE 
    action = 'create_order' 
    AND order_id NOT IN (
      SELECT 
        order_id 
      FROM 
        user_actions 
      WHERE 
        action = 'cancel_order'
    ) 
  GROUP BY 
    user_id
) 
SELECT 
  first_order_date AS date, 
  COUNT(user_id) AS first_orders 
FROM 
  first_orders 
GROUP BY 
  first_order_date 
ORDER BY 
  first_order_date

-- Логика решения:
-- 1. CTE first_orders: Определение даты первого неотменённого заказа для каждого пользователя
--    • MIN(time) с GROUP BY user_id - нахождение самой ранней даты заказа для каждого пользователя
--    • action = 'create_order' - учитываем только созданные заказы
--    • NOT IN с подзапросом - исключаем заказы, которые были отменены
--    • ::DATE - преобразование к типу даты для группировки по дням
--    • Результат: для каждого user_id его дата первого успешного заказа
--
-- 2. ОСНОВНОЙ ЗАПРОС: Агрегация первых заказов по датам
--    • GROUP BY first_order_date - группировка по дате первого заказа
--    • COUNT(user_id) - подсчёт количества уникальных пользователей
--    • ORDER BY first_order_date - хронологический порядок для анализа тренда

-- Пример результата:
-- date       | first_orders
-- 2022-08-24 | 127
-- 2022-08-25 | 143
-- 2022-08-26 | 158
-- 2022-08-27 | 172