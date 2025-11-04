-- =====================================================
-- Задача: Анализ парадоксальных заказов - отмененных пользователями, но доставленных курьерами
-- Тема: Условная агрегация с FILTER и сложные подзапросы

-- Цель: Исследовать противоречия в статусах заказов между действиями пользователей и курьеров
-- =====================================================

SELECT 
  COUNT(order_id) FILTER(
    WHERE 
      order_id NOT IN(
        SELECT 
          order_id 
        FROM 
          courier_actions 
        WHERE 
          action = 'deliver_order'
      )
  ) AS orders_canceled, 
  COUNT(order_id) FILTER(
    WHERE 
      order_id IN(
        SELECT 
          order_id 
        FROM 
          courier_actions 
        WHERE 
          action = 'deliver_order'
      )
  ) AS orders_canceled_and_delivered 
FROM 
  user_actions 
WHERE 
  action = 'cancel_order'
