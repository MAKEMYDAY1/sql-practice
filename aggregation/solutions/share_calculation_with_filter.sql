-- =====================================================
-- Задача: Анализ доли крупных заказов
-- Тема: Агрегация данных в SQL
-- Цель: Рассчитать общее количество заказов, количество крупных заказов и их долю

-- Используемые техники:
-- FILTER с агрегатными функциями
-- Преобразование типов для точного деления
-- Множественная агрегация в одном запросе
-- =====================================================

SELECT 
  COUNT(order_id) AS orders, 
  COUNT(order_id) FILTER (
    WHERE 
      ARRAY_LENGTH(product_ids, 1) >= 5
  ) AS large_orders, 
  ROUND(
    COUNT(order_id) FILTER (
      WHERE 
        ARRAY_LENGTH(product_ids, 1) >= 5
    ) / COUNT(order_id):: DECIMAL, 
    2
  ) AS large_orders_share 
FROM 
  orders

-- Логика решения:
-- 1. COUNT(order_id) - общее количество всех заказов
-- 2. COUNT(order_id) FILTER (WHERE ARRAY_LENGTH(product_ids, 1) >= 5) - количество заказов с 5+ товарами
-- 3. large_orders_share = large_orders / orders
--    • ::DECIMAL гарантирует decimal деление
--    • ROUND(..., 2) округляет до двух знаков после запятой

-- Пример результата:
-- orders | large_orders | large_orders_share
-- 59595  | 11498        | 0.19