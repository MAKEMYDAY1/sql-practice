-- =====================================================
-- Задача: Анализ текущих минимумов и максимумов с оконными функциями
-- Тема: Накопительные агрегаты с ORDER BY в оконных функциях

-- Цель: Исследовать поведение MIN() и MAX() оконных функций 
--        при наличии инструкции ORDER BY и понять концепцию "бегущего" окна

-- Условия:
-- • Применить MAX() и MIN() с ORDER BY price DESC
-- • Проанализировать результат вычислений
-- • Понять разницу между окном всей таблицы и накопительным окном
-- =====================================================
SELECT 
  product_id, 
  name, 
  price, 
  max_price, 
  min_price 
FROM 
  (
    SELECT 
      product_id, 
      name, 
      price, 
      MAX(price) OVER (
        ORDER BY 
          price DESC
      ) AS max_price, 
      MIN(price) OVER (
        ORDER BY 
          price DESC
      ) AS min_price 
    FROM 
      products
  ) AS t1 
ORDER BY 
  price DESC, 
  product_id
