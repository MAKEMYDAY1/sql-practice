-- =====================================================
-- Задача: Анализ скользящего среднего заказов по дням
-- Тема: Оконные функции с явным указанием границ рамки

-- Цель: Рассчитать скользящее среднее число заказов за 3 предыдущих дня
--        для анализа трендов и сглаживания ежедневных колебаний

-- Условия:
-- • Исключить отмененные заказы из подсчета
-- • Рассчитать скользящее среднее по 3 предыдущим дням
-- • Текущий день не учитывать в расчете
-- • Округлить результат до двух знаков после запятой
-- • Сохранить NULL значения для дней без достаточной истории
-- =====================================================
SELECT 
  date, 
  orders_count, 
  ROUND(
    AVG(orders_count) OVER (
      ORDER BY 
        date ROWS BETWEEN 3 PRECEDING 
        AND 1 PRECEDING
    ), 
    2
  ) AS moving_avg 
FROM 
  (
    SELECT 
      date(creation_time) as date, 
      count(order_id) as orders_count 
    FROM 
      orders 
    WHERE 
      order_id not in (
        SELECT 
          order_id 
        FROM 
          user_actions 
        WHERE 
          action = 'cancel_order'
      ) 
    GROUP BY 
      date
  ) AS t
