-- https://school.programmers.co.kr/learn/courses/30/lessons/131116

SELECT
    CATEGORY
    , PRICE
    , PRODUCT_NAME
FROM (
    SELECT
        CATEGORY
        , PRICE
        , PRODUCT_NAME
        , RANK() OVER(PARTITION BY CATEGORY ORDER BY PRICE DESC) RNK
    FROM
        FOOD_PRODUCT
    WHERE
        CATEGORY IN ('과자', '국', '김치', '식용유')
) T
WHERE 
    RNK = 1
ORDER BY
    PRICE DESC
;