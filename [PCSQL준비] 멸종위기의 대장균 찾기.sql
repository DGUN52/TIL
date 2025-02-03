-- 멸종위기의 대장균 찾기
-- https://school.programmers.co.kr/learn/courses/30/lessons/301651

WITH RECURSIVE TMP AS (
    SELECT 
        1 'GENERATION'
        , ID
        , PARENT_ID
    FROM 
        ECOLI_DATA E1
    WHERE 
        PARENT_ID IS NULL
    UNION ALL
    SELECT
        GENERATION+1
        , E2.ID
        , E2.PARENT_ID
    FROM 
        ECOLI_DATA E2
        JOIN TMP ON TMP.ID = E2.PARENT_ID
)
SELECT 
    COUNT(*) COUNT
    , T1.GENERATION GENERATION
FROM 
    TMP T1
    LEFT JOIN ECOLI_DATA E ON T1.ID = E.PARENT_ID
WHERE 
    E.ID IS NULL
GROUP BY
    2
;