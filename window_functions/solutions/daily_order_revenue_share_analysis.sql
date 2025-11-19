-- =====================================================
-- Задача: Анализ доли заказов в ежедневной выручке
-- Тема: Многоуровневые подзапросы с оконными функциями

-- Цель: Рассчитать стоимость каждого заказа, ежедневную выручку сервиса 
--        и долю стоимости заказа в ежедневной выручке

-- Условия:
-- • Исключить отмененные заказы из расчета
-- • Рассчитать стоимость заказа как сумму цен всех товаров в заказе
-- • Рассчитать ежедневную выручку как сумму всех заказов за день
-- • Вычислить долю заказа в ежедневной выручке в процентах
-- • Округлить доли до трех знаков после запятой
-- =====================================================
SELECT 
  order_id, 
  creation_time, 
  order_price, 
  SUM(order_price) OVER(
    PARTITION BY DATE(creation_time)
  ) AS daily_revenue, 
  ROUND(
    (
      order_price * 100.0 / SUM(order_price) OVER(
        PARTITION BY DATE(creation_time)
      )
    ), 
    3
  ) AS percentage_of_daily_revenue 
FROM 
  (
    SELECT 
      order_id, 
      creation_time, 
      SUM(price) AS order_price 
    FROM 
      (
        SELECT 
          orders.order_id, 
          orders.creation_time, 
          products.price 
        FROM 
          orders CROSS 
          JOIN UNNEST(product_ids) AS product_id 
          LEFT JOIN products USING(product_id) 
        WHERE 
          orders.order_id NOT IN (
            SELECT 
              order_id 
            FROM 
              user_actions 
            WHERE 
              action = 'cancel_order'
          )
      ) AS order_products 
    GROUP BY 
      order_id, 
      creation_time
  ) AS order_totals 
ORDER BY 
  DATE(creation_time) DESC, 
  percentage_of_daily_revenue DESC, 
  order_id

-- Логика решения:
-- 1. ВНУТРЕННИЙ ПОДЗАПРОС (order_products): Подготовка данных
--    • CROSS JOIN UNNEST(product_ids) - разворачивание массивов товаров в отдельные строки
--    • LEFT JOIN products - присоединение информации о ценах товаров
--    • Фильтрация отмененных заказов через подзапрос NOT IN
--    • Результат: каждая строка представляет товар в заказе с его ценой
--
-- 2. СРЕДНИЙ ПОДЗАПРОС (order_totals): Расчет стоимости заказов
--    • GROUP BY order_id, creation_time - группировка по заказам
--    • SUM(price) - вычисление общей стоимости каждого заказа
--    • Результат: уникальные заказы с их общей стоимостью
--
-- 3. ВНЕШНИЙ ЗАПРОС: Расчет ежедневной выручки и долей
--    • SUM(order_price) OVER(PARTITION BY DATE(creation_time)) - ежедневная выручка
--    • ROUND((order_price * 100.0 / daily_revenue), 3) - доля заказа в выручке дня
--    • ORDER BY - финальная сортировка по дате, доле и ID заказа

-- Пример результата:
-- order_id | creation_time       | order_price | daily_revenue | percentage_of_daily_revenue
-- 5001     | 2023-09-15 10:30:00 | 2450.50     | 125800.75     | 1.948
-- 5002     | 2023-09-15 11:15:00 | 1890.25     | 125800.75     | 1.503
-- 5003     | 2023-09-15 14:20:00 | 3200.00     | 125800.75     | 2.544
-- 5004     | 2023-09-14 09:45:00 | 1560.75     | 98750.25      | 1.581