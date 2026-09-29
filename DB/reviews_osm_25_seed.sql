-- BinGo Map / OSM 식당 25개 리뷰 연결 - 1단계 매칭 확인용
-- 현재 최종 DB 구조 기준:
--   restaurants (restaurant_id, osm_id, ...)
--   reviews (id, user_id, target_type, target_id, ...)
--   users
--
-- 주의:
--   이 파일은 지금은 조회만 합니다.
--   restaurants / reviews / review_image / restaurant_menu를 삭제하거나 수정하지 않습니다.
--   팀원의 TB_* / RESTAURANT 구조를 사용하지 않습니다.
--
-- 목표:
--   팀원이 선정한 25개 식당명을 현재 OSM restaurants와 매칭할 후보를 확인합니다.
--   25개가 정확히 무엇으로 연결되는지 확인한 뒤, 다음 단계에서 reviews INSERT를 진행합니다.

SET SERVEROUTPUT ON
SET DEFINE OFF

PROMPT ============================================================
PROMPT REVIEW 25 - OSM MATCH PREVIEW
PROMPT ============================================================

WITH TARGETS (
    seq_no,
    requested_name,
    alt_name,
    address_key,
    target_lat,
    target_lon
) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM dual UNION ALL
    SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM dual UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM dual UNION ALL
    SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM dual UNION ALL
    SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM dual UNION ALL
    SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM dual UNION ALL
    SELECT  7, 'ギャムドカフェ', NULL, '2-8', NULL, NULL FROM dual UNION ALL
    SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM dual UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM dual UNION ALL
    SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM dual UNION ALL
    SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM dual UNION ALL
    SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM dual UNION ALL
    SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM dual UNION ALL
    SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM dual UNION ALL
    SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM dual UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM dual UNION ALL
    SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM dual UNION ALL
    SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM dual UNION ALL
    SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM dual UNION ALL
    SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM dual UNION ALL
    SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM dual UNION ALL
    SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM dual UNION ALL
    SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM dual UNION ALL
    SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM dual UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM dual
),
CANDIDATES AS (
    SELECT
        t.seq_no,
        t.requested_name,
        r.restaurant_id,
        r.osm_id,
        r.name AS matched_name,
        r.address AS matched_address,
        r.latitude,
        r.longitude,
        r.is_published,
        CASE
            WHEN UPPER(TRIM(r.name)) = UPPER(TRIM(t.requested_name))
                THEN 1000
            WHEN t.alt_name IS NOT NULL
                 AND INSTR(LOWER(NVL(r.name, '')), LOWER(t.alt_name)) > 0
                 AND t.target_lat IS NOT NULL
                 AND t.target_lon IS NOT NULL
                 AND r.latitude IS NOT NULL
                 AND r.longitude IS NOT NULL
                 AND (
                     POWER(r.latitude - t.target_lat, 2)
                     + POWER(
                         (r.longitude - t.target_lon)
                         * COS(t.target_lat * ACOS(-1) / 180),
                         2
                       )
                 ) <= POWER(0.002, 2)
                THEN 900
            WHEN t.target_lat IS NOT NULL
                 AND t.target_lon IS NOT NULL
                 AND r.latitude IS NOT NULL
                 AND r.longitude IS NOT NULL
                 AND (
                     POWER(r.latitude - t.target_lat, 2)
                     + POWER(
                         (r.longitude - t.target_lon)
                         * COS(t.target_lat * ACOS(-1) / 180),
                         2
                       )
                 ) <= POWER(0.0015, 2)
                THEN 800
            WHEN t.alt_name IS NOT NULL
                 AND INSTR(LOWER(NVL(r.name, '')), LOWER(t.alt_name)) > 0
                THEN 700
            WHEN t.address_key IS NOT NULL
                 AND INSTR(
                     REPLACE(UPPER(NVL(r.address, '')), ' ', ''),
                     REPLACE(UPPER(t.address_key), ' ', '')
                 ) > 0
                THEN 600
            ELSE 0
        END AS match_score,
        CASE
            WHEN t.target_lat IS NOT NULL
                 AND t.target_lon IS NOT NULL
                 AND r.latitude IS NOT NULL
                 AND r.longitude IS NOT NULL
                THEN
                    POWER(r.latitude - t.target_lat, 2)
                    + POWER(
                        (r.longitude - t.target_lon)
                        * COS(t.target_lat * ACOS(-1) / 180),
                        2
                      )
            ELSE 999999999
        END AS distance_key
    FROM TARGETS t
    LEFT JOIN restaurants r
      ON (
          UPPER(TRIM(r.name)) = UPPER(TRIM(t.requested_name))
          OR (
              t.alt_name IS NOT NULL
              AND INSTR(LOWER(NVL(r.name, '')), LOWER(t.alt_name)) > 0
          )
          OR (
              t.target_lat IS NOT NULL
              AND t.target_lon IS NOT NULL
              AND r.latitude IS NOT NULL
              AND r.longitude IS NOT NULL
              AND (
                  POWER(r.latitude - t.target_lat, 2)
                  + POWER(
                      (r.longitude - t.target_lon)
                      * COS(t.target_lat * ACOS(-1) / 180),
                      2
                    )
              ) <= POWER(0.0015, 2)
          )
          OR (
              t.address_key IS NOT NULL
              AND INSTR(
                  REPLACE(UPPER(NVL(r.address, '')), ' ', ''),
                  REPLACE(UPPER(t.address_key), ' ', '')
              ) > 0
          )
      )
),
RANKED AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY c.seq_no
            ORDER BY c.match_score DESC,
                     c.distance_key ASC,
                     c.restaurant_id ASC
        ) AS rn
    FROM CANDIDATES c
)
SELECT
    seq_no,
    requested_name,
    restaurant_id,
    osm_id,
    matched_name,
    matched_address,
    latitude,
    longitude,
    is_published,
    match_score,
    CASE
        WHEN restaurant_id IS NULL THEN 'UNMATCHED'
        WHEN match_score >= 800 THEN 'MATCHED_STRONG'
        WHEN match_score >= 600 THEN 'MATCHED_WEAK'
        ELSE 'UNMATCHED'
    END AS match_status
FROM RANKED
WHERE rn = 1
ORDER BY seq_no;

PROMPT ============================================================
PROMPT SUMMARY
PROMPT ============================================================

WITH TARGETS (seq_no, requested_name, alt_name, address_key, target_lat, target_lon) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점', 'くくる', '1-10-5', 34.668729, 135.501294 FROM dual UNION ALL
    SELECT  2, '야끼소바 산페이', '三平', '1-7-9', 34.668900, 135.502100 FROM dual UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', '千房', '1-5-5', 34.668500, 135.503200 FROM dual UNION ALL
    SELECT  4, '도톤보리 타이야끼', 'たい焼き', '1-8-22', 34.668350, 135.500800 FROM dual UNION ALL
    SELECT  5, '카라아게 타로', 'からあげ', '2-2-1', 34.667800, 135.500200 FROM dual UNION ALL
    SELECT  6, 'エミュリボン', NULL, '2-13-5', NULL, NULL FROM dual UNION ALL
    SELECT  7, 'ギャムドカフェ', NULL, '2-8', NULL, NULL FROM dual UNION ALL
    SELECT  8, 'ポケモンカフェ', NULL, '3-1-1', NULL, NULL FROM dual UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', NULL, '21-30-1F', NULL, NULL FROM dual UNION ALL
    SELECT 10, '癒ロイド', NULL, '2-4-8', NULL, NULL FROM dual UNION ALL
    SELECT 11, '靭本町がく', NULL, '14-15', NULL, NULL FROM dual UNION ALL
    SELECT 12, 'ノンシャラマンカフェ', NULL, '4-14', NULL, NULL FROM dual UNION ALL
    SELECT 13, '蜜家珈琲店', NULL, '1-6-1', NULL, NULL FROM dual UNION ALL
    SELECT 14, '梨花食堂', NULL, '8-15', NULL, NULL FROM dual UNION ALL
    SELECT 15, 'Pargolo', NULL, '1-1-39', NULL, NULL FROM dual UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店', NULL, '4-23', NULL, NULL FROM dual UNION ALL
    SELECT 17, '太陽ノ塔', NULL, '3-12', NULL, NULL FROM dual UNION ALL
    SELECT 18, 'MON CHARME', NULL, '5-31', NULL, NULL FROM dual UNION ALL
    SELECT 19, 'neel中崎町', NULL, '1-13', NULL, NULL FROM dual UNION ALL
    SELECT 20, '34 Kitchen', NULL, '23-8', NULL, NULL FROM dual UNION ALL
    SELECT 21, '24ジカンスイーツノキブン', NULL, '27-4', NULL, NULL FROM dual UNION ALL
    SELECT 22, 'くじらカフェ', NULL, '2-3-13', NULL, NULL FROM dual UNION ALL
    SELECT 23, 'ダイニングバー 七', NULL, '3-1-38', NULL, NULL FROM dual UNION ALL
    SELECT 24, '焼き鳥酒場 BOO', NULL, '3-12-28', NULL, NULL FROM dual UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン', NULL, '1-17-2', NULL, NULL FROM dual
),
MATCHED AS (
    SELECT x.*
    FROM (
        SELECT
            c.*,
            ROW_NUMBER() OVER (
                PARTITION BY c.seq_no
                ORDER BY c.match_score DESC,
                         c.distance_key ASC,
                         c.restaurant_id ASC
            ) AS rn
        FROM CANDIDATES c
    ) x
    WHERE x.rn = 1
)
SELECT
    25 AS target_count,
    COUNT(*) AS target_rows,
    COUNT(CASE WHEN restaurant_id IS NOT NULL THEN 1 END) AS matched_rows,
    COUNT(CASE WHEN match_score >= 800 THEN 1 END) AS strong_rows,
    COUNT(CASE WHEN restaurant_id IS NULL THEN 1 END) AS unmatched_rows
FROM MATCHED;

PROMPT ============================================================
PROMPT NO DATA CHANGED - NEXT STEP IS REVIEW INSERT AFTER MATCH CHECK
PROMPT ============================================================

SET DEFINE ON
