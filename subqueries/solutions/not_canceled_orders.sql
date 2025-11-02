-- =====================================================
-- Задача: Фильтрация неотмененных заказов
-- Тема: Подзапросы с NOT IN для исключения данных

-- Цель: Вывести идентификаторы заказов, которые были созданы, но не отменены пользователями
-- =====================================================

SELECT 
  order_id 
FROM 
  user_actions 
WHERE 
  action = 'create_order' 
  AND order_id NOT IN (
    SELECT 
      DISTINCT order_id 
    FROM 
      user_actions 
    WHERE 
      action = 'cancel_order'
  ) 
LIMIT 
  1000