-- BinGo Map / OSM 식당 25개 리뷰 테스트 데이터
-- 목적:
--   1) 팀원이 선정한 25개 실제 식당명을 현재 restaurants(OSM) 데이터와 매칭
--   2) 매칭된 restaurant_id에만 테스트 리뷰 1개씩 생성
--   3) 기존 OSM 식당/공개 상태/지도 데이터를 삭제하거나 덮어쓰지 않음
--
-- 중요:
--   - PREVIEW가 기본입니다. 먼저 전체 F5로 매칭 결과를 확인하세요.
--   - 정확히 25개가 MATCHED 된 것을 확인한 뒤 APPLY로 바꾸고 다시 전체 F5 하세요.
--   - APPLY 후 같은 접속에서 COMMIT; 을 별도로 실행해야 앱에서 보입니다.
--   - 이 파일이 만드는 리뷰는 화면 연결 확인용 테스트 데이터이며 실제 사용자 리뷰가 아닙니다.
--   - 반복 실행해도 [BinGo TEST REVIEW 25] 접두어가 붙은 기존 테스트 리뷰만 교체합니다.
--   - restaurants 행 자체는 생성/삭제/수정하지 않습니다.

SET SERVEROUTPUT ON
SET DEFINE ON
SET VERIFY OFF
DEFINE BINGO_REVIEW_MODE = PREVIEW

PROMPT ===== REVIEW 25 OSM MATCH PLAN =====

WITH
TARGETS(seq_no, requested_name, alt_name, address_key, target_lat, target_lon) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM DUAL UNION ALL
    SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM DUAL UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM DUAL UNION ALL
    SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM DUAL UNION ALL
    SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM DUAL UNION ALL
    SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM DUAL UNION ALL
    SELECT  7, 'ギャムドカフェ', NULL, '2-8', NULL, NULL FROM DUAL UNION ALL
    SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM DUAL UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM DUAL UNION ALL
    SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM DUAL UNION ALL
    SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM DUAL UNION ALL
    SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM DUAL UNION ALL
    SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM DUAL UNION ALL
    SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM DUAL UNION ALL
    SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM DUAL UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM DUAL UNION ALL
    SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM DUAL UNION ALL
    SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM DUAL UNION ALL
    SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM DUAL UNION ALL
    SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM DUAL UNION ALL
    SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM DUAL UNION ALL
    SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM DUAL UNION ALL
    SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM DUAL UNION ALL
    SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM DUAL UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM DUAL
),
CANDIDATES AS (
    SELECT
        T.seq_no,
        T.requested_name,
        R.restaurant_id,
        R.osm_id,
        R.name AS matched_name,
        R.address AS matched_address,
        R.is_published,
        R.latitude,
        R.longitude,
        CASE
            WHEN UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name))
                THEN 1200
            WHEN T.alt_name IS NOT NULL
                 AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                 AND T.target_lat IS NOT NULL
                 AND T.target_lon IS NOT NULL
                 AND R.latitude IS NOT NULL
                 AND R.longitude IS NOT NULL
                 AND (
                     POWER(R.latitude - T.target_lat, 2)
                     + POWER(
                         (R.longitude - T.target_lon)
                         * COS(T.target_lat * ACOS(-1) / 180),
                         2
                       )
                 ) <= POWER(0.0015, 2)
                THEN 1100
            WHEN T.address_key IS NOT NULL
                 AND INSTR(
                     REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                     REPLACE(UPPER(T.address_key), ' ', '')
                 ) > 0
                THEN 1050
            WHEN T.target_lat IS NOT NULL
                 AND T.target_lon IS NOT NULL
                 AND R.latitude IS NOT NULL
                 AND R.longitude IS NOT NULL
                 AND (
                     POWER(R.latitude - T.target_lat, 2)
                     + POWER(
                         (R.longitude - T.target_lon)
                         * COS(T.target_lat * ACOS(-1) / 180),
                         2
                       )
                 ) <= POWER(0.001, 2)
                THEN 1000
            WHEN T.alt_name IS NOT NULL
                 AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                THEN 800
            ELSE 0
        END AS match_score,
        CASE
            WHEN T.target_lat IS NOT NULL
                 AND T.target_lon IS NOT NULL
                 AND R.latitude IS NOT NULL
                 AND R.longitude IS NOT NULL
                THEN POWER(R.latitude - T.target_lat, 2)
                     + POWER(
                         (R.longitude - T.target_lon)
                         * COS(T.target_lat * ACOS(-1) / 180),
                         2
                       )
            ELSE 999999999
        END AS distance_key
    FROM TARGETS T
    LEFT JOIN restaurants R
      ON (
          UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name))
          OR (
              T.alt_name IS NOT NULL
              AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
          )
          OR (
              T.address_key IS NOT NULL
              AND INSTR(
                  REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                  REPLACE(UPPER(T.address_key), ' ', '')
              ) > 0
          )
          OR (
              T.target_lat IS NOT NULL
              AND T.target_lon IS NOT NULL
              AND R.latitude IS NOT NULL
              AND R.longitude IS NOT NULL
              AND (
                  POWER(R.latitude - T.target_lat, 2)
                  + POWER(
                      (R.longitude - T.target_lon)
                      * COS(T.target_lat * ACOS(-1) / 180),
                      2
                    )
              ) <= POWER(0.001, 2)
          )
      )
),
RANKED AS (
    SELECT
        C.*,
        ROW_NUMBER() OVER (
            PARTITION BY C.seq_no
            ORDER BY C.match_score DESC,
                     C.distance_key ASC,
                     C.restaurant_id ASC
        ) AS rn
    FROM CANDIDATES C
)
SELECT
    T.seq_no,
    T.requested_name,
    R.restaurant_id,
    R.osm_id,
    R.matched_name,
    R.matched_address,
    R.is_published,
    R.match_score,
    CASE
        WHEN R.restaurant_id IS NULL THEN 'UNMATCHED'
        ELSE 'MATCHED'
    END AS match_status
FROM TARGETS T
LEFT JOIN RANKED R
  ON R.seq_no = T.seq_no
 AND R.rn = 1
ORDER BY T.seq_no;

PROMPT ===== SUMMARY =====

WITH
TARGETS(seq_no, requested_name, alt_name, address_key, target_lat, target_lon) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM DUAL UNION ALL
    SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM DUAL UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM DUAL UNION ALL
    SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM DUAL UNION ALL
    SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM DUAL UNION ALL
    SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM DUAL UNION ALL
    SELECT  7, 'ギャムドカフェ', NULL, '2-8', NULL, NULL FROM DUAL UNION ALL
    SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM DUAL UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM DUAL UNION ALL
    SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM DUAL UNION ALL
    SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM DUAL UNION ALL
    SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM DUAL UNION ALL
    SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM DUAL UNION ALL
    SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM DUAL UNION ALL
    SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM DUAL UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM DUAL UNION ALL
    SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM DUAL UNION ALL
    SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM DUAL UNION ALL
    SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM DUAL UNION ALL
    SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM DUAL UNION ALL
    SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM DUAL UNION ALL
    SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM DUAL UNION ALL
    SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM DUAL UNION ALL
    SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM DUAL UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM DUAL
),
MATCHED AS (
    SELECT
        T.seq_no,
        T.requested_name,
        R.restaurant_id,
        R.matched_name,
        R.match_score,
        ROW_NUMBER() OVER (
            PARTITION BY T.seq_no
            ORDER BY R.match_score DESC, R.distance_key ASC, R.restaurant_id ASC
        ) AS rn
    FROM TARGETS T
    JOIN (
        SELECT *
        FROM (
            SELECT C.*,
                   ROW_NUMBER() OVER (
                       PARTITION BY C.seq_no
                       ORDER BY C.match_score DESC, C.distance_key ASC, C.restaurant_id ASC
                   ) AS inner_rn
            FROM (
                SELECT
                    T2.seq_no,
                    R2.restaurant_id,
                    R2.name AS matched_name,
                    CASE
                        WHEN UPPER(TRIM(R2.name)) = UPPER(TRIM(T2.requested_name)) THEN 1200
                        WHEN T2.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R2.name, '')), LOWER(T2.alt_name)) > 0
                             AND T2.target_lat IS NOT NULL
                             AND T2.target_lon IS NOT NULL
                             AND R2.latitude IS NOT NULL
                             AND R2.longitude IS NOT NULL
                             AND (
                                 POWER(R2.latitude - T2.target_lat, 2)
                                 + POWER(
                                     (R2.longitude - T2.target_lon)
                                     * COS(T2.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.0015, 2)
                            THEN 1100
                        WHEN T2.address_key IS NOT NULL
                             AND INSTR(
                                 REPLACE(UPPER(NVL(R2.address, '')), ' ', ''),
                                 REPLACE(UPPER(T2.address_key), ' ', '')
                             ) > 0 THEN 1050
                        WHEN T2.target_lat IS NOT NULL
                             AND T2.target_lon IS NOT NULL
                             AND R2.latitude IS NOT NULL
                             AND R2.longitude IS NOT NULL
                             AND (
                                 POWER(R2.latitude - T2.target_lat, 2)
                                 + POWER(
                                     (R2.longitude - T2.target_lon)
                                     * COS(T2.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.001, 2)
                            THEN 1000
                        WHEN T2.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R2.name, '')), LOWER(T2.alt_name)) > 0
                            THEN 800
                        ELSE 0
                    END AS match_score,
                    CASE
                        WHEN T2.target_lat IS NOT NULL
                             AND T2.target_lon IS NOT NULL
                             AND R2.latitude IS NOT NULL
                             AND R2.longitude IS NOT NULL
                            THEN POWER(R2.latitude - T2.target_lat, 2)
                                 + POWER(
                                     (R2.longitude - T2.target_lon)
                                     * COS(T2.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                        ELSE 999999999
                    END AS distance_key
                FROM TARGETS T2
                JOIN restaurants R2
                  ON (
                      UPPER(TRIM(R2.name)) = UPPER(TRIM(T2.requested_name))
                      OR (
                          T2.alt_name IS NOT NULL
                          AND INSTR(LOWER(NVL(R2.name, '')), LOWER(T2.alt_name)) > 0
                      )
                      OR (
                          T2.address_key IS NOT NULL
                          AND INSTR(
                              REPLACE(UPPER(NVL(R2.address, '')), ' ', ''),
                              REPLACE(UPPER(T2.address_key), ' ', '')
                          ) > 0
                      )
                      OR (
                          T2.target_lat IS NOT NULL
                          AND T2.target_lon IS NOT NULL
                          AND R2.latitude IS NOT NULL
                          AND R2.longitude IS NOT NULL
                          AND (
                              POWER(R2.latitude - T2.target_lat, 2)
                              + POWER(
                                  (R2.longitude - T2.target_lon)
                                  * COS(T2.target_lat * ACOS(-1) / 180),
                                  2
                                )
                          ) <= POWER(0.001, 2)
                      )
                  )
            ) C
        )
        WHERE inner_rn = 1
    ) R
      ON R.seq_no = T.seq_no
),
UNMATCHED AS (
    SELECT T.seq_no
    FROM TARGETS T
    MINUS
    SELECT M.seq_no
    FROM MATCHED M
)
SELECT
    25 AS TARGET_COUNT,
    (SELECT COUNT(*) FROM MATCHED) AS MATCHED_COUNT,
    (SELECT COUNT(*) FROM UNMATCHED) AS UNMATCHED_COUNT
FROM DUAL;

DECLARE
    v_mode VARCHAR2(20) := UPPER(TRIM('&&BINGO_REVIEW_MODE'));
BEGIN
    IF v_mode = 'PREVIEW' THEN
        DBMS_OUTPUT.PUT_LINE('PREVIEW_ONLY - no review rows changed.');
    ELSIF v_mode = 'APPLY' THEN

        DECLARE
            v_user_id NUMBER;
            v_match_count NUMBER;
        BEGIN
            SELECT MIN(id)
              INTO v_user_id
              FROM users;

            IF v_user_id IS NULL THEN
                RAISE_APPLICATION_ERROR(
                    -20101,
                    'users 테이블에 사용할 사용자가 없습니다.'
                );
            END IF;

            -- 아래 매칭 결과가 25개가 아니면 아무 것도 쓰지 않고 중단합니다.
            WITH
            TARGETS(seq_no, requested_name, alt_name, address_key, target_lat, target_lon) AS (
                SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM DUAL UNION ALL
                SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM DUAL UNION ALL
                SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM DUAL UNION ALL
                SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM DUAL UNION ALL
                SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM DUAL UNION ALL
                SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM DUAL UNION ALL
                SELECT  7, 'ギャムドカフェ', NULL, '2-8', NULL, NULL FROM DUAL UNION ALL
                SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM DUAL UNION ALL
                SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM DUAL UNION ALL
                SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM DUAL UNION ALL
                SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM DUAL UNION ALL
                SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM DUAL UNION ALL
                SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM DUAL UNION ALL
                SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM DUAL UNION ALL
                SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM DUAL UNION ALL
                SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM DUAL UNION ALL
                SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM DUAL UNION ALL
                SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM DUAL UNION ALL
                SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM DUAL UNION ALL
                SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM DUAL UNION ALL
                SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM DUAL UNION ALL
                SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM DUAL UNION ALL
                SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM DUAL UNION ALL
                SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM DUAL UNION ALL
                SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM DUAL
            ),
            CANDIDATES AS (
                SELECT
                    T.*,
                    R.restaurant_id,
                    CASE
                        WHEN UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name)) THEN 1200
                        WHEN T.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                             AND T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                             AND (
                                 POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.0015, 2)
                            THEN 1100
                        WHEN T.address_key IS NOT NULL
                             AND INSTR(
                                 REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                                 REPLACE(UPPER(T.address_key), ' ', '')
                             ) > 0 THEN 1050
                        WHEN T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                             AND (
                                 POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.001, 2)
                            THEN 1000
                        WHEN T.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                            THEN 800
                        ELSE 0
                    END AS match_score,
                    CASE
                        WHEN T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                            THEN POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                        ELSE 999999999
                    END AS distance_key
                FROM TARGETS T
                LEFT JOIN restaurants R
                  ON (
                      UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name))
                      OR (
                          T.alt_name IS NOT NULL
                          AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                      )
                      OR (
                          T.address_key IS NOT NULL
                          AND INSTR(
                              REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                              REPLACE(UPPER(T.address_key), ' ', '')
                          ) > 0
                      )
                      OR (
                          T.target_lat IS NOT NULL
                          AND T.target_lon IS NOT NULL
                          AND R.latitude IS NOT NULL
                          AND R.longitude IS NOT NULL
                          AND (
                              POWER(R.latitude - T.target_lat, 2)
                              + POWER(
                                  (R.longitude - T.target_lon)
                                  * COS(T.target_lat * ACOS(-1) / 180),
                                  2
                                )
                          ) <= POWER(0.001, 2)
                      )
                  )
            ),
            RANKED AS (
                SELECT C.*,
                       ROW_NUMBER() OVER (
                           PARTITION BY C.seq_no
                           ORDER BY C.match_score DESC,
                                    C.distance_key ASC,
                                    C.restaurant_id ASC
                       ) AS rn
                FROM CANDIDATES C
            ),
            MATCHED AS (
                SELECT *
                FROM RANKED
                WHERE rn = 1
                  AND restaurant_id IS NOT NULL
                  AND match_score > 0
            )
            SELECT COUNT(*)
              INTO v_match_count
              FROM MATCHED;

            IF v_match_count <> 25 THEN
                RAISE_APPLICATION_ERROR(
                    -20102,
                    '25개 중 OSM 매칭이 ' || v_match_count || '개입니다. PREVIEW 결과에서 미매칭 식당을 먼저 확인하세요.'
                );
            END IF;

            SAVEPOINT BEFORE_REVIEW_25;

            DELETE FROM reviews
             WHERE target_type = 'RESTAURANT'
               AND content LIKE '[BinGo TEST REVIEW 25]%';

            WITH
            TARGETS(seq_no, requested_name, alt_name, address_key, target_lat, target_lon) AS (
                SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM DUAL UNION ALL
                SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM DUAL UNION ALL
                SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM DUAL UNION ALL
                SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM DUAL UNION ALL
                SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM DUAL UNION ALL
                SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM DUAL UNION ALL
                SELECT  7, 'ギャムドカ페', NULL, '2-8', NULL, NULL FROM DUAL UNION ALL
                SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM DUAL UNION ALL
                SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM DUAL UNION ALL
                SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM DUAL UNION ALL
                SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM DUAL UNION ALL
                SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM DUAL UNION ALL
                SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM DUAL UNION ALL
                SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM DUAL UNION ALL
                SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM DUAL UNION ALL
                SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM DUAL UNION ALL
                SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM DUAL UNION ALL
                SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM DUAL UNION ALL
                SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM DUAL UNION ALL
                SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM DUAL UNION ALL
                SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM DUAL UNION ALL
                SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM DUAL UNION ALL
                SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM DUAL UNION ALL
                SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM DUAL UNION ALL
                SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM DUAL
            ),
            CANDIDATES AS (
                SELECT
                    T.*,
                    R.restaurant_id,
                    R.name AS matched_name,
                    CASE
                        WHEN UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name)) THEN 1200
                        WHEN T.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                             AND T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                             AND (
                                 POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.0015, 2)
                            THEN 1100
                        WHEN T.address_key IS NOT NULL
                             AND INSTR(
                                 REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                                 REPLACE(UPPER(T.address_key), ' ', '')
                             ) > 0 THEN 1050
                        WHEN T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                             AND (
                                 POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                             ) <= POWER(0.001, 2)
                            THEN 1000
                        WHEN T.alt_name IS NOT NULL
                             AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                            THEN 800
                        ELSE 0
                    END AS match_score,
                    CASE
                        WHEN T.target_lat IS NOT NULL
                             AND T.target_lon IS NOT NULL
                             AND R.latitude IS NOT NULL
                             AND R.longitude IS NOT NULL
                            THEN POWER(R.latitude - T.target_lat, 2)
                                 + POWER(
                                     (R.longitude - T.target_lon)
                                     * COS(T.target_lat * ACOS(-1) / 180),
                                     2
                                   )
                        ELSE 999999999
                    END AS distance_key
                FROM TARGETS T
                LEFT JOIN restaurants R
                  ON (
                      UPPER(TRIM(R.name)) = UPPER(TRIM(T.requested_name))
                      OR (
                          T.alt_name IS NOT NULL
                          AND INSTR(LOWER(NVL(R.name, '')), LOWER(T.alt_name)) > 0
                      )
                      OR (
                          T.address_key IS NOT NULL
                          AND INSTR(
                              REPLACE(UPPER(NVL(R.address, '')), ' ', ''),
                              REPLACE(UPPER(T.address_key), ' ', '')
                          ) > 0
                      )
                      OR (
                          T.target_lat IS NOT NULL
                          AND T.target_lon IS NOT NULL
                          AND R.latitude IS NOT NULL
                          AND R.longitude IS NOT NULL
                          AND (
                              POWER(R.latitude - T.target_lat, 2)
                              + POWER(
                                  (R.longitude - T.target_lon)
                                  * COS(T.target_lat * ACOS(-1) / 180),
                                  2
                                )
                          ) <= POWER(0.001, 2)
                      )
                  )
            ),
            RANKED AS (
                SELECT C.*,
                       ROW_NUMBER() OVER (
                           PARTITION BY C.seq_no
                           ORDER BY C.match_score DESC,
                                    C.distance_key ASC,
                                    C.restaurant_id ASC
                       ) AS rn
                FROM CANDIDATES C
            ),
            MATCHED AS (
                SELECT *
                FROM RANKED
                WHERE rn = 1
                  AND restaurant_id IS NOT NULL
                  AND match_score > 0
            )
            INSERT INTO reviews (
                id,
                user_id,
                target_type,
                target_id,
                rating,
                content,
                visit_date,
                visit_time_slot,
                visit_purpose,
                recommend_yn,
                help_count,
                created_at,
                updated_at
            )
            SELECT
                SEQ_REVIEW.NEXTVAL,
                v_user_id,
                'RESTAURANT',
                TO_CHAR(restaurant_id),
                4.0,
                '[BinGo TEST REVIEW 25] ' || requested_name || ' - OSM 식당 연결 확인용 테스트 리뷰입니다.',
                TRUNC(SYSDATE) - MOD(seq_no, 7),
                CASE MOD(seq_no, 3)
                    WHEN 0 THEN 'DINNER'
                    WHEN 1 THEN 'LUNCH'
                    ELSE 'AFTERNOON'
                END,
                'TRAVEL',
                1,
                0,
                SYSTIMESTAMP,
                SYSTIMESTAMP
            FROM MATCHED;

            DBMS_OUTPUT.PUT_LINE('APPLY_OK - TEST REVIEW 25 inserted.');
            DBMS_OUTPUT.PUT_LINE('INSERTED_ROWS=' || SQL%ROWCOUNT);
            DBMS_OUTPUT.PUT_LINE('Review the result and execute COMMIT; in this connection.');
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO BEFORE_REVIEW_25;
                RAISE;
        END;
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'Use PREVIEW or APPLY only.');
    END IF;
END;
/

PROMPT ===== CURRENT TEST REVIEW COUNT =====
SELECT COUNT(*) AS TEST_REVIEW_COUNT
FROM reviews
WHERE target_type = 'RESTAURANT'
  AND content LIKE '[BinGo TEST REVIEW 25]%';

SELECT
    r.review_id AS REVIEW_ID,
    r.target_id,
    r.rating,
    r.content,
    r.created_at
FROM (
    SELECT
        rv.id AS review_id,
        rv.target_id,
        rv.rating,
        rv.content,
        rv.created_at,
        ROW_NUMBER() OVER (ORDER BY rv.id DESC) AS rn
    FROM reviews rv
    WHERE rv.target_type = 'RESTAURANT'
      AND rv.content LIKE '[BinGo TEST REVIEW 25]%'
) r
WHERE r.rn <= 25
ORDER BY r.review_id;

UNDEFINE BINGO_REVIEW_MODE
SET VERIFY ON
