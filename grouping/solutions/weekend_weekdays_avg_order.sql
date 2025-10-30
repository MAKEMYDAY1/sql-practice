-- =====================================================
-- Задача: Средний размер заказа по выходным и будням
-- Тема: Группировка данных в SQL
-- Цель: Рассчитать средний размер заказа для выходных и будних дней

-- Используемые операторы:
-- CASE WHEN - разделение дней на выходные и будни
-- DATE_PART() - извлечение дня недели из даты
-- GROUP BY с вычисляемым полем - группировка по типам дней
-- AVG() - расчет среднего размера заказа
-- ROUND() - округление результата
-- ORDER BY - сортировка результатов
-- =====================================================
SELECT 
  CASE WHEN DATE_PART('dow', creation_time) = 6 THEN 'weekend' WHEN DATE_PART('dow', creation_time) = 0 THEN 'weekend' WHEN DATE_PART('dow', creation_time) BETWEEN 1 
  AND 5 THEN 'weekdays' END AS week_part, 
  ROUND(
    AVG(
      ARRAY_LENGTH(product_ids, 1)
    ), 
    2
  ) AS avg_order_size 
FROM 
  orders 
GROUP BY 
  week_part 
ORDER BY 
  avg_order_size
