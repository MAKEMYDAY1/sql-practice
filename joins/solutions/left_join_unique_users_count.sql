-- =====================================================
-- Задача: Подсчёт уникальных пользователей после LEFT JOIN
-- Тема: LEFT JOIN с агрегацией для анализа полноты данных

-- Цель: Определить количество уникальных пользователей в таблице действий, включая тех, у кого нет профиля

-- Используемые операторы:
-- LEFT JOIN - объединение с сохранением всех записей из левой таблицы
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
      LEFT JOIN users ON user_actions.user_id = users.user_id 
    ORDER BY 
      user_actions.user_id
  ) AS t1
