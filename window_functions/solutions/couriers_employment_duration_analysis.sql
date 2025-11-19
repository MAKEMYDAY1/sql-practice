-- =====================================================
-- Задача: Анализ продолжительности работы курьеров и их эффективности
-- Тема: Оконные функции с FILTER для условной агрегации

-- Цель: Выявить курьеров, работающих более 10 дней, и проанализировать их производительность
--        на основе количества доставленных заказов за весь период работы

-- Условия:
-- • Рассчитать продолжительность работы каждого курьера от первого действия до последнего действия в системе
-- • Учесть только целые дни работы (без учета часов и минут)
-- • Подсчитать количество успешно доставленных заказов за весь период
-- • Отфильтровать курьеров с продолжительностью работы ≥ 10 дней
-- =====================================================
SELECT 
  DISTINCT courier_id, 
  days_employed, 
  delivered_orders 
FROM 
  (
    SELECT 
      courier_id, 
      DATE_PART(
        'day', 
        MAX(time) OVER() - MIN(time) OVER(PARTITION BY courier_id)
      ):: INTEGER AS days_employed, 
      COUNT(order_id) FILTER (
        WHERE 
          action = 'deliver_order'
      ) OVER(PARTITION BY courier_id) AS delivered_orders 
    FROM 
      courier_actions
  ) AS t1 
WHERE 
  days_employed >= 10 
ORDER BY 
  days_employed DESC, 
  courier_id
