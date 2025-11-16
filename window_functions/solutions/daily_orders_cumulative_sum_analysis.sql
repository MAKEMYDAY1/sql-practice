-- =====================================================
-- Задача: Анализ накопительной суммы заказов по дням
-- Тема: Оконные функции с агрегацией и накопительными итогами

-- Цель: Рассчитать ежедневное количество заказов и их накопительную сумму
--        для анализа динамики продаж и общего прогресса

-- Условия:
-- • Исключить отмененные заказы из подсчета
-- • Группировать заказы по дням
-- • Применить накопительную сумму с оконной функцией
-- • Привести результат к целочисленному формату
-- =====================================================
SELECT 
  date, 
  orders_count, 
  (
    SUM(orders_count) OVER (
      ORDER BY 
        date
    )
  ):: INTEGER AS orders_count_cumulative 
FROM 
  (
    SELECT 
      COUNT(order_id) AS orders_count, 
      DATE(creation_time) AS date 
    FROM 
      orders 
    WHERE 
      order_id NOT IN (
        SELECT 
          order_id 
        FROM 
          user_actions 
        WHERE 
          action = 'cancel_order'
      ) 
    GROUP BY 
      DATE(creation_time)
  ) AS t1
