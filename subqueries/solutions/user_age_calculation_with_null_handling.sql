-- =====================================================
-- Задача: Расчет возраста пользователей с обработкой пропущенных значений даты рождения
-- Тема: Продвинутая работа с NULL значениями и условной логикой

-- Цель: Рассчитать возраст всех пользователей, заменив пропущенные даты рождения средним значением
-- =====================================================

WITH last_date AS (
  SELECT 
    MAX(time):: DATE AS max_date 
  FROM 
    user_actions
), 
users_with_age AS (
  SELECT 
    user_id, 
    DATE_PART(
      'year', 
      AGE(
        (
          SELECT 
            max_date 
          FROM 
            last_date
        ), 
        birth_date
      )
    ):: INTEGER AS calculated_age 
  FROM 
    users 
  WHERE 
    birth_date IS NOT NULL
), 
avg_calculated_age AS (
  SELECT 
    AVG(calculated_age):: INTEGER AS avg_age 
  FROM 
    users_with_age
) 
SELECT 
  u.user_id, 
  COALESCE(
    DATE_PART(
      'year', 
      AGE(
        (
          SELECT 
            max_date 
          FROM 
            last_date
        ), 
        u.birth_date
      )
    ):: INTEGER, 
    (
      SELECT 
        avg_age 
      FROM 
        avg_calculated_age
    )
  ) AS age 
FROM 
  users u 
ORDER BY 
  u.user_id;

-- Логика решения:
-- 1. CTE last_date: Определение точки отсчета для расчета возраста
--    • MAX(time) из user_actions - последняя активность в системе
--    • ::DATE - преобразование к типу даты (исключаем время)
--    • Результат: дата, на которую рассчитывается возраст
--
-- 2. CTE users_with_age: Расчет возраста для пользователей с известной датой рождения
--    • DATE_PART('year', AGE(...)) - извлечение количества полных лет
--    • ::INTEGER - преобразование к целому числу
--    • WHERE birth_date IS NOT NULL - только пользователи с известной датой рождения
--    • Результат: user_id и рассчитанный возраст
--
-- 3. CTE avg_calculated_age: Вычисление среднего возраста
--    • AVG(calculated_age) - среднее арифметическое возраста
--    • ::INTEGER - округление до целого числа
--    • Результат: одно число - средний возраст пользователей с известной датой рождения
--
-- 4. ОСНОВНОЙ ЗАПРОС: Финальный расчет с обработкой NULL
--    • COALESCE(value, default) - возвращает value если не NULL, иначе default
--    • Для известных дат рождения: рассчитывается точный возраст
--    • Для NULL birth_date: подставляется среднее значение
--    • ORDER BY user_id - сортировка для удобства чтения

-- Пример работы:
-- Последняя дата: '2022-09-08'
-- Пользователи с известной датой рождения:
-- user_id | birth_date  | calculated_age
-- 1       | 1990-05-15  | 32
-- 3       | 1985-11-20  | 36
-- 5       | 1995-03-08  | 27
--
-- Средний возраст: (32 + 36 + 27) / 3 = 32
--
-- Все пользователи:
-- user_id | birth_date  | age
-- 1       | 1990-05-15  | 32
-- 2       | NULL        | 32  ← подставлено среднее
-- 3       | 1985-11-20  | 36
-- 4       | NULL        | 32  ← подставлено среднее
-- 5       | 1995-03-08  | 27