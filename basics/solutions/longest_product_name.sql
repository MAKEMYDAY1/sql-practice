-- =====================================================
-- Задача: Товар с самым длинным названием
-- Цель: Найти товар с максимальной длиной названия
-- Используемые операторы: SELECT, FROM, ORDER BY, LIMIT, LENGTH()
-- =====================================================

SELECT 
    name,
    LENGTH(name) AS name_length,
    price
FROM products
ORDER BY name_length DESC 
LIMIT 1;
