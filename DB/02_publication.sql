-- BinGo Map / 공개 선별과 결과 확인을 한 파일로 실행
-- 기본 PREVIEW는 조회만 합니다. 기존 식당/공개값을 바꾸지 않습니다.
-- 선별 기준: 상세정보형 전부 + 기본정보형 보충 -> 목표 약 50곳.
-- 상세정보형이 50곳보다 많으면 전부 공개, 후보가 부족하면 50곳 미만입니다.
-- 아래 한 줄의 PREVIEW만 APPLY로 바꾸면 범위 안의 Y/N을 적용합니다.
-- 적용하면 기존 Y도 N이 될 수 있습니다. 식당 행을 지우는 것은 아닙니다.
-- PREVIEW/APPLY 모두 파일 전체를 F5로 실행하세요. Ctrl+Enter용 파일이 아닙니다.
-- APPLY 전에 앱/Loader의 데이터 수정을 멈추고 자동 커밋을 꺼 두세요.
SET SERVEROUTPUT ON
SET DEFINE ON
SET VERIFY OFF
DEFINE BINGO_RESTAURANT_MODE = PREVIEW

PROMPT ===== PUBLICATION PLAN =====
WITH
CONFIG AS (
    -- 전체 오사카시 후보를 대상으로 한 목표 건수입니다.
    -- 아래 좌표 범위는 엉뚱한 도시/0도 좌표를 거르는 근방 검사이며 시 경계 판정이 아닙니다.
    -- 현재 Loader가 오사카시 행정구역에서 수집한 데이터라는 전제입니다.
    SELECT 50 AS TARGET_COUNT,
           34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
           135.35 AS MIN_LON, 135.65 AS MAX_LON
    FROM DUAL
),
FEATURES AS (
    SELECT R.*, P.TARGET_COUNT,
           CASE WHEN TRIM(R.NAME) IS NOT NULL AND LOWER(TRIM(R.NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.NAME)) NOT IN ('이름 없음', 'unnamed')
                  AND TRIM(R.ADDRESS) IS NOT NULL AND LOWER(TRIM(R.ADDRESS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                  AND TRIM(R.OPENING_HOURS) IS NOT NULL AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('off', 'closed')
                THEN 1 ELSE 0 END AS HAS_BASIC,
           CASE WHEN TRIM(R.CATEGORY) IS NOT NULL AND LOWER(TRIM(R.CATEGORY)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.CATEGORY) <> '기타' THEN 1 ELSE 0 END AS HAS_CATEGORY,
           CASE WHEN TRIM(R.PHONE) IS NOT NULL AND LOWER(TRIM(R.PHONE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_PHONE,
           CASE WHEN TRIM(R.WEBSITE_URL) IS NOT NULL AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND (LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%' OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%')
                THEN 1 ELSE 0 END AS HAS_WEBSITE,
           CASE WHEN TRIM(R.DESCRIPTION) IS NOT NULL AND LOWER(TRIM(R.DESCRIPTION)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_DESCRIPTION,
           CASE WHEN TRIM(R.MENU_NAME) IS NOT NULL AND LOWER(TRIM(R.MENU_NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_MENU,
           CASE WHEN TRIM(R.MENU_PRICE) IS NOT NULL AND LOWER(TRIM(R.MENU_PRICE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]') THEN 1 ELSE 0 END AS HAS_PRICE,
           CASE WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MAIN_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MAIN_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MAIN_PHOTO,
           CASE WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MENU_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MENU_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MENU_PHOTO
    FROM RESTAURANT R
    CROSS JOIN CONFIG P
    WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
      AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
),
CLASSIFIED AS (
    SELECT F.*,
           -- 1: 상세정보형 / 2: 기본정보형 / 3: 필수정보 부족
           -- 상세정보형은 대표사진과 메뉴사진 중 임시 주소가 아닌 사진이 하나 이상 필요합니다.
           CASE WHEN HAS_BASIC = 1 AND HAS_CATEGORY = 1
                      AND HAS_DESCRIPTION = 1 AND HAS_MENU = 1 AND HAS_PRICE = 1
                      AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1) THEN 1
                WHEN HAS_BASIC = 1 THEN 2
                ELSE 3 END AS INFO_TIER,
           HAS_PHONE * 2 + HAS_WEBSITE * 2 + HAS_CATEGORY
               + HAS_DESCRIPTION + HAS_MENU + HAS_PRICE
               + HAS_MAIN_PHOTO + HAS_MENU_PHOTO AS INFO_SCORE
    FROM FEATURES F
),
RANKED AS (
    SELECT C.*,
           COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) OVER () AS DETAIL_COUNT,
           COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) OVER () AS BASIC_COUNT,
           ROW_NUMBER() OVER (
               PARTITION BY INFO_TIER
               ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
           ) AS TIER_RANK
    FROM CLASSIFIED C
),
DECISIONS AS (
    SELECT Q.*,
           CASE WHEN INFO_TIER = 1 THEN 'Y'
                WHEN INFO_TIER = 2
                     AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0) THEN 'Y'
                ELSE 'N' END AS NEXT_PUBLISHED
    FROM RANKED Q
)
SELECT COUNT(*) AS AREA_ROWS,
       COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) AS DETAIL_READY,
       COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) AS BASIC_READY,
       COUNT(CASE WHEN INFO_TIER = 3 THEN 1 END) AS MISSING_BASIC,
       COUNT(CASE WHEN NEXT_PUBLISHED = 'Y' THEN 1 END) AS PLANNED_PUBLIC,
       COUNT(CASE WHEN IS_PUBLISHED = 'N' AND NEXT_PUBLISHED = 'Y' THEN 1 END) AS TO_PUBLISH,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' AND NEXT_PUBLISHED = 'N' THEN 1 END) AS TO_HIDE
FROM DECISIONS;

WITH
CONFIG AS (
    -- 전체 오사카시 후보를 대상으로 한 목표 건수입니다.
    -- 아래 좌표 범위는 엉뚱한 도시/0도 좌표를 거르는 근방 검사이며 시 경계 판정이 아닙니다.
    -- 현재 Loader가 오사카시 행정구역에서 수집한 데이터라는 전제입니다.
    SELECT 50 AS TARGET_COUNT,
           34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
           135.35 AS MIN_LON, 135.65 AS MAX_LON
    FROM DUAL
),
FEATURES AS (
    SELECT R.*, P.TARGET_COUNT,
           CASE WHEN TRIM(R.NAME) IS NOT NULL AND LOWER(TRIM(R.NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.NAME)) NOT IN ('이름 없음', 'unnamed')
                  AND TRIM(R.ADDRESS) IS NOT NULL AND LOWER(TRIM(R.ADDRESS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                  AND TRIM(R.OPENING_HOURS) IS NOT NULL AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('off', 'closed')
                THEN 1 ELSE 0 END AS HAS_BASIC,
           CASE WHEN TRIM(R.CATEGORY) IS NOT NULL AND LOWER(TRIM(R.CATEGORY)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.CATEGORY) <> '기타' THEN 1 ELSE 0 END AS HAS_CATEGORY,
           CASE WHEN TRIM(R.PHONE) IS NOT NULL AND LOWER(TRIM(R.PHONE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_PHONE,
           CASE WHEN TRIM(R.WEBSITE_URL) IS NOT NULL AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND (LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%' OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%')
                THEN 1 ELSE 0 END AS HAS_WEBSITE,
           CASE WHEN TRIM(R.DESCRIPTION) IS NOT NULL AND LOWER(TRIM(R.DESCRIPTION)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_DESCRIPTION,
           CASE WHEN TRIM(R.MENU_NAME) IS NOT NULL AND LOWER(TRIM(R.MENU_NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_MENU,
           CASE WHEN TRIM(R.MENU_PRICE) IS NOT NULL AND LOWER(TRIM(R.MENU_PRICE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]') THEN 1 ELSE 0 END AS HAS_PRICE,
           CASE WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MAIN_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MAIN_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MAIN_PHOTO,
           CASE WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MENU_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MENU_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MENU_PHOTO
    FROM RESTAURANT R
    CROSS JOIN CONFIG P
    WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
      AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
),
CLASSIFIED AS (
    SELECT F.*,
           -- 1: 상세정보형 / 2: 기본정보형 / 3: 필수정보 부족
           -- 상세정보형은 대표사진과 메뉴사진 중 임시 주소가 아닌 사진이 하나 이상 필요합니다.
           CASE WHEN HAS_BASIC = 1 AND HAS_CATEGORY = 1
                      AND HAS_DESCRIPTION = 1 AND HAS_MENU = 1 AND HAS_PRICE = 1
                      AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1) THEN 1
                WHEN HAS_BASIC = 1 THEN 2
                ELSE 3 END AS INFO_TIER,
           HAS_PHONE * 2 + HAS_WEBSITE * 2 + HAS_CATEGORY
               + HAS_DESCRIPTION + HAS_MENU + HAS_PRICE
               + HAS_MAIN_PHOTO + HAS_MENU_PHOTO AS INFO_SCORE
    FROM FEATURES F
),
RANKED AS (
    SELECT C.*,
           COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) OVER () AS DETAIL_COUNT,
           COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) OVER () AS BASIC_COUNT,
           ROW_NUMBER() OVER (
               PARTITION BY INFO_TIER
               ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
           ) AS TIER_RANK
    FROM CLASSIFIED C
),
DECISIONS AS (
    SELECT Q.*,
           CASE WHEN INFO_TIER = 1 THEN 'Y'
                WHEN INFO_TIER = 2
                     AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0) THEN 'Y'
                ELSE 'N' END AS NEXT_PUBLISHED
    FROM RANKED Q
)
SELECT RESTAURANT_ID, OSM_ID, NAME,
       CASE INFO_TIER WHEN 1 THEN 'DETAIL' WHEN 2 THEN 'BASIC' ELSE 'INCOMPLETE' END AS INFO_GROUP,
       INFO_SCORE, IS_PUBLISHED AS CURRENT_FLAG, NEXT_PUBLISHED AS NEXT_FLAG,
       CASE WHEN IS_PUBLISHED = NEXT_PUBLISHED THEN 'KEEP'
            WHEN NEXT_PUBLISHED = 'Y' THEN 'PUBLISH' ELSE 'HIDE' END AS CHANGE_TYPE,
       CATEGORY, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, WEBSITE_URL,
       MENU_NAME, MENU_PRICE, MAIN_IMAGE_URL, MENU_IMAGE_URL
FROM DECISIONS
WHERE NEXT_PUBLISHED = 'Y' OR IS_PUBLISHED = 'Y'
ORDER BY NEXT_PUBLISHED DESC, INFO_TIER, TIER_RANK;

DECLARE
    V_MODE VARCHAR2(20) := UPPER(TRIM('&&BINGO_RESTAURANT_MODE'));
BEGIN
    SAVEPOINT BEFORE_OSAKA_SELECTION;
    IF V_MODE = 'PREVIEW' THEN
        DBMS_OUTPUT.PUT_LINE('PREVIEW_ONLY - no publication changes.');
    ELSIF V_MODE = 'APPLY' THEN
        MERGE INTO RESTAURANT TARGET
            USING (
            WITH
            CONFIG AS (
                -- 전체 오사카시 후보를 대상으로 한 목표 건수입니다.
                -- 아래 좌표 범위는 엉뚱한 도시/0도 좌표를 거르는 근방 검사이며 시 경계 판정이 아닙니다.
                -- 현재 Loader가 오사카시 행정구역에서 수집한 데이터라는 전제입니다.
                SELECT 50 AS TARGET_COUNT,
                       34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
                       135.35 AS MIN_LON, 135.65 AS MAX_LON
                FROM DUAL
            ),
            FEATURES AS (
                SELECT R.*, P.TARGET_COUNT,
                       CASE WHEN TRIM(R.NAME) IS NOT NULL AND LOWER(TRIM(R.NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND LOWER(TRIM(R.NAME)) NOT IN ('이름 없음', 'unnamed')
                              AND TRIM(R.ADDRESS) IS NOT NULL AND LOWER(TRIM(R.ADDRESS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                              AND TRIM(R.OPENING_HOURS) IS NOT NULL AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('off', 'closed')
                            THEN 1 ELSE 0 END AS HAS_BASIC,
                       CASE WHEN TRIM(R.CATEGORY) IS NOT NULL AND LOWER(TRIM(R.CATEGORY)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND TRIM(R.CATEGORY) <> '기타' THEN 1 ELSE 0 END AS HAS_CATEGORY,
                       CASE WHEN TRIM(R.PHONE) IS NOT NULL AND LOWER(TRIM(R.PHONE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_PHONE,
                       CASE WHEN TRIM(R.WEBSITE_URL) IS NOT NULL AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND (LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%' OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%')
                            THEN 1 ELSE 0 END AS HAS_WEBSITE,
                       CASE WHEN TRIM(R.DESCRIPTION) IS NOT NULL AND LOWER(TRIM(R.DESCRIPTION)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_DESCRIPTION,
                       CASE WHEN TRIM(R.MENU_NAME) IS NOT NULL AND LOWER(TRIM(R.MENU_NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_MENU,
                       CASE WHEN TRIM(R.MENU_PRICE) IS NOT NULL AND LOWER(TRIM(R.MENU_PRICE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                              AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]') THEN 1 ELSE 0 END AS HAS_PRICE,
                       CASE WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                             AND (TRIM(R.MAIN_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%')
                             AND NOT REGEXP_LIKE(LOWER(R.MAIN_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                            THEN 1 ELSE 0 END AS HAS_MAIN_PHOTO,
                       CASE WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                             AND (TRIM(R.MENU_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%')
                             AND NOT REGEXP_LIKE(LOWER(R.MENU_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                            THEN 1 ELSE 0 END AS HAS_MENU_PHOTO
                FROM RESTAURANT R
                CROSS JOIN CONFIG P
                WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
                  AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
            ),
            CLASSIFIED AS (
                SELECT F.*,
                       -- 1: 상세정보형 / 2: 기본정보형 / 3: 필수정보 부족
                       -- 상세정보형은 대표사진과 메뉴사진 중 임시 주소가 아닌 사진이 하나 이상 필요합니다.
                       CASE WHEN HAS_BASIC = 1 AND HAS_CATEGORY = 1
                                  AND HAS_DESCRIPTION = 1 AND HAS_MENU = 1 AND HAS_PRICE = 1
                                  AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1) THEN 1
                            WHEN HAS_BASIC = 1 THEN 2
                            ELSE 3 END AS INFO_TIER,
                       HAS_PHONE * 2 + HAS_WEBSITE * 2 + HAS_CATEGORY
                           + HAS_DESCRIPTION + HAS_MENU + HAS_PRICE
                           + HAS_MAIN_PHOTO + HAS_MENU_PHOTO AS INFO_SCORE
                FROM FEATURES F
            ),
            RANKED AS (
                SELECT C.*,
                       COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) OVER () AS DETAIL_COUNT,
                       COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) OVER () AS BASIC_COUNT,
                       ROW_NUMBER() OVER (
                           PARTITION BY INFO_TIER
                           ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
                       ) AS TIER_RANK
                FROM CLASSIFIED C
            ),
            DECISIONS AS (
                SELECT Q.*,
                       CASE WHEN INFO_TIER = 1 THEN 'Y'
                            WHEN INFO_TIER = 2
                                 AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0) THEN 'Y'
                            ELSE 'N' END AS NEXT_PUBLISHED
                FROM RANKED Q
            )
                SELECT RESTAURANT_ID, NEXT_PUBLISHED FROM DECISIONS
            ) CHOSEN
            ON (TARGET.RESTAURANT_ID = CHOSEN.RESTAURANT_ID)
            WHEN MATCHED THEN UPDATE SET
                TARGET.IS_PUBLISHED = CHOSEN.NEXT_PUBLISHED,
                TARGET.UPDATED_AT = SYSTIMESTAMP
            WHERE TARGET.IS_PUBLISHED <> CHOSEN.NEXT_PUBLISHED;
        DBMS_OUTPUT.PUT_LINE('CHANGED_ROWS=' || SQL%ROWCOUNT);
        DBMS_OUTPUT.PUT_LINE('Review results, then execute COMMIT or ROLLBACK in this connection.');
    ELSE
        RAISE_APPLICATION_ERROR(-20020, 'Use PREVIEW or APPLY only.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO BEFORE_OSAKA_SELECTION;
        RAISE;
END;
/

PROMPT ===== CURRENT RESULT / REMAINING CHANGES =====
WITH
CONFIG AS (
    -- 전체 오사카시 후보를 대상으로 한 목표 건수입니다.
    -- 아래 좌표 범위는 엉뚱한 도시/0도 좌표를 거르는 근방 검사이며 시 경계 판정이 아닙니다.
    -- 현재 Loader가 오사카시 행정구역에서 수집한 데이터라는 전제입니다.
    SELECT 50 AS TARGET_COUNT,
           34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
           135.35 AS MIN_LON, 135.65 AS MAX_LON
    FROM DUAL
),
FEATURES AS (
    SELECT R.*, P.TARGET_COUNT,
           CASE WHEN TRIM(R.NAME) IS NOT NULL AND LOWER(TRIM(R.NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.NAME)) NOT IN ('이름 없음', 'unnamed')
                  AND TRIM(R.ADDRESS) IS NOT NULL AND LOWER(TRIM(R.ADDRESS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                  AND TRIM(R.OPENING_HOURS) IS NOT NULL AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN ('off', 'closed')
                THEN 1 ELSE 0 END AS HAS_BASIC,
           CASE WHEN TRIM(R.CATEGORY) IS NOT NULL AND LOWER(TRIM(R.CATEGORY)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND TRIM(R.CATEGORY) <> '기타' THEN 1 ELSE 0 END AS HAS_CATEGORY,
           CASE WHEN TRIM(R.PHONE) IS NOT NULL AND LOWER(TRIM(R.PHONE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_PHONE,
           CASE WHEN TRIM(R.WEBSITE_URL) IS NOT NULL AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND (LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%' OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%')
                THEN 1 ELSE 0 END AS HAS_WEBSITE,
           CASE WHEN TRIM(R.DESCRIPTION) IS NOT NULL AND LOWER(TRIM(R.DESCRIPTION)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_DESCRIPTION,
           CASE WHEN TRIM(R.MENU_NAME) IS NOT NULL AND LOWER(TRIM(R.MENU_NAME)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요') THEN 1 ELSE 0 END AS HAS_MENU,
           CASE WHEN TRIM(R.MENU_PRICE) IS NOT NULL AND LOWER(TRIM(R.MENU_PRICE)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                  AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]') THEN 1 ELSE 0 END AS HAS_PRICE,
           CASE WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MAIN_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MAIN_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MAIN_PHOTO,
           CASE WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음', '미등록', '확인 필요')
                 AND (TRIM(R.MENU_IMAGE_URL) LIKE '/%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%' OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%')
                 AND NOT REGEXP_LIKE(LOWER(R.MENU_IMAGE_URL), 'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image')
                THEN 1 ELSE 0 END AS HAS_MENU_PHOTO
    FROM RESTAURANT R
    CROSS JOIN CONFIG P
    WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
      AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
),
CLASSIFIED AS (
    SELECT F.*,
           -- 1: 상세정보형 / 2: 기본정보형 / 3: 필수정보 부족
           -- 상세정보형은 대표사진과 메뉴사진 중 임시 주소가 아닌 사진이 하나 이상 필요합니다.
           CASE WHEN HAS_BASIC = 1 AND HAS_CATEGORY = 1
                      AND HAS_DESCRIPTION = 1 AND HAS_MENU = 1 AND HAS_PRICE = 1
                      AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1) THEN 1
                WHEN HAS_BASIC = 1 THEN 2
                ELSE 3 END AS INFO_TIER,
           HAS_PHONE * 2 + HAS_WEBSITE * 2 + HAS_CATEGORY
               + HAS_DESCRIPTION + HAS_MENU + HAS_PRICE
               + HAS_MAIN_PHOTO + HAS_MENU_PHOTO AS INFO_SCORE
    FROM FEATURES F
),
RANKED AS (
    SELECT C.*,
           COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) OVER () AS DETAIL_COUNT,
           COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) OVER () AS BASIC_COUNT,
           ROW_NUMBER() OVER (
               PARTITION BY INFO_TIER
               ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
           ) AS TIER_RANK
    FROM CLASSIFIED C
),
DECISIONS AS (
    SELECT Q.*,
           CASE WHEN INFO_TIER = 1 THEN 'Y'
                WHEN INFO_TIER = 2
                     AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0) THEN 'Y'
                ELSE 'N' END AS NEXT_PUBLISHED
    FROM RANKED Q
)
SELECT COUNT(*) AS AREA_ROWS,
       COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END) AS DETAIL_READY,
       COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END) AS BASIC_READY,
       COUNT(CASE WHEN INFO_TIER = 3 THEN 1 END) AS MISSING_BASIC,
       COUNT(CASE WHEN NEXT_PUBLISHED = 'Y' THEN 1 END) AS PLANNED_PUBLIC,
       COUNT(CASE WHEN IS_PUBLISHED = 'N' AND NEXT_PUBLISHED = 'Y' THEN 1 END) AS TO_PUBLISH,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' AND NEXT_PUBLISHED = 'N' THEN 1 END) AS TO_HIDE
FROM DECISIONS;

SELECT COUNT(*) AS TOTAL_ROWS,
       COUNT(OSM_ID) AS OSM_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' THEN 1 END) AS ALL_PUBLIC_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' AND
           (LATITUDE IS NULL OR LONGITUDE IS NULL OR
            LATITUDE NOT BETWEEN 34.55 AND 34.82 OR LONGITUDE NOT BETWEEN 135.35 AND 135.65)
           THEN 1 END) AS OUTSIDE_OR_INVALID_PUBLIC
FROM RESTAURANT;

SELECT RESTAURANT_ID, OSM_ID, NAME, ADDRESS, OPENING_HOURS,
       MENU_NAME, MENU_PRICE, MAIN_IMAGE_URL, IS_PUBLISHED
FROM RESTAURANT
WHERE IS_PUBLISHED = 'Y'
ORDER BY RESTAURANT_ID;

-- APPLY 실행 후: ORA- 오류가 없고 결과가 맞으면 같은 접속에서 COMMIT; 을 별도로 실행하세요.
-- 취소하려면 COMMIT 전에 ROLLBACK; 을 실행하세요. 이 파일은 자동 COMMIT하지 않습니다.
-- PREVIEW에서는 TO_PUBLISH/TO_HIDE가 변경 예정 수이고, APPLY 성공 후에는 둘 다 0이어야 합니다.
-- 검토 후 파일의 실행 모드는 PREVIEW로 되돌려 저장하면 다음에도 미리보기로 시작합니다.
UNDEFINE BINGO_RESTAURANT_MODE
SET VERIFY ON
