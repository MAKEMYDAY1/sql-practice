-- =====================================================
-- Задача: Анализ эффективности курьеров относительно среднего показателя
-- Тема: Оконные функции для расчета агрегатов по всей таблице

-- Цель: Выявить курьеров, которые доставили больше заказов, чем в среднем по всем курьерам
--        за сентябрь 2022 года

-- Условия:
-- • Рассчитать количество доставленных заказов для каждого курьера
-- • Вычислить среднее количество заказов по всем курьерам
-- • Сравнить индивидуальные показатели со средним значением
-- • Отметить курьеров с показателями выше среднего
-- =====================================================
SELECT 
  courier_id, 
  delivered_orders, 
  avg_delivered_orders, 
  CASE WHEN avg_delivered_orders < delivered_orders THEN 1 ELSE 0 END AS is_above_avg 
FROM 
  (
    SELECT 
      courier_id, 
      COUNT(order_id) AS delivered_orders, 
      ROUND(
        AVG(
          COUNT(order_id)
        ) OVER(), 
        2
      ) AS avg_delivered_orders 
    FROM 
      courier_actions 
    WHERE 
      action = 'deliver_order' 
      AND time BETWEEN '2022-09-01' 
      AND '2022-10-01' 
    GROUP BY 
      courier_id 
    ORDER BY 
      courier_id
  ) AS t1
