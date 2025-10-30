-- =====================================================
-- Задача: Демографический анализ пользователей по возрастным группам
-- Тема: Группировка данных в SQL
-- Цель: Сегментировать пользователей на 4 возрастные группы и проанализировать распределение

-- Используемые операторы:
-- CASE WHEN - создание возрастных категорий
-- DATE_PART с AGE - точный расчет возраста в полных годах
-- WHERE IS NOT NULL - фильтрация пользователей с известной датой рождения
-- GROUP BY с ORDER BY - группировка и сортировка по категориям
-- =====================================================

SELECT 
  CASE WHEN DATE_PART(
    'year', 
    AGE(birth_date)
  ):: INTEGER BETWEEN 18 
  AND 24 THEN '18-24' WHEN DATE_PART(
    'year', 
    AGE(birth_date)
  ):: INTEGER BETWEEN 25 
  AND 29 THEN '25-29' WHEN DATE_PART(
    'year', 
    AGE(birth_date)
  ):: INTEGER BETWEEN 30 
  AND 35 THEN '30-35' ELSE '36+' END AS group_age, 
  COUNT(user_id) AS users_count 
FROM 
  users 
WHERE 
  birth_date IS NOT NULL 
GROUP BY 
  group_age 
ORDER BY 
  group_age
