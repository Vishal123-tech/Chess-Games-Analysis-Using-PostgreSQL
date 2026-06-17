--1. Data Cleaning Section
-- Check NULL values
SELECT
COUNT(*) FILTER (WHERE opening IS NULL) AS opening_nulls,
COUNT(*) FILTER (WHERE white_elo IS NULL) AS white_elo_nulls,
COUNT(*) FILTER (WHERE black_elo IS NULL) AS black_elo_nulls
FROM chess_games;

-- Duplicate games
SELECT
event,
white_player,
black_player,
utc_date,
COUNT(*)
FROM chess_games
GROUP BY 1,2,3,4
HAVING COUNT(*) > 1;

--2. Rating Gap Analysis
SELECT
white_player,
black_player,
white_elo,
black_elo,
result,
ABS(white_elo - black_elo) AS rating_gap
FROM chess_games
WHERE
(result='1-0' AND white_elo < black_elo)
OR
(result='0-1' AND black_elo < white_elo)
ORDER BY rating_gap DESC
LIMIT 20;


--3. Opening Effectiveness

SELECT
opening,
ROUND(
100.0 *
COUNT(*) FILTER (WHERE result='1-0')
/
COUNT(*),
2
) AS white_win_rate,
COUNT(*) AS games
FROM chess_games
GROUP BY opening
HAVING COUNT(*) > 1000
ORDER BY white_win_rate DESC
LIMIT 20;

--Best Openings for Black
SELECT
opening,
ROUND(
100.0 *
COUNT(*) FILTER (WHERE result='0-1')
/
COUNT(*),
2
) AS black_win_rate,
COUNT(*) AS games
FROM chess_games
GROUP BY opening
HAVING COUNT(*) > 1000
ORDER BY black_win_rate DESC
LIMIT 20;

--4. Rating Buckets

SELECT
CASE
WHEN white_elo < 1000 THEN 'Beginner'
WHEN white_elo < 1500 THEN 'Intermediate'
WHEN white_elo < 2000 THEN 'Advanced'
ELSE 'Expert'
END AS skill_level,
COUNT(*)
FROM chess_games
GROUP BY skill_level;

--5. Window Functions 
--Interviewers love these.

SELECT
white_player,
MAX(white_elo) AS max_rating,
RANK() OVER(
ORDER BY MAX(white_elo) DESC
) AS ranking
FROM chess_games
GROUP BY white_player;

--Top Opening Per Rating Range

WITH rating_groups AS (
SELECT *,
CASE
WHEN white_elo < 1200 THEN 'Beginner'
WHEN white_elo < 1800 THEN 'Intermediate'
ELSE 'Advanced'
END AS category
FROM chess_games
)
SELECT *
FROM (
SELECT
category,
opening,
COUNT(*) AS games,
ROW_NUMBER() OVER(
PARTITION BY category
ORDER BY COUNT(*) DESC
) rn
FROM rating_groups
GROUP BY category, opening
)t
WHERE rn=1;

--6. CTEs

WITH avg_rating AS (
SELECT AVG(white_elo) avg_elo
FROM chess_games
)
SELECT *
FROM chess_games, avg_rating
WHERE white_elo > avg_elo;

--7. Performance Analysis
EXPLAIN ANALYZE
SELECT *
FROM chess_games
WHERE opening='Sicilian Defense';

--8. Business Insights Section
--Which opening is most popular among experts?
SELECT
opening,
COUNT(*)
FROM chess_games
WHERE white_elo > 2200
GROUP BY opening
ORDER BY COUNT(*) DESC
LIMIT 10;

--Which time control produces most decisive games?
SELECT
time_control,
COUNT(*) FILTER(
WHERE result IN ('1-0','0-1')
) AS decisive_games
FROM chess_games
GROUP BY time_control
ORDER BY decisive_games DESC;

--9. Materialized View
CREATE MATERIALIZED VIEW opening_stats AS
SELECT
opening,
COUNT(*) AS total_games,
AVG(white_elo) AS avg_rating
FROM chess_games
GROUP BY opening;


