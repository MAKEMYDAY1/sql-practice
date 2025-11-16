-- =====================================================
-- Задача: Анализ временных интервалов между заказами пользователей
-- Тема: Функции смещения LAG и временные вычисления с AGE()

-- Цель: Рассчитать время между последовательными заказами пользователей
--        для анализа паттернов покупок и пользовательского поведения

-- Условия:
-- • Нумеровать заказы каждого пользователя в хронологическом порядке
-- • Рассчитать время между текущим и предыдущим заказом
-- • Учесть особенности первых заказов (NULL значения)
-- • Исключить отмененные заказы из анализа
-- =====================================================
SELECT 
  user_id, 
  order_id, 
  time, 
  order_number, 
  time_lag, 
  time_diff 
FROM 
  (
    SELECT 
      user_id, 
      order_id, 
      time, 
      ROW_NUMBER() OVER(
        PARTITION BY user_id 
        ORDER BY 
          time
      ) AS order_number, 
      LAG(time, 1) OVER (
        PARTITION BY user_id 
        ORDER BY 
          time
      ) AS time_lag, 
      AGE(
        time, 
        LAG(time, 1) OVER (
          PARTITION BY user_id 
          ORDER BY 
            time
        )
      ) AS time_diff 
    FROM 
      user_actions 
    WHERE 
      order_id NOT IN (
        SELECT 
          order_id 
        FROM 
          user_actions 
        WHERE 
          action = 'cancel_order'
      )
  ) AS t1 
ORDER BY 
  user_id, 
  order_number 
LIMIT 
  1000
