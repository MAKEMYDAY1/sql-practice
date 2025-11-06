-- =====================================================
-- Задача: Анализ времени доставки крупных заказов с оптимизацией производительности
-- Тема: CTE для оптимизации сложных запросов с временными вычислениями

-- Цель: Рассчитать метрики времени доставки для крупных заказов (5+ товаров) с максимальной производительностью
-- =====================================================
WITH delivery_data AS (
  SELECT 
    order_id, 
    time AS delivery_time 
  FROM 
    courier_actions 
  WHERE 
    action = 'deliver_order'
) 
SELECT 
  o.order_id, 
  o.creation_time AS time_accepted, 
  dd.delivery_time AS time_delivered, 
  (
    EXTRACT(
      epoch 
      FROM 
        (
          dd.delivery_time - o.creation_time
        )
    ) / 60
  ):: INTEGER AS delivery_time 
FROM 
  orders o, 
  delivery_data dd 
WHERE 
  o.order_id = dd.order_id 
  AND ARRAY_LENGTH(o.product_ids, 1) > 5 
  AND o.order_id NOT IN (
    SELECT 
      order_id 
    FROM 
      user_actions 
    WHERE 
      action = 'cancel_order'
  ) 
ORDER BY 
  order_id

-- Логика решения:
-- 1. CTE delivery_data: Предварительная агрегация данных о доставках
--    • Фильтрация только доставленных заказов (action = 'deliver_order')
--    • Выборка order_id и времени доставки
--    • Результат: оптимизированная таблица с временами доставки
--
-- 2. ОСНОВНОЙ ЗАПРОС: Расчет метрик доставки
--    • Неявное соединение: FROM orders o, delivery_data dd + WHERE o.order_id = dd.order_id
--    • time_accepted: время создания заказа из orders
--    • time_delivered: время доставки из CTE
--    • delivery_time: разница в минутах (epoch секунды / 60) с приведением к INTEGER
--
-- 3. ФИЛЬТРАЦИЯ:
--    • ARRAY_LENGTH(product_ids, 1) > 5 - только крупные заказы (5+ товаров)
--    • NOT IN с подзапросом - исключение отмененных заказов
--    • ORDER BY order_id - сортировка для удобства анализа

-- Пример результата:
-- order_id | time_accepted        | time_delivered       | delivery_time
-- 1001     | 2022-09-01 10:30:00 | 2022-09-01 11:15:00  | 45
-- 1002     | 2022-09-01 14:20:00 | 2022-09-01 15:05:00  | 45
-- 1003     | 2022-09-02 09:15:00 | 2022-09-02 10:30:00  | 75
