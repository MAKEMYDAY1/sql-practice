-- =====================================================
-- Задача: Анализ недовезенных заказов - созданных пользователями, но не доставленных курьерами
-- Тема: Поиск разрывов в бизнес-процессе доставки с NOT IN

-- Цель: Выявить заказы, которые застряли в процессе доставки - созданы, но не доставлены
-- =====================================================
SELECT 
  COUNT(DISTINCT order_id) AS orders_count 
FROM 
  user_actions 
WHERE 
  action = 'create_order' 
  AND order_id NOT IN (
    SELECT 
      order_id 
    FROM 
      courier_actions 
    WHERE 
      action = 'deliver_order'
  )
