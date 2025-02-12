-- https://school.programmers.co.kr/learn/courses/30/lessons/59413

WITH RECURSIVE TT AS (
    SELECT 0 HOUR
    FROM DUAL
    UNION ALL
    SELECT HOUR+1
    FROM TT
    WHERE HOUR <=22
)
SELECT 
    HOUR
    , IFNULL(COUNT, 0) COUNT
FROM (
    SELECT 
        HOUR(DATETIME) HOUR
        , COUNT(*) COUNT
    FROM 
        ANIMAL_OUTS O
    GROUP BY
        HOUR(DATETIME)
) T
RIGHT JOIN TT USING(HOUR)
;