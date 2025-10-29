-- =====================================================
-- Задача: Комплексный анализ размеров заказов по будням
-- Тема: Группировка данных в SQL
-- Цель: Выявить наиболее популярные размеры заказов, оформленных в будни, с фильтрацией по минимальному количеству

-- Используемые операторы:
-- WHERE с DATE_PART - фильтрация по дням недели
-- GROUP BY с ARRAY_LENGTH - группировка по размеру заказа
-- HAVING с COUNT - фильтрация групп по количеству заказов
-- ORDER BY - сортировка результатов
-- =====================================================

SELECT 
  ARRAY_LENGTH(product_ids, 1) AS order_size, 
  COUNT(order_id) AS orders_count 
FROM 
  orders 
WHERE 
  DATE_PART('dow', creation_time) BETWEEN 1 
  AND 5 
GROUP BY 
  ARRAY_LENGTH(product_ids, 1) 
HAVING 
  COUNT(order_id) > 2000 
ORDER BY 
  ARRAY_LENGTH(product_ids, 1)

-- Логика решения:
-- 1. WHERE DATE_PART('dow', creation_time) BETWEEN 1 AND 5
--    • DATE_PART('dow', creation_time) возвращает день недели (0-воскресенье, 1-понедельник, ..., 6-суббота)
--    • BETWEEN 1 AND 5 фильтрует только будние дни (понедельник-пятница)
-- 2. GROUP BY ARRAY_LENGTH(product_ids, 1)
--    • ARRAY_LENGTH(product_ids, 1) вычисляет количество товаров в заказе
--    • Группирует заказы по размеру (1 товар, 2 товара, 3 товара и т.д.)
-- 3. HAVING COUNT(order_id) > 2000
--    • COUNT(order_id) подсчитывает заказы в каждой группе
--    • HAVING фильтрует группы: оставляет только те, где больше 2000 заказов
-- 4. ORDER BY ARRAY_LENGTH(product_ids, 1)
--    • Сортирует результат по размеру заказа (от меньшего к большему)

-- Пример результата:
-- order_size | orders_count
-- 1          | 2326	
-- 2          | 8296	
-- 3          | 12544
-- 4          | 10639	
-- 5          | 5654