-- =====================================================
-- Задача: Выявление топовых курьеров по доставкам за сентябрь 2022 года
-- Тема: Агрегация с GROUP BY и HAVING в подзапросах

-- Цель: Определить наиболее продуктивных курьеров, доставивших 30+ заказов за сентябрь 2022
-- =====================================================
SELECT 
  courier_id, 
  birth_date, 
  sex 
FROM 
  couriers 
WHERE 
  courier_id IN(
    SELECT 
      courier_id 
    FROM 
      courier_actions 
    WHERE 
      action = 'deliver_order' 
      AND time BETWEEN '2022-09-01' 
      AND '2022-10-01' 
    GROUP BY 
      courier_id 
    HAVING 
      COUNT(order_id) >= 30
  ) 
ORDER BY 
  courier_id
