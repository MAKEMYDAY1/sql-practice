-- =====================================================
-- Задача: Расчет общей стоимости заказов
-- Тема: Агрегация с SUM после UNNEST и LEFT JOIN

-- Цель: Определить суммарную стоимость каждого заказа на основе цен товаров

-- Используемые операторы:
-- UNNEST - преобразование массивов товаров в отдельные строки
-- LEFT JOIN - объединение с ценами товаров
-- SUM - агрегация для подсчёта общей стоимости
-- GROUP BY - группировка по заказам
-- =====================================================
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
ORDER BY 
  o.order_id 
LIMIT 
  1000
