-- =====================================================
-- Задача: Анализ первых и повторных заказов по дням
-- Тема: Оконные функции для определения последовательности событий

-- Цель: Разделить заказы на первые и повторные для каждого пользователя
--        и проанализировать их распределение по дням

-- Условия:
-- • Определить первый заказ для каждого пользователя
-- • Разделить все заказы на "Первый" и "Повторный"
-- • Посчитать количество заказов каждого типа по дням
-- • Исключить отмененные заказы из анализа
-- =====================================================
SELECT 
  DATE(time) AS date, 
  order_type, 
  COUNT(order_id) AS orders_count 
FROM 
  (
    SELECT 
      user_id, 
      order_id, 
      time, 
      CASE WHEN time = MIN(time) OVER (PARTITION BY user_id) THEN 'Первый' ELSE 'Повторный' END AS order_type 
    FROM 
      user_actions 
    WHERE 
      action = 'create_order' 
      AND order_id NOT IN (
        SELECT 
          order_id 
        FROM 
          user_actions 
        WHERE 
          action = 'cancel_order'
      )
  ) AS t1 
GROUP BY 
  DATE(time), 
  order_type 
ORDER BY 
  date, 
  order_type
