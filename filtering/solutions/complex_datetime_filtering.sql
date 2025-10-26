-- =====================================================
-- Задача: Анализ отмен заказов по конкретному расписанию
-- Тема: Фильтрация данных в SQL
-- Цель: Найти отмены заказов в августе 2022 по средам с 12:00 до 15:59

-- Используемые функции:
-- DATE_PART - извлечение компонентов даты и времени
-- BETWEEN - фильтрация по диапазону часов
-- =====================================================

SELECT 
  user_id, 
  order_id, 
  action, 
  time 
FROM 
  user_actions 
WHERE 
  action = 'cancel_order' 
  AND DATE_PART('year', time) = 2022 
  AND DATE_PART('month', time) = 8 
  AND DATE_PART('dow', time) = 3 
  AND DATE_PART('hour', time) BETWEEN 12 
  AND 15 
ORDER BY 
  order_id DESC

-- Логика решения:
-- 1. action = 'cancel_order' - фильтрация только отмененных заказов
-- 2. DATE_PART('year', time) = 2022 - август 2022 года
-- 3. DATE_PART('month', time) = 8 - август (8-й месяц)
-- 4. DATE_PART('dow', time) = 3 - среда (0=воскресенье, 1=понедельник, ..., 6=суббота)
-- 5. DATE_PART('hour', time) BETWEEN 12 AND 15 - период с 12:00 до 15:59

-- Пример результата:
-- user_id | order_id | action      | time
-- 230     | 10457    | cancel_order| 2022-08-10 14:30:15
-- 200     | 10456    | cancel_order| 2022-08-17 13:45:22
-- 170     | 10455    | cancel_order| 2022-08-24 15:15:08