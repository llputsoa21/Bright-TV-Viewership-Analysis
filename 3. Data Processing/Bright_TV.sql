## BRIGHT TV Case Study
--  Tables: viewership_tv | user_profiles_tv

-- 1. View raw viewership data
-- ------------------------------------------------------------

SELECT *
FROM viewership_tv
LIMIT 100;

-- 2. Check the date range of viewership data
-- ------------------------------------------------------------

SELECT
  MIN(to_timestamp(RecordDate2) + INTERVAL 2 HOURS) AS min_view_date_sast,
  MAX(to_timestamp(RecordDate2) + INTERVAL 2 HOURS) AS max_view_date_sast
FROM viewership_tv;

-- 3. Count distinct users
-- ------------------------------------------------------------

SELECT
  COUNT(DISTINCT UserID) AS number_of_users
FROM user_profiles_tv;

-- 4. Check available channels
-- ------------------------------------------------------------

SELECT DISTINCT
  Channel2 AS channel
FROM viewership_tv
ORDER BY channel;

-- 5. Data quality checks (nulls)
-- ------------------------------------------------------------

SELECT *
FROM viewership_tv
WHERE UserID0    IS NULL
   OR RecordDate2 IS NULL
   OR `Duration 2` IS NULL;

-- 6. Row and distinct counts
-- ------------------------------------------------------------

SELECT
  COUNT(*) AS number_of_rows,
  COUNT(DISTINCT UserID0) AS number_of_users,
  COUNT(DISTINCT Channel2) AS number_of_channels
FROM viewership_tv;

-- 7. Base JOIN: viewership_tv + user_profiles_tv
-- ------------------------------------------------------------

SELECT
  v.UserID0      AS user_id,
  u.Gender       AS gender,
  u.Age          AS age,
  u.Province     AS province,
  u.Race         AS race,
  v.Channel2     AS channel,
  v.RecordDate2  AS record_datetime_utc,
  (to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) AS record_datetime_sast,
  v.`Duration 2` AS duration_hhmmss
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID;
  
-- 8. Changing duration to non-negative seconds showing on my result table
-- -------------------------------------------------------------------------

SELECT
  v.UserID0      AS user_id,
  u.Gender       AS gender,
  u.Age          AS age,
  u.Province     AS province,
  u.Race         AS race,
  v.Channel2     AS channel,
  v.RecordDate2  AS record_datetime_utc,
  (to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) AS record_datetime_sast,
  v.`Duration 2` AS duration_hhmmss,
 
  CASE
    WHEN v.`Duration 2` IS NULL THEN 0
    ELSE ABS(
           hour(v.`Duration 2`)   * 3600 +
           minute(v.`Duration 2`) * 60   +
           second(v.`Duration 2`)
         )
  END AS seconds_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID;

-- ------------------------------------------------------------
-- Q9. Total time viewed per user
-- ------------------------------------------------------------
 
SELECT
  v.UserID0  AS user_id,
  u.Gender   AS gender,
  u.Province AS province,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY
  v.UserID0,
  u.Gender,
  u.Province
ORDER BY total_seconds_viewed DESC;

-- Q10. Total time viewed per channel
-- ------------------------------------------------------------
 
SELECT
  v.Channel2 AS channel,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
GROUP BY v.Channel2
ORDER BY total_seconds_viewed DESC;

--- Q11. Viewership trend by time of day (SAST)
-- ------------------------------------------------------------
 
SELECT
  CASE
    WHEN hour(to_timestamp(RecordDate2) + INTERVAL 2 HOURS) BETWEEN 5  AND 11 THEN 'Morning'
    WHEN hour(to_timestamp(RecordDate2) + INTERVAL 2 HOURS) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN hour(to_timestamp(RecordDate2) + INTERVAL 2 HOURS) BETWEEN 17 AND 20 THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
 
  SUM(
    CASE
      WHEN `Duration 2` IS NULL
        THEN 0
      WHEN (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`)) < 0
        THEN (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`)) * -1
      ELSE
           (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN `Duration 2` IS NULL
          THEN 0
        WHEN (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`)) < 0
          THEN (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`)) * -1
        ELSE
             (hour(`Duration 2`) * 3600 + minute(`Duration 2`) * 60 + second(`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv
GROUP BY time_of_day
ORDER BY total_seconds_viewed DESC;

-- Q12. Total viewership by province
-- ------------------------------------------------------------

SELECT
  u.Province AS province,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
INNER JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY u.Province
ORDER BY total_seconds_viewed DESC;

-- Q13. Total viewership by gender
-- ------------------------------------------------------------
 
SELECT
  u.Gender AS gender,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY u.Gender
ORDER BY total_seconds_viewed DESC;


-- Q14. Viewership by channel, age group and time of day (SAST)
-- ------------------------------------------------------------
-- Q14. Viewership by channel, age group and time of day (SAST)
-- ------------------------------------------------------------
 
SELECT
  v.Channel2 AS channel,
 
  CASE
    WHEN u.Age IS NULL           THEN 'unknown'
    WHEN u.Age < 18              THEN 'children'
    WHEN u.Age BETWEEN 18 AND 35 THEN 'youth'
    WHEN u.Age BETWEEN 36 AND 59 THEN 'adults'
    WHEN u.Age >= 60             THEN 'pensioners'
    ELSE 'unknown'
  END AS age_group,
 
  CASE
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) BETWEEN 5  AND 11 THEN 'Morning'
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) BETWEEN 17 AND 20 THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY
  v.Channel2,
  age_group,
  time_of_day
ORDER BY
  channel,
  age_group,
  time_of_day;
 
-- Q15. Highest viewed channel per month by province (SAST)
-- ------------------------------------------------------------
 
SELECT
  u.Province AS province,
  date_format(
    to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS,
    'yyyy-MM'
  )          AS month_sast,
  v.Channel2 AS channel,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY
  u.Province,
  month_sast,
  v.Channel2
ORDER BY
  month_sast DESC,
  u.Province,
  total_seconds_viewed DESC;
 
-- Q16. Viewership by race
-- ------------------------------------------------------------
 
SELECT
  u.Race AS race,
 
  SUM(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END
  ) AS total_seconds_viewed,
 
  ROUND(
    SUM(
      CASE
        WHEN v.`Duration 2` IS NULL
          THEN 0
        WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
          THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
        ELSE
             (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
      END
    ) / 3600.0, 2
  ) AS total_hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID
GROUP BY u.Race
ORDER BY total_seconds_viewed DESC;

-- Q17. SQL Report for Download
-- ============================
SELECT
 
  -- Tables in Question
  v.UserID0 AS user_id,
  v.Channel2 AS channel,
 
  -- Timestamps 
  v.RecordDate2 AS record_datetime_utc,
  (to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS) AS record_datetime_sast,
  date_format(
    to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS,
    'yyyy-MM') AS month_sast,
 
  -- Raw duration
  v.`Duration 2` AS duration_hhmmss,
 
  -- User profile dimensions
  u.Gender  AS gender,
  u.Age     AS age,
  u.Province AS province,
  u.Race AS race,
 
  -- Age group
  CASE
    WHEN u.Age IS NULL           THEN 'unknown'
    WHEN u.Age < 18              THEN 'children'
    WHEN u.Age BETWEEN 18 AND 35 THEN 'youth'
    WHEN u.Age BETWEEN 36 AND 59 THEN 'adults'
    WHEN u.Age >= 60             THEN 'pensioners'
    ELSE 'unknown'
  END AS age_group,
 
  -- Time of day (SAST)
  CASE
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS)
         BETWEEN 5  AND 11 THEN 'Morning'
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS)
         BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN hour(to_timestamp(v.RecordDate2) + INTERVAL 2 HOURS)
         BETWEEN 17 AND 20 THEN 'Evening'
    ELSE 'Night'
  END AS time_of_day,
 
  -- Seconds viewed
  CASE
    WHEN v.`Duration 2` IS NULL
      THEN 0
    WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
      THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
    ELSE
         (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
  END AS seconds_viewed,
 
  -- Hours viewed (seconds divided by 3600, rounded to 2 decimals)
  ROUND(
    CASE
      WHEN v.`Duration 2` IS NULL
        THEN 0
      WHEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) < 0
        THEN (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`)) * -1
      ELSE
           (hour(v.`Duration 2`) * 3600 + minute(v.`Duration 2`) * 60 + second(v.`Duration 2`))
    END / 3600.0, 2) AS hours_viewed
 
FROM viewership_tv v
LEFT JOIN user_profiles_tv u
  ON v.UserID0 = u.UserID;
