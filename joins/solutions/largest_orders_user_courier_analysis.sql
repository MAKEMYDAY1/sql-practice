-- =====================================================
-- Задача: Анализ самых больших заказов - пользователи и курьеры
-- Тема: Многоуровневый анализ с CTE и расчетом возраста

-- Цель: Определить кто заказывал и доставлял самые большие заказы
--        (с наибольшим количеством товаров) и рассчитать их возраст

-- Условия:
-- • Найти заказы с максимальным количеством товаров
-- • Определить пользователя (создавшего) и курьера (доставившего)
-- • Рассчитать возраст относительно последней даты в user_actions
-- • Учесть возможность нескольких заказов с одинаковым максимальным размером
-- =====================================================
WITH largest_orders AS (
  SELECT 
    order_id 
  FROM 
    orders 
  WHERE 
    array_length(product_ids, 1) = (
      SELECT 
        MAX(
          array_length(product_ids, 1)
        ) 
      FROM 
        orders
    )
), 
order_details AS (
  SELECT 
    o.order_id, 
    ua.user_id, 
    ca.courier_id 
  FROM 
    orders o 
    JOIN user_actions ua ON o.order_id = ua.order_id 
    AND ua.action = 'create_order' 
    JOIN courier_actions ca ON o.order_id = ca.order_id 
    AND ca.action = 'deliver_order' 
  WHERE 
    o.order_id IN (
      SELECT 
        order_id 
      FROM 
        largest_orders
    )
), 
last_date AS (
  SELECT 
    MAX(time) AS max_time 
  FROM 
    user_actions
) 
SELECT 
  od.order_id, 
  od.user_id, 
  EXTRACT(
    YEAR 
    FROM 
      AGE(ld.max_time, u.birth_date)
  ):: integer AS user_age, 
  od.courier_id, 
  EXTRACT(
    YEAR 
    FROM 
      AGE(ld.max_time, c.birth_date)
  ):: integer AS courier_age 
FROM 
  order_details od 
  JOIN users u ON od.user_id = u.user_id 
  JOIN couriers c ON od.courier_id = c.courier_id CROSS 
  JOIN last_date ld 
ORDER BY 
  od.order_id

-- Логика решения:
-- 1. CTE largest_orders: Идентификация самых больших заказов
--    • array_length(product_ids, 1) - подсчет товаров в заказе
--    • Подзапрос MAX() находит максимальное количество товаров
--    • WHERE = MAX гарантирует учет всех заказов максимального размера
--
-- 2. CTE order_details: Сбор информации о заказах
--    • JOIN user_actions с фильтром action = 'create_order' - находим пользователя
--    • JOIN courier_actions с фильтром action = 'deliver_order' - находим курьера
--    • Фильтрация по largest_orders - только самые большие заказы
--
-- 3. CTE last_date: Определение точки отсчета для возраста
--    • MAX(time) FROM user_actions - последняя известная дата в данных
--    • Используется для консистентного расчета возраста
--
-- 4. ФИНАЛЬНЫЙ ЗАПРОС: Расчет возраста и формирование результата
--    • EXTRACT(YEAR FROM AGE()) - вычисление полных лет
--    • JOIN users и couriers для получения дат рождения
--    • CROSS JOIN last_date для доступа к дате отсчета
--    • ORDER BY order_id - сортировка по возрастанию ID заказа

-- Пример результата:
-- order_id | user_id | user_age | courier_id | courier_age
-- 1001     | 2001    | 33       | 3001       | 38
-- 1002     | 2003    | 28       | 3005       | 41