-- =====================================================
-- Задача: Анализ уникальных неотменённых заказов с составом товаров
-- Тема: LEFT JOIN с фильтрацией через подзапрос

-- Цель: Выявить успешные заказы пользователей с детальной информацией о товарах

-- Используемые операторы:
-- LEFT JOIN с USING - объединение по общему ключу
-- Подзапрос с NOT IN - исключение отменённых заказов
-- ORDER BY - многоуровневая сортировка
-- LIMIT - ограничение вывода для производительности
-- =====================================================
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
ORDER BY 
  user_id, 
  order_id 
LIMIT 
  1000
