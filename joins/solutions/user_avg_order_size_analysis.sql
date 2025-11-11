-- =====================================================
-- Задача: Анализ среднего размера заказов по пользователям
-- Тема: Агрегация после JOIN с фильтрацией данных

-- Цель: Определить среднее количество товаров в заказах для каждого пользователя

-- Используемые операторы:
-- Подзапрос с JOIN и фильтрацией - подготовка данных для агрегации
-- AVG с ARRAY_LENGTH - расчёт среднего размера заказов
-- ROUND - округление числовых значений
-- GROUP BY - группировка по пользователям
-- =====================================================
SELECT 
  user_id, 
  ROUND(
    AVG(
      ARRAY_LENGTH(product_ids, 1)
    ), 
    2
  ) AS avg_order_size 
FROM 
  (
    SELECT 
      user_id, 
      order_id, 
      product_ids 
    FROM 
      user_actions 
      LEFT JOIN orders USING (order_id) 
    WHERE 
      order_id NOT IN(
        SELECT 
          order_id 
        FROM 
          user_actions 
        WHERE 
          action = 'cancel_order'
      )
  ) AS t 
GROUP BY 
  user_id 
ORDER BY 
  user_id 
LIMIT 
  1000
