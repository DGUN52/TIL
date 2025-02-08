-- https://school.programmers.co.kr/learn/courses/30/lessons/132204
SELECT
    APNT_NO
    , PT_NAME
    , PT_NO
    , D.MCDP_CD
    , DR_NAME
    , APNT_YMD
FROM
    APPOINTMENT A
    JOIN PATIENT P USING(PT_NO)
    JOIN DOCTOR D ON DR_ID = MDDR_ID
WHERE
    DATE_FORMAT(APNT_YMD, '%Y-%m-%d') = '2022-04-13'
    AND D.MCDP_CD = 'CS'
    AND APNT_CNCL_YN = 'N'
ORDER BY
    APNT_YMD ASC
;