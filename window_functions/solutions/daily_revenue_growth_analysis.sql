-- =====================================================
-- Задача: Анализ ежедневного прироста выручки
-- Тема: Оконные функции смещения для анализа временных рядов

-- Цель: Рассчитать ежедневную выручку и ее прирост относительно предыдущего дня
--        в абсолютных и относительных значениях

-- Условия:
-- • Исключить отмененные заказы из расчета выручки
-- • Рассчитать абсолютный прирост выручки (разница с предыдущим днем)
-- • Рассчитать относительный прирост выручки (% изменения)
-- • Для первого дня принять прирост равным 0
-- • Округлить все метрики до одного знака после запятой
-- =====================================================
WITH daily_revenue_table AS (
  SELECT 
    DATE(creation_time) AS date, 
    ROUND(
      SUM(price), 
      1
    ) AS daily_revenue 
  FROM 
    orders CROSS 
    JOIN UNNEST(product_ids) AS product_id 
    LEFT JOIN products USING(product_id) 
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
) 
SELECT 
  date, 
  daily_revenue, 
  COALESCE(
    ROUND(
      daily_revenue - LAG(daily_revenue) OVER (
        ORDER BY 
          date
      ), 
      1
    ), 
    0
  ) AS revenue_growth_abs, 
  COALESCE(
    ROUND(
      (
        daily_revenue - LAG(daily_revenue) OVER (
          ORDER BY 
            date
        )
      ) * 100.0 / NULLIF(
        LAG(daily_revenue) OVER (
          ORDER BY 
            date
        ), 
        0
      ), 
      1
    ), 
    0
  ) AS revenue_growth_percentage 
FROM 
  daily_revenue_table 
ORDER BY 
  date

-- Логика решения:
-- 1. CTE daily_revenue_table: Расчет базовой ежедневной выручки
--    • UNNEST(product_ids) + LEFT JOIN products - получение цен всех товаров в заказах
--    • Фильтрация отмененных заказов через подзапрос NOT IN
--    • GROUP BY DATE(creation_time) - агрегация по дням
--    • ROUND(SUM(price), 1) - вычисление и округление ежедневной выручки
--
-- 2. Расчет абсолютного прироста (revenue_growth_abs):
--    • LAG(daily_revenue) OVER (ORDER BY date) - выручка за предыдущий день
--    • daily_revenue - LAG(daily_revenue) - разница с предыдущим днем
--    • COALESCE(..., 0) - для первого дня (когда нет предыдущего) устанавливаем 0
--    • ROUND(..., 1) - округление до одного знака
--
-- 3. Расчет относительного прироста (revenue_growth_percentage):
--    • (current - previous) / previous * 100 - формула процентного изменения
--    • NULLIF(LAG(...), 0) - защита от деления на ноль (если предыдущая выручка = 0)
--    • * 100.0 - умножение на decimal для точного процентного расчета
--    • COALESCE(..., 0) - обработка NULL (первый день или деление на ноль)
--
-- 4. Финальная сортировка:
--    • ORDER BY date - хронологический порядок для временного ряда

-- Пример результата:
-- date       | daily_revenue | revenue_growth_abs | revenue_growth_percentage
-- 2023-09-01 | 12580.5       | 0.0                | 0.0
-- 2023-09-02 | 18420.7       | 5840.2             | 46.4
-- 2023-09-03 | 15230.2       | -3190.5            | -17.3
-- 2023-09-04 | 19840.6       | 4610.4             | 30.3