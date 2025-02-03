-- 연간 평가점수에 해당하는 평가 등급 및 성과금 조회하기
-- https://school.programmers.co.kr/learn/courses/30/lessons/284528
WITH CALC_GRADE AS(
    SELECT
        EMP_NO
        , EMP_NAME
        , SAL
        , CASE
            WHEN AVG(SCORE) >= 96 THEN 'S'
            WHEN AVG(SCORE) >= 90 THEN 'A'
            WHEN AVG(SCORE) >= 80 THEN 'B'
            ELSE 'C'
        END GRADE
    FROM
        HR_EMPLOYEES E
        JOIN HR_GRADE G USING(EMP_NO)
    GROUP BY
        EMP_NO
)
SELECT
    EMP_NO
    , EMP_NAME
    , GRADE
    , CASE
        WHEN GRADE = 'S' THEN SAL*0.2
        WHEN GRADE = 'A' THEN SAL*0.15
        WHEN GRADE = 'B' THEN SAL*0.1
        ELSE SAL
    END BONUS
FROM 
    CALC_GRADE
ORDER BY
    1 ASC
;