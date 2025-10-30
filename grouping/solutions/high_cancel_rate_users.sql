-- =====================================================
-- Задача: Анализ пользователей с высокой долей отмен заказов
-- Тема: Фильтрация с HAVING и агрегатные функции
-- Цель: Выявить пользователей с высокой частотой отмен заказов для дальнейшего анализа

-- Используемые операторы:
-- COUNT() FILTER (WHERE) - условный подсчет с фильтрацией
-- ROUND() - округление числовых значений
-- GROUP BY - группировка по пользователям
-- HAVING - фильтрация групп по агрегатным условиям
-- ::DECIMAL - преобразование типов для точных расчетов
-- =====================================================

SELECT 
  user_id, 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'create_order'
  ) AS orders_count, 
  ROUND(
    COUNT(order_id) FILTER (
      WHERE 
        action = 'cancel_order'
    ):: DECIMAL / COUNT(order_id) FILTER (
      WHERE 
        action = 'create_order'
    ), 
    2
  ) AS cancel_rate 
FROM 
  user_actions 
GROUP BY 
  user_id 
HAVING 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'create_order'
  ) > 3 
  AND COUNT(order_id) FILTER (
    WHERE 
      action = 'cancel_order'
  ):: DECIMAL / COUNT(order_id) FILTER (
    WHERE 
      action = 'create_order'
  ) >= 0.5 
ORDER BY 
  user_id

-- Логика решения:
-- 1. COUNT(order_id) FILTER (WHERE action = 'create_order') - подсчитывает только созданные заказы
--    • Игнорирует отмененные и другие действия
--    • Дает точное количество оформленных заказов
-- 2. COUNT(order_id) FILTER (WHERE action = 'cancel_order') - подсчитывает только отмененные заказы
--    • Учитывает только действия по отмене
-- 3. cancel_rate = отмененные_заказы / созданные_заказы
--    • ::DECIMAL обеспечивает точное деление (вместо целочисленного)
--    • ROUND(..., 2) округляет до двух знаков для читаемости
-- 4. HAVING применяет два условия фильтрации:
--    • orders_count > 3 - только пользователи с более чем 3 заказами
--    • cancel_rate >= 0.5 - доля отмен не менее 50%
-- 5. ORDER BY user_id - сортировка по возрастанию ID пользователя

-- Пример результата:
-- user_id | orders_count | cancel_rate
-- 123     | 5            | 0.60
-- 456     | 7            | 0.57
-- 789     | 4            | 0.75
