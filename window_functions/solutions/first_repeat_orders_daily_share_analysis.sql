-- =====================================================
-- Задача: Анализ долей первых и повторных заказов по дням
-- Тема: Многоуровневые оконные функции и вложенные подзапросы

-- Цель: Рассчитать доли первых и повторных заказов от общего количества заказов за каждый день
--        для анализа динамики привлечения и удержания пользователей

-- Условия:
-- • Определить первые и повторные заказы для каждого пользователя
-- • Посчитать количество заказов каждого типа по дням
-- • Рассчитать долю каждого типа заказов от общего количества за день
-- • Исключить отмененные заказы из анализа
-- =====================================================
SELECT 
  date, 
  order_type, 
  orders_count, 
  ROUND(
    orders_count * 1.0 / SUM(orders_count) OVER (PARTITION BY date), 
    2
  ) AS orders_share 
FROM 
  (
    SELECT 
      DATE(time) AS date, 
      order_type, 
      COUNT(order_id) AS orders_count 
    FROM 
      (
        SELECT 
          user_id, 
          order_id, 
          time, 
          CASE WHEN time = MIN(time) OVER (PARTITION BY user_id) THEN 'Первый' ELSE 'Повторный' END AS order_type 
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
      ) AS orders_with_types 
    GROUP BY 
      DATE(time), 
      order_type
  ) AS daily_counts 
ORDER BY 
  date, 
  order_type

-- Логика решения:
-- 1. ВНУТРЕННИЙ ПОДЗАПРОС (orders_with_types): Определение типа заказа
--    • MIN(time) OVER (PARTITION BY user_id) - нахождение времени первого заказа пользователя
--    • CASE WHEN time = MIN(time) - определение типа заказа через сравнение
--    • Фильтрация неотмененных заказов через подзапрос NOT IN
--
-- 2. СРЕДНИЙ ПОДЗАПРОС (daily_counts): Агрегация по дням и типам
--    • GROUP BY DATE(time), order_type - группировка по дате и типу заказа
--    • COUNT(order_id) - подсчет количества заказов в каждой группе
--    • DATE(time) - извлечение даты из временной метки
--
-- 3. ВНЕШНИЙ ЗАПРОС: Расчет долей с оконной функцией
--    • SUM(orders_count) OVER (PARTITION BY date) - сумма заказов за день
--    • orders_count * 1.0 / SUM(...) - расчет доли каждого типа
--    • ROUND(..., 2) - округление до двух знаков после запятой
--    • ORDER BY date, order_type - финальная сортировка

-- Пример результата:
-- date       | order_type | orders_count | orders_share
-- 2023-09-01 | Первый     | 156          | 0.64
-- 2023-09-01 | Повторный  | 89           | 0.36
-- 2023-09-02 | Первый     | 142          | 0.44
-- 2023-09-02 | Повторный  | 184          | 0.56