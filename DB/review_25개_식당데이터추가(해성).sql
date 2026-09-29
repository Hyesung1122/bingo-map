-- ============================================================
-- BinGo Map : 맛집 25곳으로 전체 교체 (기존 5개 + 새로 받은 일본어 목록 20곳)
--
-- [구성]
--  1~5  : 원래 있던 맛집 5개 (쿠쿠루/산페이/치보/타이야끼/카라아게) - 데이터 그대로 재사용
--  6~25 : 새로 받은 목록 중 앞 20곳 (뒤 6곳은 25개 맞추려고 제외 - 필요하면 알려주면 교체)
--
-- [6~25번의 값 출처]
--  * 이름/카테고리/주소/영업시간/전화/웹사이트(있는 것만) : 실제로 받은 값 그대로
--  * 평점/리뷰수/가격대 : 화면 테스트용 임의값 (실제 정보 아님)
--  * 좌석/예약/결제/언어/대표메뉴/사진/좌표 : 정보가 없어서 비움(NULL)
--    -> 좌표가 없어서 이 20곳은 지도에는 안 뜨고, 리뷰 목록/상세에만 나옴
--
-- [하는 일]
--  1) restaurants 에 is_published 컬럼이 없으면 추가
--  2) 기존 맛집에 달린 리뷰 사진 -> 리뷰 -> 메뉴를 먼저 삭제 (외래키 때문에 순서 중요)
--  3) 기존 맛집을 전부 삭제
--  4) 위 25곳을 새로 추가 (모두 is_published='Y')
--
-- [경고] 앱에서 실제로 남긴 리뷰가 있었다면 2)에서 함께 삭제됨. 되돌릴 수 없음.
-- [통합본에서 고친 것]
--  * MON CHARME 영업시간 문구가 105자라 opening_hours(최대 100자) 초과로 ORA-12899 났던 것 -> 짧게 줄임
--  * TB_REVIEW / TB_REVIEW_IMAGE 가 이 DB에 아직 없어도(ORA-00942) 멈추지 않고 건너뛰도록 처리
--    (이 2개는 별개로 팀 쿼리에서 만들어야 함 - 안 만들어도 리뷰 목록 카드는 뜸)
--  * TB_RESTAURANT_MENU 는 이 파일이 직접 만들고, 맛집 25곳의 메뉴까지 같이 채움
--    (맛집 상세의 '메뉴' 영역은 restaurants.menu_name 이 아니라 이 테이블만 보기 때문)
--    - 원래 5개: 실제 있던 메뉴 그대로 (is_signature=1)
--    - 새 20개: 정보가 없어서 '대표 메뉴 (테스트용)' ¥1,000 로 채움
-- [실행] 앱을 끄고 SQL Developer 에서 전체 F5. 결과 확인 후 COMMIT; 하세요.
-- ============================================================
SET SERVEROUTPUT ON
SET DEFINE OFF

-- ---------- 1. is_published 컬럼 없으면 추가 ----------
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM USER_TAB_COLUMNS
    WHERE TABLE_NAME = 'RESTAURANTS' AND COLUMN_NAME = 'IS_PUBLISHED';

    IF v_exists = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE restaurants ADD (is_published VARCHAR2(1) DEFAULT ''Y'' NOT NULL)';
        DBMS_OUTPUT.PUT_LINE('ADDED: restaurants.is_published');
    ELSE
        DBMS_OUTPUT.PUT_LINE('EXISTS: restaurants.is_published');
    END IF;
END;
/

-- ---------- 2. 기존 맛집에 달린 리뷰/메뉴 먼저 삭제 ----------
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TB_REVIEW_IMAGE';
    IF v_exists = 1 THEN
        EXECUTE IMMEDIATE 'DELETE FROM TB_REVIEW_IMAGE WHERE REVIEW_ID IN (SELECT REVIEW_ID FROM TB_REVIEW WHERE RESTAURANT_ID IN (SELECT id FROM restaurants))';
    ELSE
        DBMS_OUTPUT.PUT_LINE('SKIP: TB_REVIEW_IMAGE 테이블이 없어서 건너뜀');
    END IF;

    SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TB_REVIEW';
    IF v_exists = 1 THEN
        EXECUTE IMMEDIATE 'DELETE FROM TB_REVIEW WHERE RESTAURANT_ID IN (SELECT id FROM restaurants)';
    ELSE
        DBMS_OUTPUT.PUT_LINE('SKIP: TB_REVIEW 테이블이 없어서 건너뜀');
    END IF;
END;
/

DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TB_RESTAURANT_MENU';
    IF v_exists = 1 THEN
        EXECUTE IMMEDIATE 'DELETE FROM TB_RESTAURANT_MENU WHERE RESTAURANT_ID IN (SELECT id FROM restaurants)';
    ELSE
        DBMS_OUTPUT.PUT_LINE('SKIP: TB_RESTAURANT_MENU 테이블이 없어서 건너뜀');
    END IF;
END;
/

-- ---------- 3. 기존 맛집 전부 삭제 ----------
DELETE FROM restaurants;

-- ---------- 4. 맛집 25곳 추가 ----------
-- [1/25] 쿠쿠루 도톤보리 본점  (원래 있던 맛집 데이터 그대로)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '쿠쿠루 도톤보리 본점',
    '타코야끼',
    '도톤보리,타코야끼,오사카맛집',
    4.6,
    1248,
    '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집',
    '1-10-5 Dotonbori, Chuo-ku, Osaka',
    34.668729,
    135.501294,
    '09:00 - 21:00',
    '+81-6-6212-7381',
    '¥500 - ¥1,500',
    'https://www.kukurutei.com',
    '20석',
    '예약 불가 (현장 대기)',
    '현금, 신용카드, 전자화폐',
    '일본어, 한국어 메뉴판',
    '/images/food-takoyaki.png',
    '명물 타코야끼 (8개)',
    '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴',
    '¥850',
    NULL,
    'Y'
);

-- [2/25] 야끼소바 산페이  (원래 있던 맛집 데이터 그대로)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '야끼소바 산페이',
    '야끼소바',
    '야끼소바,철판요리,감칠맛',
    4.4,
    892,
    '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점',
    '1-7-14 Dotonbori, Chuo-ku, Osaka',
    34.668900,
    135.502100,
    '10:30 - 20:30',
    '+81-6-6211-1234',
    '¥700 - ¥1,200',
    'https://www.sanpei-osaka.jp',
    '15석 (카운터석)',
    '예약 불가',
    '현금, 신용카드',
    '일본어, 영어',
    '/images/food-yakisoba.png',
    '특제 소스 야끼소바',
    '진한 특제 소스와 쫄깃한 면발의 조화',
    '¥900',
    NULL,
    'Y'
);

-- [3/25] 오코노미야끼 치보 도톤보리빌딩점  (원래 있던 맛집 데이터 그대로)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '오코노미야끼 치보 도톤보리빌딩점',
    '오코노미야끼',
    '오코노미야끼,철판구이,웨이팅맛집',
    4.5,
    1102,
    '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장',
    '1-5-5 Dotonbori, Chuo-ku, Osaka',
    34.668500,
    135.503200,
    '11:00 - 21:30',
    '+81-6-6212-2211',
    '¥1,000 - ¥2,500',
    'https://www.chibo.com',
    '50석 (테이블 및 다찌석)',
    '전화 예약 가능',
    '현금, 신용카드, 모바일페이',
    '한국어 지원 (다국어 키오스크)',
    '/images/food-okonomiyaki.png',
    '치보 믹스 오코노미야끼',
    '새우, 오징어, 돼지고기가 모두 들어간 베스트 메뉴',
    '¥1,580',
    NULL,
    'Y'
);

-- [4/25] 도톤보리 타이야끼  (원래 있던 맛집 데이터 그대로)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '도톤보리 타이야끼',
    '붕어빵',
    '길거리간식,붕어빵,디저트',
    4.3,
    567,
    '국산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵',
    '1-8-22 Dotonbori, Chuo-ku, Osaka',
    34.668350,
    135.500800,
    '10:00 - 19:00',
    '+81-6-6213-9876',
    '¥300 - ¥600',
    NULL,
    '없음 (테이크아웃 전용)',
    '예약 불가',
    '현금 전용',
    '일본어 메뉴',
    '/images/food-taiyaki.png',
    '통단팥 붕어빵',
    '달콤하고 부드러운 팥이 꽉 찬 인기 간식',
    '¥300',
    NULL,
    'Y'
);

-- [5/25] 카라아게 타로  (원래 있던 맛집 데이터 그대로)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '카라아게 타로',
    '닭튀김',
    '치킨,가라아게,맥주안주',
    4.4,
    734,
    '바삭한 튀김옷 속 육즙이 가득! 특제 마늘 간장 소스로 버무린 정통 일본식 닭튀김',
    '2-2-1 Nanba, Chuo-ku, Osaka',
    34.667800,
    135.500200,
    '11:00 - 21:00',
    '+81-6-6631-5544',
    '¥600 - ¥1,000',
    'https://www.karaage-taro.jp',
    '10석',
    '예약 불가',
    '현금, 신용카드',
    '일본어, 영어',
    '/images/food-karaage.png',
    '카라아게 타로 (오리지널)',
    '겉은 바삭하고 속은 촉촉한 대표 닭튀김',
    '¥680',
    NULL,
    'Y'
);

-- [6/25] エミュリボン  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'エミュリボン',
    '기타',
    NULL,
    4.2,
    58,
    '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
    '2-13-5',
    NULL,
    NULL,
    'Mo-Fr 18:00-23:00; Sa-Su 16:00-23:00',
    '0664847389',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [7/25] ギャムドカフェ  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'ギャムドカフェ',
    '기타',
    NULL,
    3.9,
    42,
    '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
    '中央区 2 2-8',
    NULL,
    NULL,
    'Mo-Sa 00:00-24:00',
    '+81-6-7710-2165',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [8/25] ポケモンカフェ  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'ポケモンカフェ',
    '기타',
    NULL,
    4.5,
    210,
    '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
    '北区 梅田3 1-1',
    NULL,
    NULL,
    'Mo-Su 10:00-20:00',
    '+81 6 4256 1160',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [9/25] 本宮的茶 大阪 (BEN GONG'S TEA)  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '本宮的茶 大阪 (BEN GONG''S TEA)',
    '카페(버블티)',
    NULL,
    4.0,
    35,
    '(정보 일부 미확인 - 테스트용 설명) 카페(버블티) 매장입니다.',
    '中央区 1 21-30-1F',
    NULL,
    NULL,
    '11:00-22:30',
    '+81-6-4963-3250',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [10/25] 癒ロイド  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '癒ロイド',
    '카페',
    NULL,
    4.3,
    77,
    '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
    '2-4-8',
    NULL,
    NULL,
    '10:00-22:00',
    '+81 6-6632-2118',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [11/25] 靭本町がく  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '靭本町がく',
    '일식',
    NULL,
    4.1,
    64,
    '(정보 일부 미확인 - 테스트용 설명) 일식 매장입니다.',
    '西 1 14-15',
    NULL,
    NULL,
    '11:30-15:00,17:00-23:00; Su,PH off',
    '+81-6-6479-3459',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [12/25] ノンシャラマンカフェ  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'ノンシャラマンカフェ',
    '카페',
    NULL,
    3.8,
    29,
    '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
    '中央区 備後町一丁目 4-14',
    NULL,
    NULL,
    'Mo-Fr 10:00-19:00; Sa, Su, PH 12:00-19:00',
    '+81 6 6265 3366',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [13/25] 蜜家珈琲店  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '蜜家珈琲店',
    '카페(브런치)',
    NULL,
    4.4,
    95,
    '(정보 일부 미확인 - 테스트용 설명) 카페(브런치) 매장입니다.',
    '阿倍野区 1-6-1',
    NULL,
    NULL,
    'Mo-Su 10:00-21:00',
    '06-6536-8814',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [14/25] 梨花食堂  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '梨花食堂',
    '카레',
    NULL,
    4.0,
    51,
    '(정보 일부 미확인 - 테스트용 설명) 카레 매장입니다.',
    '北区 天神橋四丁目 8-15',
    NULL,
    NULL,
    '10:30-15:00',
    '06-6358-0787',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [15/25] Pargolo  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'Pargolo',
    '이탈리안',
    NULL,
    3.7,
    33,
    '(정보 일부 미확인 - 테스트용 설명) 이탈리안 매장입니다.',
    '四貫島１丁目１−３９',
    NULL,
    NULL,
    'Mo-Su,PH 12:00-13:30,18:00-20:30',
    '+81 6 6464 0651',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [16/25] 傾奇御麺 天神橋・本店  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '傾奇御麺 天神橋・本店',
    '라멘',
    NULL,
    4.2,
    88,
    '(정보 일부 미확인 - 테스트용 설명) 라멘 매장입니다.',
    '北区 浪花町 4-23',
    NULL,
    NULL,
    '11:30-02:00',
    '06-6147-4446',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [17/25] 太陽ノ塔  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '太陽ノ塔',
    '카페(디저트)',
    NULL,
    4.3,
    71,
    '(정보 일부 미확인 - 테스트용 설명) 카페(디저트) 매장입니다.',
    '中崎二丁目 3-12',
    NULL,
    NULL,
    'Mo-Su 09:00-22:00',
    '+81 6-6374-3630',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [18/25] MON CHARME  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'MON CHARME',
    '프렌치',
    NULL,
    4.6,
    120,
    '(정보 일부 미확인 - 테스트용 설명) 프렌치 매장입니다.',
    '北区 浮田一丁目 5-31',
    NULL,
    NULL,
    '목금토 런치(예약) / 월~토 디너 / 일 휴무',
    '06-6131-9119',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [19/25] neel中崎町  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'neel中崎町',
    '카페',
    NULL,
    4.1,
    46,
    '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
    '中崎西四丁目 1-13',
    NULL,
    NULL,
    'Mo-Su 10:00-20:30',
    '+81 6-6867-9996',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [20/25] 34 Kitchen  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '34 Kitchen',
    '카페',
    NULL,
    3.9,
    28,
    '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
    '23-8',
    NULL,
    NULL,
    '11:00-23:00',
    '06-4256-6915',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [21/25] 24ジカンスイーツノキブン  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '24ジカンスイーツノキブン',
    '디저트',
    NULL,
    4.0,
    40,
    '(정보 일부 미확인 - 테스트용 설명) 디저트 매장입니다.',
    '生野区 小路2丁目 27-4',
    NULL,
    NULL,
    '24시간 연중무휴',
    NULL,
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [22/25] くじらカフェ  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'くじらカフェ',
    '카페',
    NULL,
    4.2,
    62,
    '(정보 일부 미확인 - 테스트용 설명) 카페 매장입니다.',
    '西淀川区 2丁目 3-13',
    NULL,
    NULL,
    'Mo-Sa 11:00-15:00; Su,PH off',
    '06-7508-7352',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [23/25] ダイニングバー 七  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'ダイニングバー 七',
    '이탈리안',
    NULL,
    3.8,
    25,
    '(정보 일부 미확인 - 테스트용 설명) 이탈리안 매장입니다.',
    '西淀川区 3-1-38',
    NULL,
    NULL,
    'Tu-Su 17:30-20:00',
    '06-6477-7087',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [24/25] 焼き鳥酒場 BOO  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    '焼き鳥酒場 BOO',
    '기타',
    NULL,
    4.1,
    53,
    '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
    '西淀川区 3-12-28',
    NULL,
    NULL,
    'Mo-Sa 11:30-24:00',
    '06-4808-1241',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);

-- [25/25] ビストロ ソウルキッチン  (좌표/사진/메뉴 없음, 평점·리뷰수·가격대는 테스트용 임의값)
INSERT INTO restaurants (
    name, category, tags, rating, review_count, description, address, latitude, longitude, opening_hours, phone, price_range, website_url, seat_info, reservation_info, payment_methods, languages, main_image_url, menu_name, menu_description, menu_price, menu_image_url, is_published
) VALUES (
    'ビストロ ソウルキッチン',
    '기타',
    NULL,
    4.0,
    37,
    '(정보 일부 미확인 - 테스트용 설명) 기타 매장입니다.',
    '淀川区 1-17-2 山陽マンション102',
    NULL,
    NULL,
    '12:00-20:00',
    '06-7708-7475',
    '¥1,000 - ¥2,000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'Y'
);


-- ---------- 5. TB_RESTAURANT_MENU 테이블 준비 (없으면 생성) ----------
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TB_RESTAURANT_MENU';
    IF v_exists = 0 THEN
        EXECUTE IMMEDIATE q'[
            CREATE TABLE TB_RESTAURANT_MENU (
                MENU_ID       NUMBER          NOT NULL,
                RESTAURANT_ID NUMBER          NOT NULL,
                NAME          VARCHAR2(100)   NOT NULL,
                PRICE         VARCHAR2(50),
                IS_SIGNATURE  NUMBER(1)       DEFAULT 0,
                CONSTRAINT pk_tb_restaurant_menu PRIMARY KEY (MENU_ID),
                CONSTRAINT fk_menu_restaurant FOREIGN KEY (RESTAURANT_ID) REFERENCES restaurants (id)
            )
        ]';
        DBMS_OUTPUT.PUT_LINE('CREATED: TB_RESTAURANT_MENU');
    ELSE
        DBMS_OUTPUT.PUT_LINE('EXISTS: TB_RESTAURANT_MENU');
    END IF;

    SELECT COUNT(*) INTO v_exists FROM USER_SEQUENCES WHERE SEQUENCE_NAME = 'SEQ_RESTAURANT_MENU';
    IF v_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_RESTAURANT_MENU START WITH 1 INCREMENT BY 1 NOCACHE';
        DBMS_OUTPUT.PUT_LINE('CREATED: SEQ_RESTAURANT_MENU');
    ELSE
        DBMS_OUTPUT.PUT_LINE('EXISTS: SEQ_RESTAURANT_MENU');
    END IF;
END;
/

-- 자동 채번 트리거 (없으면 생성)
CREATE OR REPLACE TRIGGER tb_restaurant_menu_bi
    BEFORE INSERT ON TB_RESTAURANT_MENU
    FOR EACH ROW
BEGIN
    IF :NEW.MENU_ID IS NULL THEN
        SELECT SEQ_RESTAURANT_MENU.NEXTVAL INTO :NEW.MENU_ID FROM dual;
    END IF;
END;
/

-- ---------- 6. 맛집 25곳 메뉴 1개씩 추가 (이름으로 매칭, 이미 있으면 건너뜀) ----------
-- 원래 있던 맛집 5개 (실제 메뉴 그대로)
INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '명물 타코야끼 (8개)', '¥850', 1 FROM restaurants
WHERE name = '쿠쿠루 도톤보리 본점'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '특제 소스 야끼소바', '¥900', 1 FROM restaurants
WHERE name = '야끼소바 산페이'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '치보 믹스 오코노미야끼', '¥1,580', 1 FROM restaurants
WHERE name = '오코노미야끼 치보 도톤보리빌딩점'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '통단팥 붕어빵', '¥300', 1 FROM restaurants
WHERE name = '도톤보리 타이야끼'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '카라아게 타로 (오리지널)', '¥680', 1 FROM restaurants
WHERE name = '카라아게 타로'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

-- 새로 받은 맛집 20개 (정보 없어서 테스트용 메뉴로 채움)
INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'エミュリボン'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'ギャムドカフェ'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'ポケモンカフェ'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '本宮的茶 大阪 (BEN GONG''S TEA)'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '癒ロイド'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '靭本町がく'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'ノンシャラマンカフェ'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '蜜家珈琲店'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '梨花食堂'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'Pargolo'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '傾奇御麺 天神橋・本店'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '太陽ノ塔'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'MON CHARME'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'neel中崎町'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '34 Kitchen'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '24ジカンスイーツノキブン'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'くじらカフェ'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'ダイニングバー 七'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = '焼き鳥酒場 BOO'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);

INSERT INTO TB_RESTAURANT_MENU (RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE)
SELECT id, '대표 메뉴 (테스트용)', '¥1,000', 1 FROM restaurants
WHERE name = 'ビストロ ソウルキッチン'
  AND NOT EXISTS (SELECT 1 FROM TB_RESTAURANT_MENU m WHERE m.RESTAURANT_ID = restaurants.id);
COMMIT;

-- ---------- 확인 ----------
-- 기대값: TOTAL=25, PUBLIC_COUNT=25
SELECT COUNT(*) AS TOTAL, COUNT(CASE WHEN is_published='Y' THEN 1 END) AS PUBLIC_COUNT FROM restaurants;
SELECT id, name, category, address, is_published FROM restaurants ORDER BY id;

-- 기대값: MENU_COUNT=25, NO_MENU_COUNT=0
SELECT COUNT(DISTINCT r.id) AS RESTAURANTS_TOTAL,
       COUNT(DISTINCT m.RESTAURANT_ID) AS MENU_COUNT,
       COUNT(DISTINCT r.id) - COUNT(DISTINCT m.RESTAURANT_ID) AS NO_MENU_COUNT
FROM restaurants r
LEFT JOIN TB_RESTAURANT_MENU m ON m.RESTAURANT_ID = r.id
WHERE r.is_published = 'Y';
