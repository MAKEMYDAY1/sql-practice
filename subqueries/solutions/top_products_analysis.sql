-- =====================================================
-- Задача: Анализ 10 самых популярных товаров с учётом повторных покупок в заказах
-- Тема: Комбинирование UNNEST с двухуровневой сортировкой

-- Цель: Выявить топ-10 товаров по популярности с учётом всех вхождений в заказах
-- =====================================================
SELECT 
  * 
FROM 
  (
    SELECT 
      UNNEST(product_ids) AS product_id, 
      COUNT(*) AS times_purchased 
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
      product_id 
    ORDER BY 
      times_purchased DESC 
    LIMIT 
      10
  ) AS popular_products 
ORDER BY 
  product_id;
