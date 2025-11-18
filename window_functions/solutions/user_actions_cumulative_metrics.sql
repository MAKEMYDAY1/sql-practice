-- =====================================================
-- Задача: Накопительные метрики пользовательских действий в реальном времени
-- Тема: Оконные функции с CASE для динамического подсчета показателей

-- Цель: Рассчитать накопительные суммы созданных и отмененных заказов для каждого пользователя
--        в каждый момент времени, а также динамический показатель отмен

-- Условия:
-- • Для каждого действия пользователя посчитать накопительные суммы
-- • Отслеживать количество созданных и отмененных заказов на момент каждого действия
-- • Рассчитать динамическую долю отмененных заказов (cancel_rate)
-- • Сохранить все исходные строки без фильтрации
-- =====================================================
SELECT 
  user_id, 
  order_id, 
  action, 
  time, 
  SUM(
    CASE WHEN action = 'create_order' THEN 1 ELSE 0 END
  ) OVER (
    PARTITION BY user_id 
    ORDER BY 
      time ROWS BETWEEN UNBOUNDED PRECEDING 
      AND CURRENT ROW
  ) AS created_orders, 
  SUM(
    CASE WHEN action = 'cancel_order' THEN 1 ELSE 0 END
  ) OVER (
    PARTITION BY user_id 
    ORDER BY 
      time ROWS BETWEEN UNBOUNDED PRECEDING 
      AND CURRENT ROW
  ) AS canceled_orders, 
  ROUND(
    (
      (
        SUM(
          CASE WHEN action = 'cancel_order' THEN 1 ELSE 0 END
        ) OVER (
          PARTITION BY user_id 
          ORDER BY 
            time ROWS BETWEEN UNBOUNDED PRECEDING 
            AND CURRENT ROW
        )
      )
    ):: DECIMAL / (
      SUM(
        CASE WHEN action = 'create_order' THEN 1 ELSE 0 END
      ) OVER (
        PARTITION BY user_id 
        ORDER BY 
          time ROWS BETWEEN UNBOUNDED PRECEDING 
          AND CURRENT ROW
      )
    ), 
    2
  ) AS cancel_rate 
FROM 
  user_actions 
ORDER BY 
  user_id, 
  order_id, 
  time 
LIMIT 
  1000

-- Логика решения:
-- 1. НАКОПИТЕЛЬНАЯ СУММА СОЗДАННЫХ ЗАКАЗОВ:
--    • CASE WHEN action = 'create_order' THEN 1 ELSE 0 END - преобразуем действие в числовой показатель
--    • SUM() OVER (PARTITION BY user_id ORDER BY time) - накопительная сумма по пользователю
--    • ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW - от начала до текущей строки
--
-- 2. НАКОПИТЕЛЬНАЯ СУММА ОТМЕНЕННЫХ ЗАКАЗОВ:
--    • Аналогичная логика для действий отмены заказов
--    • Каждое действие cancel_order увеличивает счетчик на 1
--
-- 3. РАСЧЕТ ДОЛИ ОТМЕНЕННЫХ ЗАКАЗОВ:
--    • canceled_orders / created_orders - деление отмененных на созданные
--    • ::DECIMAL - преобразование для дробного деления
--    • NULLIF(created_orders, 0) - защита от деления на ноль
--    • ROUND(..., 2) - округление до двух знаков

-- Пример результата:
-- user_id | order_id | action       | time               | created_orders | canceled_orders | cancel_rate
-- 1001    | 5001     | create_order | 2023-09-01 10:00   | 1              | 0               | 0.00
-- 1001    | 5001     | cancel_order | 2023-09-01 10:05   | 1              | 1               | 1.00
-- 1001    | 5002     | create_order | 2023-09-01 11:00   | 2              | 1               | 0.50
-- 1001    | 5003     | create_order | 2023-09-01 12:00   | 3              | 1               | 0.33