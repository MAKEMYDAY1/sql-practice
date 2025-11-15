-- =====================================================
-- Задача: Ранжирование товаров по цене с использованием оконных функций
-- Тема: Ранжирующие оконные функции - ROW_NUMBER, RANK, DENSE_RANK

-- Цель: Проанализировать распределение товаров по цене с помощью различных методов ранжирования
--        и понять различия между функциями нумерации и ранжирования

-- Условия:
-- • Упорядочить товары от самых дорогих к самым дешевым
-- • Применить три типа ранжирующих функций
-- • Проанализировать различия в результатах
-- =====================================================
SELECT 
  product_id, 
  name, 
  price, 
  product_number, 
  product_rank, 
  product_dense_rank 
FROM 
  (
    SELECT 
      name, 
      price, 
      product_id, 
      ROW_NUMBER() OVER (
        ORDER BY 
          price DESC
      ) AS product_number, 
      RANK() OVER (
        ORDER BY 
          price DESC
      ) AS product_rank, 
      DENSE_RANK() OVER (
        ORDER BY 
          price DESC
      ) AS product_dense_rank 
    FROM 
      products 
    ORDER BY 
      price DESC
  ) AS t1