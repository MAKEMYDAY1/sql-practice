-- =====================================================
-- Задача: Топ-10 популярных товаров за сентябрь 2022
-- Тема: Многоуровневая агрегация с DISTINCT и оконными функциями

-- Цель: Определить 10 самых популярных товаров среди доставленных заказов
--        за сентябрь 2022 года

-- Условия:
-- • Учитывать только доставленные заказы
-- • Если товар встречается в заказе несколько раз - считать один раз
-- • Вывести наименования товаров и количество уникальных заказов
-- =====================================================
SELECT 
  name, 
  COUNT(product_id) as times_purchased 
FROM 
  (
    SELECT 
      order_id, 
      product_id, 
      name 
    FROM 
      (
        SELECT 
          DISTINCT order_id, 
          unnest(product_ids) as product_id 
        FROM 
          orders 
          LEFT JOIN courier_actions USING (order_id) 
        WHERE 
          action = 'deliver_order' 
          and date_part('month', time) = 9 
          and date_part('year', time) = 2022
      ) t1 
      LEFT JOIN products USING (product_id)
  ) t2 
GROUP BY 
  name 
ORDER BY 
  times_purchased DESC 
LIMIT 
  10
