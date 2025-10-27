-- =====================================================
-- Задача: Расчет метрик пользовательской активности
-- Тема: Агрегация данных в SQL
-- Цель: Рассчитать базовые метрики пользовательской активности и заказов

-- Используемые функции:
-- COUNT(DISTINCT) - подсчет уникальных значений
-- ::DECIMAL - преобразование типов для корректного деления
-- ROUND() - округление результата
-- =====================================================

SELECT 
  COUNT(DISTINCT user_id) AS unique_users, 
  COUNT(DISTINCT order_id) AS unique_orders, 
  ROUND(
    COUNT(DISTINCT order_id):: DECIMAL / COUNT(DISTINCT user_id), 
    2
  ) AS orders_per_user 
FROM 
  user_actions

-- Логика решения:
-- 1. COUNT(DISTINCT user_id) - количество уникальных пользователей
-- 2. COUNT(DISTINCT order_id) - количество уникальных заказов
-- 3. orders_per_user = unique_orders / unique_users
--    • ::DECIMAL гарантирует decimal деление (вместо integer division)
--    • ROUND(..., 2) округляет до двух знаков после запятой

-- Пример результата:
-- unique_users | unique_orders | orders_per_user
-- 21401        | 59595         | 2.78