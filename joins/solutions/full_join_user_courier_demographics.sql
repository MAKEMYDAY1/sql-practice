-- =====================================================
-- Задача: Сравнение демографического распределения пользователей и курьеров по датам рождения
-- Тема: FULL JOIN между агрегированными подзапросами

-- Цель: Сравнить распределение дат рождения пользователей и курьеров для анализа демографического сходства

-- Используемые операторы:
-- FULL JOIN - объединение с сохранением всех записей из обеих таблиц
-- Подзапросы с GROUP BY - предварительная агрегация данных
-- COUNT с GROUP BY - подсчёт количества записей по группам
-- =====================================================
SELECT 
  a.birth_date AS users_birth_date, 
  b.birth_date AS couriers_birth_date, 
  a.users_count, 
  b.couriers_count 
FROM 
  (
    SELECT 
      birth_date, 
      COUNT(user_id) AS users_count 
    FROM 
      users 
    WHERE 
      birth_date IS NOT NULL 
    GROUP BY 
      birth_date
  ) AS a FULL 
  JOIN (
    SELECT 
      birth_date, 
      COUNT(courier_id) AS couriers_count 
    FROM 
      couriers 
    WHERE 
      birth_date IS NOT NULL 
    GROUP BY 
      birth_date
  ) AS b ON a.birth_date = b.birth_date 
ORDER BY 
  users_birth_date, 
  couriers_birth_date
