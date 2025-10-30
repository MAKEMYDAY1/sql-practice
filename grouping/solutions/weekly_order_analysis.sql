-- =====================================================
-- Задача: Анализ эффективности заказов по дням недели
-- Тема: Условная агрегация и временные расчеты
-- Цель: Проанализировать паттерны оформления и отмен заказов по дням недели

-- Используемые операторы:
-- DATE_PART('isodow') - извлечение порядкового номера дня недели (1-понедельник, 7-воскресенье)
-- TO_CHAR('Dy') - получение сокращенного названия дня недели
-- COUNT() FILTER (WHERE) - условный подсчет с фильтрацией
-- ROUND() - округление числовых значений
-- Группировка по нескольким полям
-- =====================================================

SELECT 
  DATE_PART('isodow', time):: INTEGER AS weekday_number, 
  TO_CHAR(time, 'Dy') AS weekday, 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'create_order'
  ) AS created_orders, 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'cancel_order'
  ) AS canceled_orders, 
  COUNT(order_id) FILTER (
    WHERE 
      action = 'create_order'
  ) - COUNT(order_id) FILTER (
    WHERE 
      action = 'cancel_order'
  ) AS actual_orders, 
  ROUND(
    (
      COUNT(order_id) FILTER (
        WHERE 
          action = 'create_order'
      ) - COUNT(order_id) FILTER (
        WHERE 
          action = 'cancel_order'
      )
    ):: DECIMAL / COUNT(order_id) FILTER (
      WHERE 
        action = 'create_order'
    ), 
    3
  ) AS success_rate 
FROM 
  user_actions 
WHERE 
  time BETWEEN '2022-08-24' 
  AND '2022-09-07' 
GROUP BY 
  TO_CHAR(time, 'Dy'), 
  DATE_PART('isodow', time) 
ORDER BY 
  DATE_PART('isodow', time)

-- Логика решения:
-- 1. DATE_PART('isodow', time)::INTEGER - извлекает номер дня недели по ISO стандарту
--    • 1 - понедельник, 2 - вторник, ..., 7 - воскресенье
--    • ::INTEGER преобразует в целое число для лучшей читаемости
-- 2. TO_CHAR(time, 'Dy') - получает сокращенное название дня недели
--    • 'Mon', 'Tue', 'Wed', etc.
-- 3. COUNT() FILTER (WHERE action = 'create_order') - подсчет созданных заказов
--    • Учитывает только действия создания заказа
-- 4. COUNT() FILTER (WHERE action = 'cancel_order') - подсчет отмененных заказов
--    • Учитывает только действия отмены заказа
-- 5. actual_orders = created_orders - canceled_orders
--    • Расчет фактически доставленных заказов
-- 6. success_rate = actual_orders / created_orders
--    • Доля успешных (неотмененных) заказов
--    • ::DECIMAL обеспечивает точное деление с плавающей точкой
--    • ROUND(..., 3) округляет до трех знаков после запятой

-- Пример результата:
-- weekday_number | weekday | created_orders | canceled_orders | actual_orders | success_rate
-- 1              | Mon     | 2456           | 189             | 2267          | 0.923
-- 2              | Tue     | 2312           | 167             | 2145          | 0.928
-- 3              | Wed     | 2289           | 172             | 2117          | 0.925