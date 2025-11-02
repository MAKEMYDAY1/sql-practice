-- Задача: Анализ отклонений количества заказов пользователей от среднего значения
-- Тема: Многократные подзапросы в SELECT
-- Цель: Проанализировать поведение пользователей через сравнение индивидуальных показателей со средними по платформе
-- =====================================================

SELECT 
  user_id, 
  COUNT(order_id) AS orders_count, 
  (
    SELECT 
      ROUND(
        AVG(orders_count), 
        2
      ) 
    FROM 
      (
        SELECT 
          COUNT(order_id) AS orders_count 
        FROM 
          user_actions 
        WHERE 
          action = 'create_order' 
        GROUP BY 
          user_id
      ) AS sub1
  ) AS orders_avg, 
  COUNT(order_id) - (
    SELECT 
      ROUND(
        AVG(orders_count), 
        2
      ) 
    FROM 
      (
        SELECT 
          COUNT(order_id) AS orders_count 
        FROM 
          user_actions 
        WHERE 
          action = 'create_order' 
        GROUP BY 
          user_id
      ) AS sub2
  ) AS orders_diff 
FROM 
  user_actions 
WHERE 
  action = 'create_order' 
GROUP BY 
  user_id 
ORDER BY 
  user_id 
LIMIT 
  1000;

-- Логика решения:
-- 1. ОСНОВНОЙ ЗАПРОС: Расчет количества заказов для каждого пользователя
--    • GROUP BY user_id - группировка по пользователям
--    • COUNT(order_id) - подсчет заказов для каждого пользователя
--    • WHERE action = 'create_order' - только созданные заказы (исключаем отмены)
--
-- 2. ПОДЗАПРОС ДЛЯ СРЕДНЕГО ЗНАЧЕНИЯ (используется дважды):
--    • Внутренний подзапрос: подсчет заказов для каждого пользователя
--    • Внешний подзапрос: вычисление среднего арифметического
--    • ROUND(..., 2) - округление до двух знаков после запятой
--
-- 3. РАСЧЕТ ОТКЛОНЕНИЯ: orders_count - orders_avg
--    • Показывает насколько пользователь отклоняется от среднего
--    • Положительное значение = выше среднего
--    • Отрицательное значение = ниже среднего

-- Пример результата:
-- user_id | orders_count | orders_avg | orders_diff
-- 1       | 3            | 2.78       | 0.22
-- 2       | 5            | 2.78       | 2.22
-- 3       | 1            | 2.78       | -1.78
-- 4       | 2            | 2.78       | -0.78