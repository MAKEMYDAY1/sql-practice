-- =====================================================
-- Задача: Анализ среднего размера заказов, отмененных пользователями мужского пола
-- Тема: Многоуровневые подзапросы с соединением таблиц

-- Цель: Исследовать поведенческие паттерны мужской аудитории через анализ отмененных заказов
-- =====================================================
SELECT 
  ROUND(
    AVG(
      ARRAY_LENGTH(product_ids, 1)
    ), 
    3
  ) AS avg_order_size 
FROM 
  orders 
WHERE 
  order_id IN (
    SELECT 
      order_id 
    FROM 
      user_actions 
    WHERE 
      action = 'cancel_order' 
      AND user_id IN(
        SELECT 
          user_id 
        FROM 
          users 
        WHERE 
          sex = 'male'
      )
  )
