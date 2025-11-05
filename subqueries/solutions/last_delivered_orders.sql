-- =====================================================
-- Задача: Анализ 100 последних доставленных заказов по времени доставки
-- Тема: Временные метки vs идентификаторы в подзапросах

-- Цель: Получить содержимое 100 самых последних по времени доставки заказов
-- =====================================================
SELECT 
  order_id, 
  product_ids 
FROM 
  orders 
WHERE 
  order_id IN(
    SELECT 
      order_id 
    FROM 
      courier_actions 
    WHERE 
      action = 'deliver_order' 
    ORDER BY 
      time DESC 
    LIMIT 
      100
  ) 
ORDER BY 
  order_id
