-- =====================================================
-- Задача: Преобразование LEFT JOIN в INNER JOIN с помощью WHERE
-- Тема: Фильтрация результатов JOIN для эмуляции разных типов соединений

-- Цель: Показать эквивалентность LEFT JOIN + WHERE NOT NULL и INNER JOIN

-- Используемые операторы:
-- LEFT JOIN - объединение с сохранением всех записей из левой таблицы
-- WHERE - фильтрация результатов соединения
-- IS NOT NULL - исключение записей без соответствия
-- =====================================================
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
WHERE 
  users.user_id IS NOT NULL 
ORDER BY 
  user_actions.user_id
