WITH 
user_dates AS (
    SELECT 
        user_id,
        MIN(time::date) AS date
    FROM user_actions
    GROUP BY user_id
),
courier_dates AS (
    SELECT 
        courier_id,
        MIN(time::date) AS date
    FROM courier_actions
    GROUP BY courier_id
),
dates AS (
    SELECT DISTINCT time::date AS date
    FROM user_actions
    UNION
    SELECT DISTINCT time::date AS date
    FROM courier_actions
)

SELECT 
    date,
    COUNT(DISTINCT user_dates.user_id)::INTEGER AS new_users,
    COUNT(DISTINCT courier_dates.courier_id)::INTEGER AS new_couriers,
    SUM(COUNT(DISTINCT user_dates.user_id)) OVER (ORDER BY date)::INTEGER AS total_users,
    SUM(COUNT(DISTINCT courier_dates.courier_id)) OVER (ORDER BY date)::INTEGER AS total_couriers
FROM dates
LEFT JOIN user_dates USING (date)
LEFT JOIN courier_dates USING (date)
GROUP BY date
ORDER BY date