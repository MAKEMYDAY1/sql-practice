-- =====================================================
-- Задача: Подсчёт уникальных пользователей после объединения таблиц
-- Тема: JOIN с агрегацией и вложенными запросами

-- Цель: Определить количество уникальных пользователей, присутствующих в обеих таблицах

-- Используемые операторы:
-- JOIN - объединение таблиц по ключевому полю
-- COUNT(DISTINCT) - подсчёт уникальных значений
-- Подзапрос в FROM - создание временной таблицы для агрегации
-- =====================================================
SELECT 
  COUNT(DISTINCT user_id_left) AS users_count 
FROM 
  (
    SELECT 
      user_actions.user_id AS user_id_left, 
      users.user_id AS user_id_right, 
      order_id, 
      time, 
      action, 
      sex, 
      birth_date 
    FROM 
      user_actions 
      JOIN users ON user_actions.user_id = users.user_id 
    ORDER BY 
      user_actions.user_id
  ) AS t1

-- Логика решения:
-- 1. ВНУТРЕННИЙ ПОДЗАПРОС: Объединение таблиц user_actions и users
--    • JOIN users ON user_actions.user_id = users.user_id - INNER JOIN по ключевому полю
--    • user_actions.user_id AS user_id_left - ID из таблицы действий
--    • users.user_id AS user_id_right - ID из таблицы профилей
--    • ORDER BY user_actions.user_id - сортировка (не влияет на COUNT)
--    • Результат: объединённая таблица с пользователями, присутствующими в обеих таблицах
--
-- 2. ВНЕШНИЙ ЗАПРОС: Агрегация для подсчёта уникальных пользователей
--    • COUNT(DISTINCT user_id_left) - подсчёт уникальных ID пользователей
--    • DISTINCT гарантирует, что каждый пользователь учитывается только один раз
--    • user_id_left и user_id_right содержат одинаковые значения (благодаря JOIN)
--
-- 3. AS t1 - алиас для подзапроса (обязателен в PostgreSQL)

-- Альтернативное решение (более эффективное):
-- SELECT COUNT(DISTINCT ua.user_id) AS users_count
-- FROM user_actions ua
-- JOIN users u ON ua.user_id = u.user_id;

-- Пример результата:
-- users_count
-- 10787
