-- https://school.programmers.co.kr/learn/courses/30/lessons/62284

SELECT DISTINCT
    CART_ID
FROM
    CART_PRODUCTS A
    JOIN CART_PRODUCTS B USING(CART_ID)
WHERE
    A.NAME = 'Milk'
    AND B.NAME = 'Yogurt'
ORDER BY
    1 ASC
;    