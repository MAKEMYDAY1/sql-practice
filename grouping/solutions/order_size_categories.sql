-- =====================================================
-- Задача: Сегментация заказов по размеру на категории
-- Тема: Группировка данных в SQL
-- Цель: Разделить заказы на три категории по размеру и посчитать количество заказов в каждой

-- Используемые операторы:
-- CASE WHEN - создание пользовательских категорий
-- GROUP BY с вычисляемым полем - группировка по категориям
-- COUNT() - подсчет заказов в каждой категории
-- ORDER BY - сортировка результатов
-- =====================================================

SELECT 
  CASE WHEN ARRAY_LENGTH(product_ids, 1) BETWEEN 1 
  AND 3 THEN 'Малый' WHEN ARRAY_LENGTH(product_ids, 1) BETWEEN 4 
  AND 6 THEN 'Средний' ELSE 'Большой' END AS order_size, 
  COUNT(order_id) AS orders_count 
FROM 
  orders 
GROUP BY 
  order_size 
ORDER BY 
  COUNT(order_id)
