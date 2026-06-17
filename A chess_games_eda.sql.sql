DROP TABLE IF EXISTS chess_games;

CREATE TABLE chess_games (
    event TEXT,
    white_player TEXT,
    black_player TEXT,
    result TEXT,
    utc_date TEXT,
    utc_time TEXT,
    white_elo INTEGER,
    black_elo INTEGER,
    white_rating_diff NUMERIC(10,2),
    black_rating_diff NUMERIC(10,2),
    eco VARCHAR(10),
    opening TEXT,
    time_control VARCHAR(50),
    termination TEXT,
    an_moves TEXT
);
SELECT COUNT(*)
FROM chess_games;

SELECT column_name
FROM information_schema.columns
WHERE table_name='chess_games'
ORDER BY ordinal_position;

SELECT *
FROM chess_games
LIMIT 10;

--White Wins vs Black Wins
SELECT
    result,
    COUNT(*) AS games
FROM chess_games
GROUP BY result
ORDER BY games DESC;

--Most Popular Openings

SELECT
    opening,
    COUNT(*) AS games
FROM chess_games
GROUP BY opening
ORDER BY games DESC
LIMIT 20;

--Average Player Rating

SELECT
    ROUND(AVG(white_elo),2) AS avg_white,
    ROUND(AVG(black_elo),2) AS avg_black
FROM chess_games;

--Top 20 Highest Rated Players

SELECT
    white_player,
    MAX(white_elo) AS max_rating
FROM chess_games
GROUP BY white_player
ORDER BY max_rating DESC
LIMIT 20;

--Average Rating by Opening

SELECT
    opening,
    ROUND(
        AVG((white_elo + black_elo)/2.0),
        2
    ) AS avg_rating
FROM chess_games
GROUP BY opening
HAVING COUNT(*) > 100
ORDER BY avg_rating DESC;

--Most Common Time Controls
SELECT
    time_control,
    COUNT(*)
FROM chess_games
GROUP BY time_control
ORDER BY COUNT(*) DESC;

--White Win %
SELECT
ROUND(
100.0 *
COUNT(*) FILTER(
WHERE result='1-0'
)
/ COUNT(*),
2
) AS white_win_pct
FROM chess_games;

--Black Win %

SELECT
ROUND(
100.0 *
COUNT(*) FILTER(
WHERE result='0-1'
)
/ COUNT(*),
2
) AS black_win_pct
FROM chess_games;

--Draw %

SELECT
ROUND(
100.0 *
COUNT(*) FILTER(
WHERE result='1/2-1/2'
)
/ COUNT(*),
2
) AS draw_pct
FROM chess_games;


CREATE INDEX idx_opening
ON chess_games(opening);

CREATE INDEX idx_white_elo
ON chess_games(white_elo);

CREATE INDEX idx_black_elo
ON chess_games(black_elo);

CREATE INDEX idx_result
ON chess_games(result);

CREATE INDEX idx_time_control
ON chess_games(time_control);

ANALYZE chess_games;

EXPLAIN ANALYZE
SELECT *
FROM chess_games
WHERE time_control = '300+0';

--Top 10 Openings

SELECT
    opening,
    COUNT(*) AS games
FROM chess_games
GROUP BY opening
ORDER BY games DESC
LIMIT 10;
