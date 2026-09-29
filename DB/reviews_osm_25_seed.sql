-- BinGo Map / 리뷰 탭 25개 식당 - OSM 매칭 확인 전용
-- 현재 최종 DB 구조만 사용합니다.
-- 사용 테이블: restaurants
-- 이 파일은 INSERT / UPDATE / DELETE를 전혀 하지 않습니다.
--
-- 팀원이 만든 25개 '테스트 식당 데이터' 자체를 DB에 넣는 파일이 아닙니다.
-- 현재 OSM으로 채워진 restaurants에서 같은 식당을 찾아 restaurant_id를 확인합니다.

SET DEFINE OFF
SET PAGESIZE 100
SET LINESIZE 250

PROMPT ============================================================
PROMPT REVIEW 25 / OSM RESTAURANT MATCH CHECK
PROMPT ============================================================

WITH TARGETS (seq_no, requested_name) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점' FROM dual UNION ALL
    SELECT  2, '야끼소바 산페이' FROM dual UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점' FROM dual UNION ALL
    SELECT  4, '도톤보리 타이야끼' FROM dual UNION ALL
    SELECT  5, '카라아게 타로' FROM dual UNION ALL
    SELECT  6, 'エミュリボン' FROM dual UNION ALL
    SELECT  7, 'ギャムドカフェ' FROM dual UNION ALL
    SELECT  8, 'ポケモンカフェ' FROM dual UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)' FROM dual UNION ALL
    SELECT 10, '癒ロイド' FROM dual UNION ALL
    SELECT 11, '靭本町がく' FROM dual UNION ALL
    SELECT 12, 'ノンシャラマンカフェ' FROM dual UNION ALL
    SELECT 13, '蜜家珈琲店' FROM dual UNION ALL
    SELECT 14, '梨花食堂' FROM dual UNION ALL
    SELECT 15, 'Pargolo' FROM dual UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店' FROM dual UNION ALL
    SELECT 17, '太陽ノ塔' FROM dual UNION ALL
    SELECT 18, 'MON CHARME' FROM dual UNION ALL
    SELECT 19, 'neel中崎町' FROM dual UNION ALL
    SELECT 20, '34 Kitchen' FROM dual UNION ALL
    SELECT 21, '24ジカンスイーツノキブン' FROM dual UNION ALL
    SELECT 22, 'くじらカフェ' FROM dual UNION ALL
    SELECT 23, 'ダイニングバー 七' FROM dual UNION ALL
    SELECT 24, '焼き鳥酒場 BOO' FROM dual UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン' FROM dual
),
CANDIDATES AS (
    SELECT
        t.seq_no,
        t.requested_name,
        r.restaurant_id,
        r.osm_id,
        r.name AS osm_name,
        r.address,
        r.latitude,
        r.longitude,
        r.is_published,
        CASE
            WHEN UPPER(TRIM(r.name)) = UPPER(TRIM(t.requested_name))
                THEN 100
            WHEN INSTR(
                    UPPER(REPLACE(NVL(r.name, ''), ' ', '')),
                    UPPER(REPLACE(t.requested_name, ' ', ''))
                 ) > 0
                THEN 70
            WHEN INSTR(
                    UPPER(REPLACE(t.requested_name, ' ', '')),
                    UPPER(REPLACE(NVL(r.name, ''), ' ', ''))
                 ) > 0
                THEN 60
            ELSE 0
        END AS match_score
    FROM TARGETS t
    LEFT JOIN restaurants r
      ON UPPER(REPLACE(NVL(r.name, ''), ' ', ''))
         LIKE '%' || UPPER(REPLACE(t.requested_name, ' ', '')) || '%'
      OR UPPER(REPLACE(t.requested_name, ' ', ''))
         LIKE '%' || UPPER(REPLACE(NVL(r.name, ''), ' ', '')) || '%'
),
RANKED AS (
    SELECT
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY c.seq_no
            ORDER BY c.match_score DESC, c.restaurant_id ASC
        ) AS rn
    FROM CANDIDATES c
)
SELECT
    seq_no,
    requested_name,
    restaurant_id,
    osm_id,
    osm_name,
    address,
    latitude,
    longitude,
    is_published,
    CASE
        WHEN restaurant_id IS NULL THEN 'UNMATCHED'
        WHEN match_score = 100 THEN 'EXACT'
        WHEN match_score >= 70 THEN 'PARTIAL'
        ELSE 'UNMATCHED'
    END AS match_status
FROM RANKED
WHERE rn = 1
ORDER BY seq_no;

PROMPT ============================================================
PROMPT SUMMARY
PROMPT ============================================================

WITH TARGETS (seq_no, requested_name) AS (
    SELECT  1, '쿠쿠루 도톤보리 본점' FROM dual UNION ALL
    SELECT  2, '야끼소바 산페이' FROM dual UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점' FROM dual UNION ALL
    SELECT  4, '도톤보리 타이야끼' FROM dual UNION ALL
    SELECT  5, '카라아게 타로' FROM dual UNION ALL
    SELECT  6, 'エミュリボン' FROM dual UNION ALL
    SELECT  7, 'ギャムドカフェ' FROM dual UNION ALL
    SELECT  8, 'ポケモンカフェ' FROM dual UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)' FROM dual UNION ALL
    SELECT 10, '癒ロイド' FROM dual UNION ALL
    SELECT 11, '靭本町がく' FROM dual UNION ALL
    SELECT 12, 'ノンシャラマンカフェ' FROM dual UNION ALL
    SELECT 13, '蜜家珈琲店' FROM dual UNION ALL
    SELECT 14, '梨花食堂' FROM dual UNION ALL
    SELECT 15, 'Pargolo' FROM dual UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店' FROM dual UNION ALL
    SELECT 17, '太陽ノ塔' FROM dual UNION ALL
    SELECT 18, 'MON CHARME' FROM dual UNION ALL
    SELECT 19, 'neel中崎町' FROM dual UNION ALL
    SELECT 20, '34 Kitchen' FROM dual UNION ALL
    SELECT 21, '24ジカンスイーツノキブン' FROM dual UNION ALL
    SELECT 22, 'くじらカフェ' FROM dual UNION ALL
    SELECT 23, 'ダイニングバー 七' FROM dual UNION ALL
    SELECT 24, '焼き鳥酒場 BOO' FROM dual UNION ALL
    SELECT 25, 'ビスト로 ソウルキッチン' FROM dual
),
MATCHED AS (
    SELECT
        t.seq_no,
        t.requested_name,
        r.restaurant_id,
        CASE
            WHEN UPPER(TRIM(r.name)) = UPPER(TRIM(t.requested_name))
                THEN 100
            WHEN INSTR(
                    UPPER(REPLACE(NVL(r.name, ''), ' ', '')),
                    UPPER(REPLACE(t.requested_name, ' ', ''))
                 ) > 0
                THEN 70
            WHEN INSTR(
                    UPPER(REPLACE(t.requested_name, ' ', '')),
                    UPPER(REPLACE(NVL(r.name, ''), ' ', ''))
                 ) > 0
                THEN 60
            ELSE 0
        END AS match_score,
        ROW_NUMBER() OVER (
            PARTITION BY t.seq_no
            ORDER BY
                CASE
                    WHEN UPPER(TRIM(r.name)) = UPPER(TRIM(t.requested_name))
                        THEN 100
                    WHEN INSTR(
                            UPPER(REPLACE(NVL(r.name, ''), ' ', '')),
                            UPPER(REPLACE(t.requested_name, ' ', ''))
                         ) > 0
                        THEN 70
                    WHEN INSTR(
                            UPPER(REPLACE(t.requested_name, ' ', '')),
                            UPPER(REPLACE(NVL(r.name, ''), ' ', ''))
                         ) > 0
                        THEN 60
                    ELSE 0
                END DESC,
                r.restaurant_id ASC
        ) AS rn
    FROM TARGETS t
    LEFT JOIN restaurants r
      ON UPPER(REPLACE(NVL(r.name, ''), ' ', ''))
         LIKE '%' || UPPER(REPLACE(t.requested_name, ' ', '')) || '%'
      OR UPPER(REPLACE(t.requested_name, ' ', ''))
         LIKE '%' || UPPER(REPLACE(NVL(r.name, ''), ' ', '')) || '%'
)
SELECT
    25 AS target_count,
    COUNT(*) AS target_rows,
    COUNT(CASE WHEN restaurant_id IS NOT NULL AND match_score > 0 THEN 1 END) AS matched_rows,
    COUNT(CASE WHEN restaurant_id IS NOT NULL AND match_score = 100 THEN 1 END) AS exact_rows,
    COUNT(CASE WHEN restaurant_id IS NULL OR match_score = 0 THEN 1 END) AS unmatched_rows
FROM MATCHED
WHERE rn = 1;

PROMPT ============================================================
PROMPT NO DATA CHANGED
PROMPT ============================================================
