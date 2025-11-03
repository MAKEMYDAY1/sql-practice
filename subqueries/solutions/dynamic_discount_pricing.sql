-- =====================================================
-- Задача: Динамическое назначение скидок на основе отклонения от средней цены
-- Тема: Условная логика с CASE и подзапросами

-- Цель: Реализовать гибкую систему скидок в зависимости от позиционирования товара относительно средней цены
-- =====================================================

WITH avg_price AS (
  SELECT 
    ROUND(
      AVG(price), 
      2
    ) AS average_price 
  FROM 
    products
) 
SELECT 
  product_id, 
  name, 
  price, 
  CASE WHEN price >= (
    SELECT 
      average_price 
    FROM 
      avg_price
  ) + 50 THEN price * 0.85 WHEN price <= (
    SELECT 
      average_price 
    FROM 
      avg_price
  ) -50 THEN price * 0.90 ELSE price END AS new_price 
FROM 
  products 
ORDER BY 
  price DESC, 
  product_id
