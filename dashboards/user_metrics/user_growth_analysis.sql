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
),
daily_metrics AS (
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
)

SELECT 
    date,
    new_users,
    new_couriers,
    total_users,
    total_couriers,
    ROUND(
        CASE 
            WHEN LAG(new_users) OVER (ORDER BY date) IS NULL THEN NULL
            WHEN LAG(new_users) OVER (ORDER BY date) = 0 THEN NULL
            ELSE (new_users::DECIMAL - LAG(new_users) OVER (ORDER BY date)) / LAG(new_users) OVER (ORDER BY date) * 100
        END, 2
    ) AS new_users_change,
    ROUND(
        CASE 
            WHEN LAG(new_couriers) OVER (ORDER BY date) IS NULL THEN NULL
            WHEN LAG(new_couriers) OVER (ORDER BY date) = 0 THEN NULL
            ELSE (new_couriers::DECIMAL - LAG(new_couriers) OVER (ORDER BY date)) / LAG(new_couriers) OVER (ORDER BY date) * 100
        END, 2
    ) AS new_couriers_change,
    ROUND(
        CASE 
            WHEN LAG(total_users) OVER (ORDER BY date) IS NULL THEN NULL
            WHEN LAG(total_users) OVER (ORDER BY date) = 0 THEN NULL
            ELSE (total_users::DECIMAL - LAG(total_users) OVER (ORDER BY date)) / LAG(total_users) OVER (ORDER BY date) * 100
        END, 2
    ) AS total_users_growth,
    ROUND(
        CASE 
            WHEN LAG(total_couriers) OVER (ORDER BY date) IS NULL THEN NULL
            WHEN LAG(total_couriers) OVER (ORDER BY date) = 0 THEN NULL
            ELSE (total_couriers::DECIMAL - LAG(total_couriers) OVER (ORDER BY date)) / LAG(total_couriers) OVER (ORDER BY date) * 100
        END, 2
    ) AS total_couriers_growth
FROM daily_metrics
ORDER BY date