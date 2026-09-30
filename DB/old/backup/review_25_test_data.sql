-- BinGo Map / 리뷰 탭 테스트용 25개 식당 + 25개 리뷰
-- 현재 최종 DB 구조만 사용합니다.
--
-- 목적
-- 1) 팀원이 만든 25개 식당 데이터를 현재 restaurants 구조로 넣습니다.
-- 2) 지도 데이터와 섞이지 않도록 OSM_ID는 NULL, IS_PUBLISHED='N'으로 넣습니다.
-- 3) 각 식당에 리뷰 1개씩 총 25개를 reviews에 넣습니다.
-- 4) 리뷰 화면은 이 25개 테스트 리뷰만 골라서 보여줍니다.
--
-- 주의
-- - 기존 OSM restaurants 1,915건은 삭제/수정하지 않습니다.
-- - 기존 Y/N 공개 상태도 건드리지 않습니다.
-- - TB_REVIEW / TB_REVIEW_IMAGE / TB_RESTAURANT_MENU / RESTAURANT는 사용하지 않습니다.
-- - 이 데이터는 화면 연결 확인용 가상 테스트 데이터입니다.
-- - 반복 실행 시 이 파일이 만든 테스트 행만 먼저 지우고 다시 만듭니다.

SET DEFINE OFF
SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT 1. OLD REVIEW TEST DATA CLEANUP
PROMPT ============================================================

DELETE FROM reviews
WHERE target_type = 'RESTAURANT'
  AND content LIKE '[BinGo REVIEW TEST 25]%';

DELETE FROM restaurants
WHERE tags LIKE '%REVIEW_TEST_25%';

PROMPT ============================================================
PROMPT 2. INSERT 25 TEST RESTAURANTS
PROMPT ============================================================

INSERT INTO restaurants (
    name, category, tags, rating, review_count, description,
    address, latitude, longitude, opening_hours, phone, price_range,
    website_url, seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description, menu_price, menu_image_url,
    osm_id, is_published, created_at, updated_at
)
SELECT
    name, category, tags, rating, review_count, description,
    address, latitude, longitude, opening_hours, phone, price_range,
    website_url, seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description, menu_price, menu_image_url,
    NULL, 'N', SYSTIMESTAMP, SYSTIMESTAMP
FROM (
    SELECT
        '쿠쿠루 도톤보리 본점' name,
        '타코야끼' category,
        '도톤보리,타코야끼,오사카맛집,REVIEW_TEST_25' tags,
        4.6 rating, 1248 review_count,
        '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집' description,
        '1-10-5 Dotonbori, Chuo-ku, Osaka' address,
        34.668729 latitude, 135.501294 longitude,
        '09:00 - 21:00' opening_hours,
        '+81-6-6212-7381' phone,
        '¥500 - ¥1,500' price_range,
        'https://www.kukurutei.com' website_url,
        '20석' seat_info,
        '예약 불가 (현장 대기)' reservation_info,
        '현금, 신용카드, 전자화폐' payment_methods,
        '일본어, 한국어 메뉴판' languages,
        '/images/food-takoyaki.png' main_image_url,
        '명물 타코야끼 (8개)' menu_name,
        '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴' menu_description,
        '¥850' menu_price,
        NULL menu_image_url
    FROM dual
    UNION ALL SELECT
        '야끼소바 산페이', '야끼소바',
        '야끼소바,철판요리,감칠맛,REVIEW_TEST_25',
        4.4, 892,
        '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점',
        '1-7-14 Dotonbori, Chuo-ku, Osaka',
        34.668900, 135.502100,
        '10:30 - 20:30', '+81-6-6211-1234',
        '¥700 - ¥1,200', 'https://www.sanpei-osaka.jp',
        '15석 (카운터석)', '예약 불가',
        '현금, 신용카드', '일본어, 영어',
        '/images/food-yakisoba.png',
        '특제 소스 야끼소바',
        '진한 특제 소스와 쫄깃한 면발의 조화',
        '¥900', NULL
    FROM dual
    UNION ALL SELECT
        '오코노미야끼 치보 도톤보리빌딩점', '오코노미야끼',
        '오코노미야끼,철판구이,웨이팅맛집,REVIEW_TEST_25',
        4.5, 1102,
        '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장',
        '1-5-5 Dotonbori, Chuo-ku, Osaka',
        34.668500, 135.503200,
        '11:00 - 21:30', '+81-6-6212-2211',
        '¥1,000 - ¥2,500', 'https://www.chibo.com',
        '50석 (테이블 및 다찌석)', '전화 예약 가능',
        '현금, 신용카드, 모바일페이', '한국어 지원 (다국어 키오스크)',
        '/images/food-okonomiyaki.png',
        '치보 믹스 오코노미야끼',
        '새우, 오징어, 돼지고기가 모두 들어간 베스트 메뉴',
        '¥1,580', NULL
    FROM dual
    UNION ALL SELECT
        '도톤보리 타이야끼', '붕어빵',
        '길거리간식,붕어빵,디저트,REVIEW_TEST_25',
        4.3, 567,
        '국산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵',
        '1-8-22 Dotonbori, Chuo-ku, Osaka',
        34.668350, 135.500800,
        '10:00 - 19:00', '+81-6-6213-9876',
        '¥300 - ¥600', NULL,
        '없음 (테이크아웃 전용)', '예약 불가',
        '현금 전용', '일본어 메뉴',
        '/images/food-taiyaki.png',
        '통단팥 붕어빵',
        '달콤하고 부드러운 팥이 꽉 찬 인기 간식',
        '¥300', NULL
    FROM dual
    UNION ALL SELECT
        '카라아게 타로', '닭튀김',
        '치킨,가라아게,맥주안주,REVIEW_TEST_25',
        4.4, 734,
        '바삭한 튀김옷 속 육즙이 가득! 특제 마늘 간장 소스로 버무린 정통 일본식 닭튀김',
        '2-2-1 Nanba, Chuo-ku, Osaka',
        34.667800, 135.500200,
        '11:00 - 21:00', '+81-6-6631-5544',
        '¥600 - ¥1,000', 'https://www.karaage-taro.jp',
        '10석', '예약 불가',
        '현금, 신용카드', '일본어, 영어',
        '/images/food-karaage.png',
        '카라아게 타로 (오리지널)',
        '겉은 바삭하고 속은 촉촉한 대표 닭튀김',
        '¥680', NULL
    FROM dual
    UNION ALL SELECT
        'エミュリボン', '기타', 'REVIEW_TEST_25', 4.2, 58,
        '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
        '2-13-5', NULL, NULL,
        'Mo-Fr 18:00-23:00; Sa-Su 16:00-23:00', '0664847389',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'ギャムドカフェ', '기타', 'REVIEW_TEST_25', 3.9, 42,
        '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
        '中央区 2 2-8', NULL, NULL,
        'Mo-Sa 00:00-24:00', '+81-6-7710-2165',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'ポケモンカフェ', '기타', 'REVIEW_TEST_25', 4.5, 210,
        '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
        '北区 梅田3 1-1', NULL, NULL,
        'Mo-Su 10:00-20:00', '+81 6 4256 1160',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '本宮的茶 大阪 (BEN GONG''S TEA)', '카페(버블티)', 'REVIEW_TEST_25', 4.0, 35,
        '(정보 일부 미확인 - 테스트용 설명) 카페(버블티) 매장입니다.',
        '中央区 1 21-30-1F', NULL, NULL,
        '11:00-22:30', '+81-6-4963-3250',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '癒ロイド', '카페', 'REVIEW_TEST_25', 4.3, 77,
        '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
        '2-4-8', NULL, NULL,
        '10:00-22:00', '+81 6-6632-2118',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '靭本町がく', '일식', 'REVIEW_TEST_25', 4.1, 64,
        '(정보 일부 미확인 - 테스트용 설명) 일식 매장입니다.',
        '西 1 14-15', NULL, NULL,
        '11:30-15:00,17:00-23:00; Su,PH off', '+81-6-6479-3459',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'ノンシャラマンカフェ', '카페', 'REVIEW_TEST_25', 3.8, 29,
        '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
        '中央区 備後町一丁目 4-14', NULL, NULL,
        'Mo-Fr 10:00-19:00; Sa, Su, PH 12:00-19:00', '+81 6 6265 3366',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '蜜家珈琲店', '카페(브런치)', 'REVIEW_TEST_25', 4.4, 95,
        '(정보 일부 미확인 - 테스트용 설명) 카페(브런치) 매장입니다.',
        '阿倍野区 1-6-1', NULL, NULL,
        'Mo-Su 10:00-21:00', '06-6536-8814',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '梨花食堂', '카레', 'REVIEW_TEST_25', 4.0, 51,
        '(정보 일부 미확인 - 테스트용 설명) 카레 매장입니다.',
        '北区 天神橋四丁目 8-15', NULL, NULL,
        '10:30-15:00', '06-6358-0787',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'Pargolo', '이탈리안', 'REVIEW_TEST_25', 3.7, 33,
        '(정보 일부 미확인 - 테스트용 설명) 이탈리안 매장입니다.',
        '四貫島１丁目１−３９', NULL, NULL,
        'Mo-Su,PH 12:00-13:30,18:00-20:30', '+81 6 6464 0651',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '傾奇御麺 天神橋・本店', '라멘', 'REVIEW_TEST_25', 4.2, 88,
        '(정보 일부 미확인 - 테스트용 설명) 라멘 매장입니다.',
        '北区 浪花町 4-23', NULL, NULL,
        '11:30-02:00', '06-6147-4446',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '太陽ノ塔', '카페(디저트)', 'REVIEW_TEST_25', 4.3, 71,
        '(정보 일부 미확인 - 테스트용 설명) 카페(디저트) 매장입니다.',
        '中崎二丁目 3-12', NULL, NULL,
        'Mo-Su 09:00-22:00', '+81 6-6374-3630',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'MON CHARME', '프렌치', 'REVIEW_TEST_25', 4.6, 120,
        '(정보 일부 미확인 - 테스트용 설명) 프렌치 매장입니다.',
        '北区 浮田一丁目 5-31', NULL, NULL,
        '목금토 런치(예약) / 월~토 디너 / 일 휴무', '06-6131-9119',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'neel中崎町', '카페', 'REVIEW_TEST_25', 4.1, 46,
        '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
        '中崎西四丁目 1-13', NULL, NULL,
        'Mo-Su 10:00-20:30', '+81 6-6867-9996',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '34 Kitchen', '카페', 'REVIEW_TEST_25', 3.9, 28,
        '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
        '23-8', NULL, NULL,
        '11:00-23:00', '06-4256-6915',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '24ジカンスイーツノキブン', '디저트', 'REVIEW_TEST_25', 4.0, 40,
        '(정보 일부 미확인 - 테스트용 설명) 디저트 매장입니다.',
        '生野区 小路2丁目 27-4', NULL, NULL,
        '24시간 연중무휴', NULL,
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'くじらカフェ', '카페', 'REVIEW_TEST_25', 4.2, 62,
        '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
        '西淀川区 2丁目 3-13', NULL, NULL,
        'Mo-Sa 11:00-15:00; Su,PH off', '06-7508-7352',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'ダイニングバー 七', '이탈리안', 'REVIEW_TEST_25', 3.8, 25,
        '(정보 일부 미확인 - 테스트용 설명) 이탈리안 매장입니다.',
        '西淀川区 3-1-38', NULL, NULL,
        'Tu-Su 17:30-20:00', '06-6477-7087',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        '焼き鳥酒場 BOO', '기타', 'REVIEW_TEST_25', 4.1, 53,
        '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
        '西淀川区 3-12-28', NULL, NULL,
        'Mo-Sa 11:30-24:00', '06-4808-1241',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
    UNION ALL SELECT
        'ビストロ ソウルキッチン', '기타', 'REVIEW_TEST_25', 4.0, 37,
        '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
        '淀川区 1-17-2 山陽マンション102', NULL, NULL,
        '12:00-20:00', '06-7708-7475',
        '¥1,000 - ¥2,000', NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL
    FROM dual
);

PROMPT INSERTED TEST RESTAURANTS:
SELECT COUNT(*) AS TEST_RESTAURANT_COUNT
FROM restaurants
WHERE tags LIKE '%REVIEW_TEST_25%';

PROMPT ============================================================
PROMPT 3. INSERT 25 TEST REVIEWS
PROMPT ============================================================

INSERT INTO reviews (
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
    (SELECT MIN(id) FROM users),
    'RESTAURANT',
    TO_CHAR(r.restaurant_id),
    d.rating,
    '[BinGo REVIEW TEST 25] ' || d.name || ' - 화면 연결 확인용 가상 리뷰입니다.',
    TRUNC(SYSDATE) - d.seq_no,
    CASE MOD(d.seq_no, 3)
        WHEN 0 THEN 'DINNER'
        WHEN 1 THEN 'LUNCH'
        ELSE 'AFTERNOON'
    END,
    'TRAVEL',
    1,
    0,
    SYSTIMESTAMP,
    SYSTIMESTAMP
FROM (
    SELECT  1 seq_no, '쿠쿠루 도톤보리 본점' name, 4.6 rating FROM dual UNION ALL
    SELECT  2, '야끼소바 산페이', 4.4 FROM dual UNION ALL
    SELECT  3, '오코노미야끼 치보 도톤보리빌딩점', 4.5 FROM dual UNION ALL
    SELECT  4, '도톤보리 타이야끼', 4.3 FROM dual UNION ALL
    SELECT  5, '카라아게 타로', 4.4 FROM dual UNION ALL
    SELECT  6, 'エミュリボン', 4.2 FROM dual UNION ALL
    SELECT  7, 'ギャムドカフェ', 3.9 FROM dual UNION ALL
    SELECT  8, 'ポケモンカフェ', 4.5 FROM dual UNION ALL
    SELECT  9, '本宮的茶 大阪 (BEN GONG''S TEA)', 4.0 FROM dual UNION ALL
    SELECT 10, '癒ロイド', 4.3 FROM dual UNION ALL
    SELECT 11, '靭本町がく', 4.1 FROM dual UNION ALL
    SELECT 12, 'ノンシャラマンカフェ', 3.8 FROM dual UNION ALL
    SELECT 13, '蜜家珈琲店', 4.4 FROM dual UNION ALL
    SELECT 14, '梨花食堂', 4.0 FROM dual UNION ALL
    SELECT 15, 'Pargolo', 3.7 FROM dual UNION ALL
    SELECT 16, '傾奇御麺 天神橋・本店', 4.2 FROM dual UNION ALL
    SELECT 17, '太陽ノ塔', 4.3 FROM dual UNION ALL
    SELECT 18, 'MON CHARME', 4.6 FROM dual UNION ALL
    SELECT 19, 'neel中崎町', 4.1 FROM dual UNION ALL
    SELECT 20, '34 Kitchen', 3.9 FROM dual UNION ALL
    SELECT 21, '24ジカンスイーツノキブン', 4.0 FROM dual UNION ALL
    SELECT 22, 'くじらカフェ', 4.2 FROM dual UNION ALL
    SELECT 23, 'ダイニングバー 七', 3.8 FROM dual UNION ALL
    SELECT 24, '焼き鳥酒場 BOO', 4.1 FROM dual UNION ALL
    SELECT 25, 'ビストロ ソウルキッチン', 4.0 FROM dual
) d
JOIN restaurants r
  ON r.name = d.name
 AND r.tags LIKE '%REVIEW_TEST_25%';

PROMPT INSERTED TEST REVIEWS:
SELECT COUNT(*) AS TEST_REVIEW_COUNT
FROM reviews
WHERE target_type = 'RESTAURANT'
  AND content LIKE '[BinGo REVIEW TEST 25]%';

COMMIT;

PROMPT ============================================================
PROMPT FINAL CHECK
PROMPT ============================================================

SELECT
    COUNT(*) AS TEST_RESTAURANTS,
    COUNT(CASE WHEN is_published = 'Y' THEN 1 END) AS TEST_PUBLIC,
    COUNT(CASE WHEN is_published = 'N' THEN 1 END) AS TEST_HIDDEN
FROM restaurants
WHERE tags LIKE '%REVIEW_TEST_25%';

SELECT
    COUNT(*) AS TEST_REVIEWS,
    COUNT(DISTINCT target_id) AS REVIEWED_RESTAURANTS
FROM reviews
WHERE target_type = 'RESTAURANT'
  AND content LIKE '[BinGo REVIEW TEST 25]%';

PROMPT ============================================================
PROMPT REVIEW_25_TEST_DATA_DONE
PROMPT ============================================================
