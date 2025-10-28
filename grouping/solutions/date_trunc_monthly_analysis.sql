-- =====================================================
-- Задача: Анализ месячной динамики заказов
-- Тема: Группировка данных в SQL
-- Цель: Проанализировать количество заказов по месяцам

-- Используемые функции:
-- DATE_TRUNC() - приведение дат к началу периода
-- COUNT() - подсчет количества заказов
-- GROUP BY - группировка по временным периодам
-- =====================================================

SELECT 
  DATE_TRUNC('month', creation_time) AS month, 
  COUNT(order_id) AS orders_count 
FROM 
  orders 
GROUP BY 
  DATE_TRUNC('month', creation_time) 
ORDER BY 
  DATE_TRUNC('month', creation_time)
