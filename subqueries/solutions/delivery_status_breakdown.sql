-- =====================================================
-- Задача: Детальный анализ статусов недоставленных заказов
-- Тема: Эффективные подзапросы с математическими операциями
-- Курс: SQL для аналитики данных
-- Дата: 2024-01-15
-- Автор: [Твое имя]
-- =====================================================

-- Цель: Разбить недоставленные заказы на отмененные и находящиеся в процессе доставки
-- Бизнес-контекст: Мониторинг pipeline доставки, анализ причин недоставки, оптимизация логистических процессов
SELECT 
  COUNT(DISTINCT order_id) AS orders_undelivered, 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'cancel_order'
  ) AS orders_canceled, 
  COUNT(DISTINCT order_id) - COUNT(order_id) FILTER (
    WHERE 
      action = 'cancel_order'
  ) AS orders_in_process 
FROM 
  user_actions 
WHERE 
  order_id IN (
    SELECT 
      order_id 
    FROM 
      courier_actions 
    WHERE 
      order_id NOT IN (
        SELECT 
          order_id 
        FROM 
          courier_actions 
        WHERE 
          action = 'deliver_order'
      )
  )
