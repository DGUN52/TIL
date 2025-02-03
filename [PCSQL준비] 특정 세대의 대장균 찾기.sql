-- 특정 세대의 대장균 찾기
-- https://school.programmers.co.kr/learn/courses/30/lessons/301650
WITH RECURSIVE TMP AS (
    SELECT
        1 GEN
        , ID
        , PARENT_ID
    FROM
        ECOLI_DATA
    WHERE
        PARENT_ID IS NULL
    UNION ALL
    SELECT
        T.GEN+1
        , E.ID
        , E.PARENT_ID
    FROM
        TMP T JOIN ECOLI_DATA E ON T.ID = E.PARENT_ID
)
SELECT
    ID
FROM
    TMP
WHERE
    GEN = 3
ORDER BY
    1
;
