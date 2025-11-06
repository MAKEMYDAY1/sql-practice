-- =====================================================
-- Задача: Идентификация заказов, содержащих премиальные товары
-- Тема: Многоуровневые CTE с UNNEST для анализа состава заказов

-- Цель: Найти все заказы, которые включают хотя бы один из пяти самых дорогих товаров сервиса
-- =====================================================

WITH expensive_products AS (
  SELECT 
    product_id 
  FROM 
    products 
  ORDER BY 
    price DESC 
  LIMIT 
    5
), orders_unnested AS (
  SELECT 
    order_id, 
    product_ids, 
    UNNEST(product_ids) AS single_product_id 
  FROM 
    orders
) 
SELECT 
  DISTINCT order_id, 
  product_ids 
FROM 
  orders_unnested 
WHERE 
  single_product_id IN (
    SELECT 
      product_id 
    FROM 
      expensive_products
  ) 
ORDER BY 
  order_id

-- Логика решения:
-- 1. CTE expensive_products: Определение premium-ассортимента
--    • ORDER BY price DESC - сортировка товаров по убыванию цены
--    • LIMIT 5 - выбор пяти самых дорогих позиций
--    • Результат: таблица с product_id топ-5 самых дорогих товаров
--
-- 2. CTE orders_unnested: Денормализация заказов для анализа
--    • UNNEST(product_ids) - преобразование массивов в отдельные строки
--    • Сохранение order_id и product_ids для последующего восстановления
--    • Результат: развёрнутая таблица "заказ-товар" для поштучного анализа
--
-- 3. ОСНОВНОЙ ЗАПРОС: Фильтрация и дедупликация результатов
--    • WHERE single_product_id IN (...) - проверка принадлежности к premium-ассортименту
--    • DISTINCT - устранение дубликатов заказов (если несколько premium товаров в одном заказе)
--    • ORDER BY order_id - упорядочивание для удобства анализа

-- Пример работы:
-- expensive_products: [101, 205, 308, 412, 525] (ID самых дорогих товаров)
-- orders_unnested fragment:
-- order_id | product_ids       | single_product_id
-- 1001     | [101, 15, 22]     | 101  ✓ (попадает в результат)
-- 1001     | [101, 15, 22]     | 15   ✗
-- 1001     | [101, 15, 22]     | 22   ✗
-- 1002     | [45, 67, 89]      | 45   ✗
-- 1003     | [205, 308, 50]    | 205  ✓ (попадает в результат)
-- 1003     | [205, 308, 50]    | 308  ✓ (попадает в результат)
-- 1003     | [205, 308, 50]    | 50   ✗
--
-- Результат (после DISTINCT):
-- order_id | product_ids
-- 1001     | [101, 15, 22]
-- 1003     | [205, 308, 50]