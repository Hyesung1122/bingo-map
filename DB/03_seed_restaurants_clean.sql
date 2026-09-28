-- BinGo Map / 49개 맛집 데이터 안전 반영용 SEED
-- 기존 RESTAURANT 행을 삭제하지 않습니다.
-- 같은 NAME + ADDRESS가 이미 있으면 건너뜁니다.
-- 새 행만 SEQ_RESTAURANT.NEXTVAL로 추가합니다.
-- IS_PUBLISHED는 INSERT하지 않으며 테이블 기본값 'N'을 사용합니다.
-- 공개 여부는 02_publication.sql에서 PREVIEW -> APPLY로 처리합니다.
-- 먼저 01_setup.sql을 실행한 뒤 이 파일 전체를 F5로 실행하세요.
-- 확인 후 같은 접속에서 COMMIT; 또는 잘못되면 COMMIT 전에 ROLLBACK; 하세요.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET VERIFY OFF

PROMPT ===== SEED START =====
-- [데이터 1] '타코야끼 쿠쿠루 본점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '타코야끼 쿠쿠루 본점' AS v1, '타코야끼' AS v2, '도톤보리,타코야끼,오사카맛집' AS v3, 4.6 AS v4, 1248 AS v5, '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집' AS v6, '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−10−5 白亜ビル １階' AS v7, 34.6687946 AS v8, 135.4983839 AS v9, '10:30 - 21:30' AS v10, '+81-6-6212-7381' AS v11, '¥500 - ¥1,500' AS v12, 'https://dotonbori-kukuru.com/dotonbori-honten/' AS v13, '20석' AS v14, '예약 불가 (현장 대기)' AS v15, '현금, 신용카드, 전자화폐' AS v16, '일본어, 한국어 메뉴판' AS v17, '/images/store-img/dotonbori/kukuru-takoyaki-shop.png' AS v18, '타코야끼 (8개)' AS v19, '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴' AS v20, '¥1,080' AS v21, '/images/food-img/dotonbori/menu-kukuru-takoyaki.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 2] '호젠지 산페이'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '호젠지 산페이' AS v1, '야끼소바' AS v2, '야끼소바,철판요리,감칠맛' AS v3, 4.4 AS v4, 892 AS v5, '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점' AS v6, '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−7−9 横丁ビル 日宝 1F' AS v7, 34.668900 AS v8, 135.502100 AS v9, '17:00 - 23:00' AS v10, '+81-6-6211-1234' AS v11, '¥700 - ¥1,200' AS v12, 'https://tabelog.com/kr/osaka/A2701/A270202/27011039/?cid=google_yoyaku' AS v13, '15석 (카운터석)' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/dotonbori/hochenji-yakisoba-shop.png' AS v18, '소 힘줄・파・곤약 야끼소바' AS v19, '진한 특제 소스와 쫄깃한 면발의 조화' AS v20, '¥1,650' AS v21, '/images/food-img/dotonbori/menu-hochenji-yakisoba.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 3] '오코노미야끼 치보 도톤보리빌딩점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '오코노미야끼 치보 도톤보리빌딩점' AS v1, '오코노미야끼' AS v2, '오코노미야끼,철판구이,웨이팅맛집' AS v3, 4.5 AS v4, 1102 AS v5, '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장' AS v6, '일본 〒542-0071 Osaka, Chuo Ward, Dotonbori, 1 Chome−5−5 千房道頓堀ビル1～6F' AS v7, 34.668500 AS v8, 135.503200 AS v9, '11:00 - 21:30' AS v10, '+81-6-6212-2211' AS v11, '¥1,000 - ¥2,500' AS v12, 'https://www.chibo.com' AS v13, '50석 (테이블 및 다찌석)' AS v14, '전화 예약 가능' AS v15, '현금, 신용카드, 모바일페이' AS v16, '한국어 지원 (다국어 키오스크)' AS v17, '/images/store-img/dotonbori/chibo-okonomiyaki-shop.png' AS v18, '믹스 파기야키' AS v19, '새우, 오징어, 돼지고기, 파가 모두 들어간 베스트 메뉴' AS v20, '¥1,650' AS v21, '/images/food-img/dotonbori/menu-chibo-okonomiyaki.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 4] '나루토 타이야키 본점 센니치마에 아이조바시점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '나루토 타이야키 본점 센니치마에 아이조바시점' AS v1, '붕어빵' AS v2, '길거리간식,붕어빵,디저트' AS v3, 4.3 AS v4, 567 AS v5, '일본산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵' AS v6, '1 Chome-4-10 Sennichimae, Chuo Ward, Osaka, 542-0074' AS v7, 34.6672921 AS v8, 135.5043207 AS v9, '11:00 - 05:00' AS v10, '+81 6-6212-3838' AS v11, '¥300 - ¥600' AS v12, 'https://www.taiyaki.co.jp/' AS v13, '없음 (테이크아웃 전용)' AS v14, '예약 불가' AS v15, '현금 전용' AS v16, '일본어 메뉴' AS v17, '/images/store-img/dotonbori/naruto-taiyaki-shop.png' AS v18, '통단팥 붕어빵' AS v19, '달콤하고 부드러운 팥이 꽉 찬 인기 간식' AS v20, '¥300' AS v21, '/images/food-img/dotonbori/menu-naruto-taiyaki.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 5] '호타루(쿠시카츠)'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '호타루(쿠시카츠)' AS v1, '쿠시카츠' AS v2, '쿠시카츠,일식꼬치,난바맛집' AS v3, 4.6 AS v4, 620 AS v5, '일식 꼬치 및 튀김 전문점. 아늑하고 편안한 분위기에서 즐기는 정통 쿠시카츠' AS v6, '3 Chome-3-3 Namba, Chuo Ward, Osaka, 542-0076 일본' AS v7, 34.665200 AS v8, 135.501100 AS v9, '12:00 - 22:30' AS v10, '+81 50-5488-7736' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://kd6t800.gorp.jp' AS v13, '테이블석 및 바 테이블' AS v14, '예약 가능 (온라인 주문 가능)' AS v15, '현금, 신용카드, 온라인 결제' AS v16, '일본어' AS v17, '/images/store-img/dotonbori/hotaru-kushikatsu-shop.png' AS v18, '모둠 쿠시카츠 세트' AS v19, '바삭하게 튀겨낸 다양한 수제 꼬치 세트' AS v20, '¥2,500' AS v21, '/images/food-img/dotonbori/menu-hotaru-kushikatsu.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 6] '오뎅야'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '오뎅야' AS v1, '오뎅바' AS v2, '오뎅,이자카야,국물요리,난바맛집' AS v3, 4.4 AS v4, 279 AS v5, '깊고 진한 국물의 정통 어묵 전문 식당. 아늑한 분위기에서 즐기는 수제 오뎅과 술 한잔' AS v6, '1 Chome-3-1 2 F, Dotonbori, Chuo Ward, Osaka 542-0071' AS v7, 34.668200 AS v8, 135.503500 AS v9, '금요일 오후 5:00에 영업 시작' AS v10, '전화번호 문의 (인스타그램 참고)' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://instagram.com' AS v13, '바 테이블 및 일반 테이블' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/dotonbori/odenya-shop.png' AS v18, '모둠 오뎅 세트' AS v19, '부드럽게 우려낸 육수에 무, 스지, 각종 수제 어묵이 들어간 세트' AS v20, '¥1,800' AS v21, '/images/food-img/dotonbori/menu-odenya.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 7] '아카오니 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '아카오니 도톤보리점' AS v1, '타코야끼' AS v2, '타코야끼,도톤보리,미쉐린' AS v3, 4.5 AS v4, 980 AS v5, '생문어를 사용해 신선한 맛을 유지하는 것으로 유명한 타코야끼 명가. 2016~2018년 미쉐린 가이드 3년 연속 소개.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66865 AS v8, 135.50142 AS v9, '10:00 - 22:00' AS v10, NULL AS v11, '¥500 - ¥900' AS v12, 'https://akaoni.tekuteku.net/' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-takoyaki.png' AS v18, '아카오니 타코야끼 (8개)' AS v19, '생문어를 큼직하게 넣은 시그니처 타코야끼' AS v20, '¥750' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 8] '코가류 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '코가류 도톤보리점' AS v1, '타코야끼' AS v2, '타코야끼,가성비,인생맛집' AS v3, 4.4 AS v4, 1520 AS v5, '크기는 작지만 부드러운 식감과 저렴한 가격으로 유명한 타코야끼 전문점. 파를 듬뿍 올려 먹는 것이 포인트.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66880 AS v8, 135.50108 AS v9, '10:00 - 21:00' AS v10, NULL AS v11, '¥400 - ¥700' AS v12, 'http://www.kogaryu.jp/' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/food-takoyaki.png' AS v18, '소스마요 타코야끼 (8개)' AS v19, '소스와 마요네즈의 조화가 좋은 인기 메뉴' AS v20, '¥500' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 9] '오도리다코'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '오도리다코' AS v1, '타코야끼' AS v2, '타코야끼,SNS맛집,문어' AS v3, 4.3 AS v4, 2100 AS v5, '타코야끼 1개마다 주꾸미를 통째로 넣어 SNS에서 화제가 된 곳. 소스/간장/암염 맛 선택 가능.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-8-26' AS v7, 34.66872 AS v8, 135.50130 AS v9, '11:00 - 21:00' AS v10, NULL AS v11, '¥600 - ¥1,200' AS v12, 'https://odoridako.com/' AS v13, '매장 내 좌석 없음 (스탠딩)' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어, 영어' AS v17, '/images/food-takoyaki.png' AS v18, '오도리다코 타코야끼 (4개)' AS v19, '주꾸미 한 마리가 통째로 들어간 시그니처 메뉴' AS v20, '¥600' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 10] '미즈노 도톤보리 본점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '미즈노 도톤보리 본점' AS v1, '오코노미야끼' AS v2, '오코노미야끼,노포,웨이팅맛집' AS v3, 4.6 AS v4, 3400 AS v5, '오랜 역사를 자랑하는 오코노미야끼 노포. 야마이모(참마)를 넣어 폭신한 식감이 특징.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-4-15' AS v7, 34.66890 AS v8, 135.50118 AS v9, '11:00 - 22:00 (목요일 휴무)' AS v10, NULL AS v11, '¥1,200 - ¥2,500' AS v12, 'https://www.mizuno-osaka.com/' AS v13, '카운터석, 철판 테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어' AS v17, '/images/food-okonomiyaki.png' AS v18, '야마이모야키' AS v19, '참마를 듬뿍 넣어 폭신하게 구운 미즈노 대표 메뉴' AS v20, '¥1,800' AS v21, 'https://via.placeholder.com/64?text=Okonomiyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 11] '앗치치 혼포'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '앗치치 혼포' AS v1, '타코야끼' AS v2, '타코야끼,겉바속촉' AS v3, 4.3 AS v4, 870 AS v5, '일반 구리 철판 대신 전문 조리 기술이 필요한 특수 철판을 사용하는 타코야끼 전문점.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66858 AS v8, 135.50095 AS v9, '10:00 - 21:00' AS v10, NULL AS v11, '¥500 - ¥900' AS v12, 'http://www.acchichihonpo.com/' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/food-takoyaki.png' AS v18, '네기 타코야끼' AS v19, '파를 듬뿍 올린 달콤한 소스의 타코야끼' AS v20, '¥600' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 12] '주하치방 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '주하치방 도톤보리점' AS v1, '타코야끼' AS v2, '타코야끼,바삭한식감,오사카노포' AS v3, 4.2 AS v4, 640 AS v5, '텐카스(튀김 부스러기)를 가득 넣어 바삭한 식감을 강조한 오사카 오랜 타코야끼 전문점.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66850 AS v8, 135.50085 AS v9, '11:00 - 20:00' AS v10, NULL AS v11, '¥400 - ¥800' AS v12, 'https://www.takoyaki18ban.com/' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/food-takoyaki.png' AS v18, '텐카스 타코야끼' AS v19, '텐카스를 가득 넣어 겉이 유난히 바삭한 타코야끼' AS v20, '¥550' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 13] 'CREO-RU 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT 'CREO-RU 도톤보리점' AS v1, '오사카명물' AS v2, '타코야끼,오코노미야끼,쿠시카츠,단체석' AS v3, 4.4 AS v4, 1230 AS v5, '오사카 3대 명물(타코야끼·오코노미야끼·쿠시카츠)을 한 곳에서 즐길 수 있는 120석 규모의 대형 매장.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66840 AS v8, 135.50160 AS v9, '11:00 - 23:00' AS v10, NULL AS v11, '¥1,000 - ¥3,000' AS v12, 'https://www.creo-ru.com/' AS v13, '120석 (단체석 가능)' AS v14, '전화 예약 가능' AS v15, '현금, 신용카드, 모바일페이' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-okonomiyaki.png' AS v18, '7종 반죽 타코야끼' AS v19, '7가지 가루를 혼합한 반죽으로 만든 겉바속촉 타코야끼' AS v20, '¥900' AS v21, 'https://via.placeholder.com/64?text=Takoyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 14] '츠루하시 후게쓰 도톤보리 에비스바시점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '츠루하시 후게쓰 도톤보리 에비스바시점' AS v1, '오코노미야끼' AS v2, '오코노미야끼,이자카야,철판요리' AS v3, 4.3 AS v4, 1890 AS v5, '테이블마다 철판이 있어 눈앞에서 구워주는 오코노미야끼로 유명한 인기 이자카야 체인.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66822 AS v8, 135.50175 AS v9, '11:00 - 23:00' AS v10, NULL AS v11, '¥1,000 - ¥2,000' AS v12, 'https://www.fugetsu.jp/' AS v13, '테이블 철판석' AS v14, '예약 가능(좌석에 따라)' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어' AS v17, '/images/food-okonomiyaki.png' AS v18, '부타타마 오코노미야끼' AS v19, '돼지고기와 계란이 들어간 대표 오코노미야끼' AS v20, '¥1,050' AS v21, 'https://via.placeholder.com/64?text=Okonomiyaki' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 15] '킹에몬 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '킹에몬 도톤보리점' AS v1, '라멘' AS v2, '라멘,흑간장,24시간' AS v3, 4.4 AS v4, 2760 AS v5, '나니와 최강 간장 라멘으로 유명한 24시간 영업 라멘 전문점. 흑간장 스프에 해산물 감칠맛이 특징.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-4-17' AS v7, 34.66895 AS v8, 135.50122 AS v9, '11:00 - 익일 08:00' AS v10, '06-6211-5502' AS v11, '~¥1,000' AS v12, 'http://king-emon-dotonbori.com/' AS v13, '카운터석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-ramen.png' AS v18, '킹에몬 흑간장 라멘' AS v19, '간장 풍미와 신선한 해산물이 어우러진 흑간장 라멘' AS v20, '¥890' AS v21, 'https://via.placeholder.com/64?text=Ramen' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 16] '킨류 라멘 도톤보리 본점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '킨류 라멘 도톤보리 본점' AS v1, '라멘' AS v2, '라멘,돈코츠,랜드마크' AS v3, 4.2 AS v4, 3980 AS v5, '주홍색 외벽과 거대한 용 오브제로 유명한 도톤보리의 랜드마크 라멘집. 진한 돈코츠 스프가 특징.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66810 AS v8, 135.50200 AS v9, '24시간 영업' AS v10, NULL AS v11, '¥700 - ¥1,000' AS v12, 'https://kinryuramen.com/' AS v13, '테이블석, 좌식석' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어, 영어' AS v17, '/images/food-ramen.png' AS v18, '킨류 라멘' AS v19, '진한 돈코츠 스프에 부추와 마늘을 곁들이는 대표 메뉴' AS v20, '¥800' AS v21, 'https://via.placeholder.com/64?text=Ramen' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 17] '시센노 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '시센노 도톤보리점' AS v1, '라멘' AS v2, '라멘,미소라멘' AS v3, 4.1 AS v4, 560 AS v5, '진한 미소(된장) 라멘으로 유명한 라멘 격전구 도톤보리의 전문점.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66798 AS v8, 135.50188 AS v9, '11:00 - 23:00' AS v10, NULL AS v11, '¥800 - ¥1,100' AS v12, 'https://www.shisen-no.com/' AS v13, '카운터석' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/food-ramen.png' AS v18, '시센노 미소라멘' AS v19, '진하고 깊은 맛의 미소 베이스 라멘' AS v20, '¥950' AS v21, 'https://via.placeholder.com/64?text=Ramen' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 18] '나니와 멘지로'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '나니와 멘지로' AS v1, '라멘' AS v2, '라멘,조개육수,라멘마니아성지' AS v3, 4.6 AS v4, 1340 AS v5, '2019년 오픈 이후 라멘 마니아의 성지가 된 곳. 조개 육수 베이스의 황금 조개 라멘이 대표 메뉴.' AS v6, '오사카부 오사카시 주오구 난바' AS v7, 34.66650 AS v8, 135.50120 AS v9, '11:00 - 21:00' AS v10, NULL AS v11, '¥900 - ¥1,300' AS v12, 'https://naniwa-menjiro.com/' AS v13, '카운터석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-ramen.png' AS v18, '황금 조개 라멘' AS v19, '조개 육수 베이스의 투명한 황금빛 라멘' AS v20, '¥1,050' AS v21, 'https://via.placeholder.com/64?text=Ramen' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 19] '쿠시카츠 다루마 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '쿠시카츠 다루마 도톤보리점' AS v1, '쿠시카츠' AS v2, '쿠시카츠,두번찍기금지,오사카명물' AS v3, 4.3 AS v4, 4200 AS v5, '거대한 아저씨 간판으로 유명한 쿠시카츠 전문점. "두 번 찍기 금지"라는 오사카식 룰로도 유명.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66795 AS v8, 135.50210 AS v9, '11:00 - 22:30' AS v10, NULL AS v11, '¥100 - ¥300 (꼬치 1개)' AS v12, 'https://www.kushikatu-daruma.com/' AS v13, '카운터석, 테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-kushikatsu.png' AS v18, '쿠시카츠 모둠 (10개)' AS v19, '소고기, 새우, 채소 등 다양한 재료의 꼬치튀김 모둠' AS v20, '¥1,500' AS v21, 'https://via.placeholder.com/64?text=Kushikatsu' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 20] '이치란 라멘 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '이치란 라멘 도톤보리점' AS v1, '라멘' AS v2, '라멘,돈코츠,1인칸막이석' AS v3, 4.2 AS v4, 5600 AS v5, '일본을 대표하는 돈코츠 라멘 체인점. 1인 칸막이 좌석과 나만의 맛 주문표가 특징.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66765 AS v8, 135.50220 AS v9, '24시간 영업' AS v10, NULL AS v11, '¥900 - ¥1,300' AS v12, 'https://ichiran.com/' AS v13, '1인 칸막이석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-ramen.png' AS v18, '이치란 라멘' AS v19, '나만의 맛 주문표로 커스텀하는 돈코츠 라멘' AS v20, '¥980' AS v21, 'https://via.placeholder.com/64?text=Ramen' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 21] '카니도라쿠 도톤보리 본점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '카니도라쿠 도톤보리 본점' AS v1, '게요리' AS v2, '게요리,랜드마크,대형간판' AS v3, 4.4 AS v4, 6100 AS v5, '다리가 움직이는 대형 게 간판으로 도톤보리를 상징하는 게요리 전문점. 회, 샤브샤브, 초밥 등 제공.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-6-18' AS v7, 34.66830 AS v8, 135.50148 AS v9, '11:00 - 22:00' AS v10, NULL AS v11, '¥3,000 - ¥10,000' AS v12, 'https://douraku.co.jp/kansai/honten/' AS v13, '테이블석, 개인실' AS v14, '전화 예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-crab.png' AS v18, '게 코스 요리' AS v19, '바다참게·킹크랩·털게 중 선택하는 게 코스' AS v20, '¥5,500' AS v21, 'https://via.placeholder.com/64?text=Crab' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 22] '가무쿠라 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '가무쿠라 도톤보리점' AS v1, '디저트' AS v2, '디저트,간식,테이크아웃' AS v3, 4.0 AS v4, 320 AS v5, '가볍게 즐길 수 있는 테이크아웃 디저트/간식 전문점.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-7-25' AS v7, 34.66875 AS v8, 135.50175 AS v9, '10:00 - 20:00' AS v10, NULL AS v11, '¥300 - ¥700' AS v12, 'https://kamukura.co.jp/shop/18/' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/food-dessert.png' AS v18, '시그니처 디저트 세트' AS v19, '가게 대표 디저트 메뉴' AS v20, '¥450' AS v21, 'https://via.placeholder.com/64?text=Dessert' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 23] '마루요시 스시'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '마루요시 스시' AS v1, '초밥' AS v2, '초밥,가성비,사쿠라가와' AS v3, 4.3 AS v4, 410 AS v5, '난바 근처 사쿠라가와 지역의 가성비 좋은 초밥 세트 전문점.' AS v6, '오사카부 오사카시 주오구 사쿠라가와' AS v7, 34.66600 AS v8, 135.50050 AS v9, '11:30 - 21:00' AS v10, NULL AS v11, '¥1,500 -' AS v12, 'https://maruyoshi-sushi.com/' AS v13, '카운터석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-sushi.png' AS v18, '초밥 세트' AS v19, '저렴한 가격의 초밥 모둠 세트' AS v20, '¥1,500' AS v21, 'https://via.placeholder.com/64?text=Sushi' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 24] '우오신 스시 미나미점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '우오신 스시 미나미점' AS v1, '초밥' AS v2, '초밥,대형초밥,아나고' AS v3, 4.5 AS v4, 890 AS v5, '보통 초밥의 세 배 크기 생선이 올라간 큼직한 초밥으로 유명한 전문점.' AS v6, '오사카부 오사카시 주오구 난바' AS v7, 34.66700 AS v8, 135.50080 AS v9, '11:00 - 22:00' AS v10, NULL AS v11, '¥1,000 - ¥2,000' AS v12, 'https://uoshin-sushi.com/' AS v13, '카운터석, 테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-sushi.png' AS v18, '아나고 엔니기리' AS v19, '부드러운 붕장어에 구수한 소스를 곁들인 초밥' AS v20, '¥600' AS v21, 'https://via.placeholder.com/64?text=Sushi' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 25] '스시로 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '스시로 도톤보리점' AS v1, '회전초밥' AS v2, '회전초밥,체인,가족단위' AS v3, 4.3 AS v4, 3120 AS v5, '도톤보리 한가운데 위치한 인기 회전초밥 체인점. 신선한 해산물과 합리적인 가격이 강점.' AS v6, '오사카부 오사카시 주오구 도톤보리 1-7-21' AS v7, 34.66876 AS v8, 135.50128 AS v9, '11:00 - 23:00' AS v10, NULL AS v11, '¥110 - ¥500 (접시당)' AS v12, 'https://www.akindo-sushiro.co.jp/' AS v13, '테이블석, 카운터석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-sushi.png' AS v18, '모둠 초밥 세트' AS v19, '마구로, 사케, 하마치, 에비 등 인기 메뉴 모둠' AS v20, '¥980' AS v21, 'https://via.placeholder.com/64?text=Sushi' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 26] '다이키 수산 회전초밥 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '다이키 수산 회전초밥 도톤보리점' AS v1, '회전초밥' AS v2, '회전초밥,다국어메뉴,가성비' AS v3, 4.2 AS v4, 2480 AS v5, '오사카 대표 회전초밥 체인. 다국어 메뉴 제공으로 외국인 관광객에게 인기.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66740 AS v8, 135.50230 AS v9, '11:00 - 22:00' AS v10, NULL AS v11, '¥100 - ¥400 (접시당)' AS v12, 'https://www.daiki-suisan.co.jp/' AS v13, '테이블석, 카운터석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-sushi.png' AS v18, '참치·새우 모둠' AS v19, '참치, 새우(2개 100엔)부터 즐기는 인기 모둠' AS v20, '¥600' AS v21, 'https://via.placeholder.com/64?text=Sushi' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 27] '하리주 카레'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '하리주 카레' AS v1, '카레' AS v2, '카레,노포,메이지시대' AS v3, 4.5 AS v4, 2100 AS v5, '메이지 시대에 창업한 오사카 전통 카레 전문점. 일본 최초로 계란을 카레에 올린 곳으로 알려짐.' AS v6, '오사카부 오사카시 주오구 난바 3-1-34' AS v7, 34.66600 AS v8, 135.50100 AS v9, '11:00 - 20:00 (월요일 휴무)' AS v10, NULL AS v11, '¥900 - ¥1,500' AS v12, 'https://www.hariju.co.jp/' AS v13, '카운터석, 테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-curry.png' AS v18, '다마고 카레' AS v19, '일본 최초로 계란을 올린 시그니처 카레' AS v20, '¥1,100' AS v21, 'https://via.placeholder.com/64?text=Curry' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 28] '오사카 오쇼 도톤보리점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '오사카 오쇼 도톤보리점' AS v1, '교자' AS v2, '교자,중화요리,체인' AS v3, 4.1 AS v4, 1560 AS v5, '오사카에서 인기 있는 교자(만두) 전문 중화요리 체인점. 도톤보리 매장은 큰 간판으로도 유명.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66780 AS v8, 135.50250 AS v9, '11:00 - 23:00' AS v10, NULL AS v11, '¥700 - ¥1,500' AS v12, 'https://www.osaka-ohsho.com/' AS v13, '테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 중국어' AS v17, '/images/food-gyoza.png' AS v18, '야끼교자 (6개)' AS v19, '겉바속촉 육즙 가득한 오사카 오쇼 대표 만두' AS v20, '¥250' AS v21, 'https://via.placeholder.com/64?text=Gyoza' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 29] '도톤보리 이마이'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '도톤보리 이마이' AS v1, '우동' AS v2, '우동,노포,기츠네우동' AS v3, 4.6 AS v4, 1980 AS v5, '70년 이상의 역사를 자랑하는 오사카 우동 노포. 큼직한 유부를 올린 기츠네 우동이 간판 메뉴.' AS v6, '오사카부 오사카시 주오구 도톤보리' AS v7, 34.66790 AS v8, 135.50180 AS v9, '11:00 - 22:00' AS v10, NULL AS v11, '¥900 - ¥1,500' AS v12, 'https://www.d-imai.com/' AS v13, '다다미석, 테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/food-udon.png' AS v18, '기츠네 우동' AS v19, '홋카이도 다시마와 규슈 가다랑어포로 우려낸 국물의 유부우동' AS v20, '¥1,050' AS v21, 'https://via.placeholder.com/64?text=Udon' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 30] '규카츠 모토무라 난바점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '규카츠 모토무라 난바점' AS v1, '규카츠' AS v2, '규카츠,난바,웨이팅맛집' AS v3, 4.5 AS v4, 4700 AS v5, '일본 각지에 체인을 둔 규카츠(소고기 커틀릿) 전문점 중 가장 인기 있는 난바점. 화로에 직접 구워 먹는 방식.' AS v6, '오사카부 오사카시 주오구 난바' AS v7, 34.66430 AS v8, 135.50190 AS v9, '10:45 - 22:00' AS v10, NULL AS v11, '¥1,300 - ¥2,200' AS v12, 'https://www.gyukatsu-motomura.com/' AS v13, '카운터석, 테이블석' AS v14, '예약 불가 (현장 대기)' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어, 중국어' AS v17, '/images/food-gyukatsu.png' AS v18, '규카츠 정식' AS v19, '개인 화로에 취향껏 구워 먹는 소고기 커틀릿 정식' AS v20, '¥1,780' AS v21, 'https://via.placeholder.com/64?text=Gyukatsu' AS v22, 'N' AS v23
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 31] '아부리야우메다점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '아부리야우메다점' AS v1, '야키니쿠' AS v2, '야키니쿠,무한리필,소고기,우메다맛집' AS v3, 4.4 AS v4, 1297 AS v5, '법, 채소와 함께 고기를 테이블에서 무한 리필로 구워 먹을 수 있는 편안한 식당입니다.' AS v6, '일본 〒530-0057 Osaka, Kita Ward, Sonezaki, 2 Chome−15−20 SWINGうめだ 4階' AS v7, 34.701200 AS v8, 135.500200 AS v9, '11:00 - 24:00' AS v10, '+81 6-6361-1129' AS v11, '¥5,000 - ¥8,000' AS v12, 'https://aburiya.1dining.co.jp' AS v13, '테이블석 (무한리필)' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/couse-aburiya-low-kokusangyu-shop.png' AS v18, '국산규 야키니쿠 무한리필 코스' AS v19, '엄선된 소고기 구이 및 다양한 사이드 메뉴 무한리필' AS v20, '¥6,500' AS v21, '/images/food-img/umeda/menu-couse-aburiya-low-kokusangyu.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 32] '불고기 잭 우메다점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '불고기 잭 우메다점' AS v1, '야키니쿠' AS v2, '야키니쿠,고기구이,우메다' AS v3, 4.5 AS v4, 2185 AS v5, '야키니쿠 전문식당. 질 좋은 고기를 합리적인 가격에 즐길 수 있는 인기 매장.' AS v6, '일본 〒530-0027 Osaka, Kita Ward, Doyamacho, 2-11 MKビートビル 3F' AS v7, 34.703500 AS v8, 135.505000 AS v9, '16:00 - 24:00' AS v10, '+81 50-5462-8743' AS v11, '¥4,000 - ¥6,000' AS v12, 'https://yakinikujack-umeda.foodre.jp/?utm_contents=website_link' AS v13, '테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/bulgogi-jack-umeda-branch-shop.png' AS v18, '잭 프리미엄 세트' AS v19, '다양한 부위의 소고기를 맛볼 수 있는 모둠 세트' AS v20, '¥4,980' AS v21, '/images/food-img/umeda/menu-bulgogi-jack-umeda-branch.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 33] '규카츠 교토가츠규 우메다점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '규카츠 교토가츠규 우메다점' AS v1, '규카츠' AS v2, '규카츠,소고기카틀릿,우메다맛집' AS v3, 4.8 AS v4, 10111 AS v5, '겉은 바삭하고 속은 촉촉한 부드러운 소고기 규카츠 전문점' AS v6, '일본 〒530-0012 Osaka, Kita Ward, Shibata, 1 Chome−1−27 サセウメダビル B1F' AS v7, 34.704200 AS v8, 135.498800 AS v9, '11:00 - 22:00' AS v10, '+81 6-6376-3300' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://gyukatsu-kyotokatsugyu.com' AS v13, '카운터석 및 테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어' AS v17, '/images/store-img/umeda/gyukatsu-kyoto-katsukyu-shop.png' AS v18, '살치살 규카츠 정식' AS v19, '특제 보리밥과 다채로운 소스와 함께 즐기는 규카츠 정식' AS v20, '¥2,079' AS v21, '/images/food-img/umeda/menu-gyukatsu-kyoto-katsukyu.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 34] '모헤지 우메다 루쿠아점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '모헤지 우메다 루쿠아점' AS v1, '몬자야끼' AS v2, '몬자야끼,철판요리,루쿠아,우메다' AS v3, 4.9 AS v4, 11796 AS v5, '철판 위에서 직접 조리해 먹는 독특하고 고소한 맛의 몬자야끼 전문점.' AS v6, '10층 루쿠아 오사카, 일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome−1−3 ルクア大阪 10階' AS v7, 34.701500 AS v8, 135.495500 AS v9, '11:00 - 23:00' AS v10, '+81 6-6867-9525' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://www.instagram.com/moheji_osaka/' AS v13, '철판 테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/moheji-umeda-shop.png' AS v18, '명란 명태알 몬자야끼' AS v19, '명란과 모짜렐라 치즈가 듬뿍 들어간 베스트 몬자야끼' AS v20, '¥1,580' AS v21, '/images/food-img/umeda/menu-moheji-umeda.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 35] '하카타 모츠나베 오오야마 오사카역점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '하카타 모츠나베 오오야마 오사카역점' AS v1, '모츠나베' AS v2, '모츠나베,곱창전골,국물요리,우메다' AS v3, 4.6 AS v4, 1205 AS v5, '진한 된장 베이스 육수와 고소한 소곱창이 어우러진 하카타 정통 모츠나베 전문점' AS v6, '10층 · 루쿠아1100, 일본 〒530-8558 Osaka, Kita Ward, Umeda, 3 Chome−1−3 ルクアイーレ 10階' AS v7, 34.701700 AS v8, 135.495300 AS v9, '11:00 - 23:00' AS v10, '+81 6-6151-1411' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://motu-ooyama.com' AS v13, '테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/hakata-motsunabe-ohyama-osaka-station-branch-shop.png' AS v18, '된장맛 모츠나베 세트' AS v19, '특제 된장 육수와 엄선된 한우 곱창의 깊은 맛' AS v20, '¥1,980' AS v21, '/images/food-img/umeda/menu-hakata-motsunabe-ohyama-osaka-station-branch.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 36] '스키야키 샤브샤브 츠카다 킷테오사카점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '스키야키 샤브샤브 츠카다 킷테오사카점' AS v1, '스키야키' AS v2, '스키야키,샤브샤브,고급요리,킷테오사카' AS v3, 4.8 AS v4, 4542 AS v5, '정갈한 분위기에서 즐기는 고급 스키야키 및 샤브샤브 전문점' AS v6, '1층 · 킷테 오사카, 일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome−2−2 KITTE大阪 5F' AS v7, 34.700500 AS v8, 135.494500 AS v9, '11:00 - 23:00' AS v10, '+81 50-1720-8664' AS v11, '¥2,000 - ¥8,000' AS v12, 'https://e.japanticket.com/shops/5440' AS v13, '테이블석 및 개인실' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어' AS v17, '/images/store-img/umeda/sukiyaki-shabu-shabu-tsukada-kitage-osaka-branch-shop.png' AS v18, '특선 스키야키 정식' AS v19, '달콤 짭조름한 특제 소스에 부드러운 소고기를 익혀 날계란에 찍어 먹는 정식' AS v20, '¥3,200' AS v21, '/images/food-img/umeda/menu-sukiyaki shabu-shabu tsukada-kitage osaka-branch.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 37] '하나다코'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '하나다코' AS v1, '타코야끼' AS v2, '타코야끼,우메다맛집,파마요리타코야끼,줄서는맛집' AS v3, 4.2 AS v4, 4582 AS v5, '문어가 들어간 둥근 반죽을 구워 파와 마요네즈를 얹은 음식인 다코야끼를 파는 식당입니다.' AS v6, '일본 〒530-0017 Osaka, Kita Ward, Kakudacho, 9-26 大阪新梅田食道街 1 階' AS v7, 34.703800 AS v8, 135.499500 AS v9, '10:00 - 21:45' AS v10, '+81 6-6361-7518' AS v11, '¥1 - ¥1,000' AS v12, 'https://shinume.com' AS v13, '스탠딩석 / 테이크아웃' AS v14, '예약 불가' AS v15, '현금 전용' AS v16, '일본어' AS v17, '/images/store-img/umeda/hanadako-shop.png' AS v18, '네기마요 타코야끼' AS v19, '알싸한 대파가 산더미처럼 올라간 특제 마요네즈 타코야끼' AS v20, '¥780' AS v21, '/images/food-img/umeda/menu-hanadako.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 38] '신세카이 칸칸'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '신세카이 칸칸' AS v1, '타코야끼' AS v2, '타코야끼,신세카이,간식' AS v3, 4.2 AS v4, 593 AS v5, '옛날 느낌의 카운터 주문형 식당으로 풍미 넘치는 재료를 넣어 동그란 모양으로 반죽한 튀김을 선보입니다.' AS v6, '3 Chome-5-16 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본' AS v7, 34.653000 AS v8, 135.505000 AS v9, '9:30 - 18:00' AS v10, '+81 6-6636-2915' AS v11, '¥1 - ¥1,000' AS v12, ' ' AS v13, '카운터석 / 테이크아웃' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/store-img/shinsaibashi/takoyaki-shop.png' AS v18, '타코야끼' AS v19, '겉은 바삭하고 속은 촉촉한 전통 타코야끼' AS v20, '¥500' AS v21, '/images/food-img/shinsaibashi/menu-takoyaki.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 39] '신세계 꼬치 커틀릿·오코노미 야키 아파레'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '신세계 꼬치 커틀릿·오코노미 야키 아파레' AS v1, '쿠시카츠' AS v2, '쿠시카츠,오코노미야끼,일식튀김' AS v3, 4.1 AS v4, 970 AS v5, '일식 꼬치 및 튀김 전문점, 정통 쿠시카츠와 철판요리를 함께 즐길 수 있습니다.' AS v6, '2 Chome-5-1 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본' AS v7, 34.652500 AS v8, 135.504800 AS v9, '11:00 - 02:00' AS v10, '+81 6-4393-8950' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://tabelog.com/kr/osaka/A2701/A270206/27145766/' AS v13, '테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/shinsaibashi/kushikatsu-shop.png' AS v18, '모둠 쿠시카츠 5종' AS v19, '바삭하게 튀겨낸 신세카이 스타일의 수제 꼬치' AS v20, '¥1,200' AS v21, '/images/food-img/shinsaibashi/menu-kushikatsu.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 40] '호르몬 야키니쿠 시치푸쿠'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '호르몬 야키니쿠 시치푸쿠' AS v1, '야키니쿠' AS v2, '야키니쿠,호르몬,곱창구이,신세카이' AS v3, 4.1 AS v4, 318 AS v5, '쿠시카츠와 숯불 곱창을 포장해 주는 칠복을 전해드립니다!' AS v6, '2 Chome-6-21 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본' AS v7, 34.652200 AS v8, 135.504500 AS v9, '11:30 - 24:00' AS v10, '+81 6-6631-0298' AS v11, '¥1,000 - ¥4,000' AS v12, 'https://owst.jp' AS v13, '테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어' AS v17, '/images/store-img/shinsaibashi/yakiniku-shop.png' AS v18, '호르몬 모둠구이' AS v19, '신선한 소 곱창과 내장을 숯불에 구워 먹는 대표 메뉴' AS v20, '¥1,500' AS v21, '/images/food-img/shinsaibashi/menu-yakiniku.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 41] '쿠라스시 신세카이 츠텐카쿠점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '쿠라스시 신세카이 츠텐카쿠점' AS v1, '회전초밥' AS v2, '회전초밥,가성비,체인점,츠텐카쿠' AS v3, 3.8 AS v4, 2142 AS v5, '쓰텐카쿠 미나미도리 쇼점가에 위치한 인기 대형 회전초밥 체인점' AS v6, '일본 〒556-0002 Osaka, Naniwa Ward, Ebisuhigashi, 2 Chome−6-3 2F' AS v7, 34.652000 AS v8, 135.504200 AS v9, '영업 중 · 오전 12:00에 영업 종료' AS v10, '+81 6-6632-6101' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://www.kurasushi.co.jp' AS v13, '테이블석 (접시 회전 시스템)' AS v14, '예약 가능 (온라인 가능)' AS v15, '현금, 신용카드, 전자화폐' AS v16, '일본어, 영어, 한국어' AS v17, '/images/store-img/shinsaibashi/shin-kushikatsu-shop.png' AS v18, '초밥 접시 세트' AS v19, '다양한 신선한 초밥과 사이드 메뉴' AS v20, '¥300 ~ 1,100' AS v21, '/images/food-img/shinsaibashi/menu-sushi.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 42] '곤베 호루몬 우동'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '곤베 호루몬 우동' AS v1, '우동' AS v2, '우동,곱창우동,노포,신세카이시장' AS v3, 4.2 AS v4, 567 AS v5, '곱창구이 전문점. 진한 국물과 쫄깃한 우동 면발에 고소한 곱창이 어우러진 별미 우동.' AS v6, '1 Chome-23-5 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본' AS v7, 34.651500 AS v8, 135.504000 AS v9, '24:00 - 07:00' AS v10, '+81 6-6631-4841' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://x.com/gonbee_horumon' AS v13, '카운터석' AS v14, '예약 불가' AS v15, '현금' AS v16, '일본어' AS v17, '/images/store-img/shinsaibashi/udon-shop.png' AS v18, '호루몬 우동' AS v19, '특제 소스로 볶아낸 곱창이 듬뿍 들어간 얼큰한 우동' AS v20, '¥950' AS v21, '/images/food-img/shinsaibashi/menu-udon.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 43] 'Fumichan'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT 'Fumichan' AS v1, '타코야끼' AS v2, '타코야끼,테이크아웃,신세카이' AS v3, 4.6 AS v4, 338 AS v5, '다코야끼 전문점. 겉은 바삭하고 속은 부드러운 오사카 정통 길거리 간식.' AS v6, '2 Chome-2-8 Ebisunishi, Naniwa Ward, Osaka, 556-0003 일본' AS v7, 34.651000 AS v8, 135.503500 AS v9, '영업 중 · 오전 12:00에 영업 종료' AS v10, '+81 6-6631-0541' AS v11, '¥1 - ¥1,000' AS v12, 'https://adx7.byoubu.com' AS v13, '테이크아웃 전용' AS v14, '예약 불가' AS v15, '현금 전용' AS v16, '일본어' AS v17, '/images/store-img/shinsaibashi/fumichan-takoyaki-shop.png' AS v18, '후미찬 타코야끼 (8개)' AS v19, '가성비 좋은 담백하고 고소한 타코야끼' AS v20, '¥500' AS v21, '/images/food-img/shinsaibashi/menu-fumichan-takoyaki.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 44] '신세카이 쿠시카츠 잇토쿠 신세카이점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '신세카이 쿠시카츠 잇토쿠 신세카이점' AS v1, '쿠시카츠' AS v2, '쿠시카츠,일식꼬치,신세카이맛집' AS v3, 4.4 AS v4, 1286 AS v5, '일식 꼬치 및 튀김 전문점 바삭한 튀김옷과 특제 소스의 조화가 일품인 쿠시카츠 전문점.' AS v6, '2 Chome-3-18 Ebisuhigashi, Naniwa Ward, Osaka, 556-0002 일본' AS v7, 34.652800 AS v8, 135.505200 AS v9, '11:00~23:00' AS v10, '+81 6-6632-9499' AS v11, '¥2,000 - ¥3,000' AS v12, 'https://kushikatsuittoku.com/store/?id=karasaki' AS v13, '테이블석 및 카운터석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어, 한국어' AS v17, '/images/store-img/shinsaibashi/shin-kushikatsu-shop.png' AS v18, '잇토쿠 모둠 꼬치 세트' AS v19, '다양한 고기와 채소 튀김을 맛볼 수 있는 세트 메뉴' AS v20, '¥1,600' AS v21, '/images/food-img/shinsaibashi/shin-menu-kushikatsu-shop.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 45] '오니기리 고리짱 난바점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '오니기리 고리짱 난바점' AS v1, '기타' AS v2, '오니기리,주먹밥,난바맛집,테이크아웃' AS v3, 4.9 AS v4, 11908 AS v5, '다양한 속재료가 들어간 맛있는 수제 오니기리와 일본 전통 음식을 즐길 수 있는 테이크아웃 전문 맛집.' AS v6, '일본 〒542-0081 Osaka, Chuo Ward, Minamisenba, 3 Chome-5-28 富士ビル南船場 1階' AS v7, 34.673800 AS v8, 135.501200 AS v9, '10:00~21:00' AS v10, '+81 6-6484-8325' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://forms.gle' AS v13, '테이크아웃 전문' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/dotonbori/onigiri-shop.png' AS v18, '시그니처 명란 오니기리' AS v19, '특제 소스와 듬뿍 올라간 명란이 조화로운 주먹밥' AS v20, '¥450' AS v21, '/images/food-img/dotonbori/menu-onigiri.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 46] 'Kiiro'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT 'Kiiro' AS v1, '기타' AS v2, '이자카야,신사이바시맛집,술집' AS v3, 4.1 AS v4, 231 AS v5, '아늑한 분위기에서 다양한 안주와 주류를 즐길 수 있는 신사이바시 인근의 인기 이자카야.' AS v6, 'Neo Minamisenba Bldg., 2 Chome-7-19 Minamisenba, Chuo Ward, Osaka, 542-0081 일본' AS v7, 34.675100 AS v8, 135.503400 AS v9, '11:30~23:00' AS v10, '+81 6-6264-1776' AS v11, '¥1,000 - ¥1,000' AS v12, 'https://instagram.com' AS v13, '테이블석' AS v14, '예약 가능' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/dotonbori/izakaya-shop.png' AS v18, '모둠 사시미' AS v19, '신선한 제철 해산물을 맛볼 수 있는 대표 메뉴' AS v20, '¥1,800' AS v21, '/images/food-img/dotonbori/menu-izakaya.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 47] '야타이탄탄멘 타부쨩'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '야타이탄탄멘 타부쨩' AS v1, '기타' AS v2, '탄탄멘,라멘,도톤보리맛집,난바' AS v3, 4.6 AS v4, 662 AS v5, '든든한 국수 요리를 파는 고풍스럽고 소박한 레스토랑으로 종이 등불과 복고풍 인테리어가 특징입니다.' AS v6, '일본 〒542-0074 Osaka, Chuo Ward, Sennichimae, 1 Chome-6-1 山喜登会館 1층·百羅' AS v7, 34.667200 AS v8, 135.505600 AS v9, '17:00 - 01:00' AS v10, '+81 80-8532-1239' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://instagram.com' AS v13, '카운터석 및 테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/dotonbori/tabuchan-tantanmen-shop.png' AS v18, '오리지널 탄탄멘' AS v19, '깊고 진한 육수와 특제 고기 고명이 올라간 매콤한 탄탄멘' AS v20, '¥950' AS v21, '/images/food-img/dotonbori/menu-tabuchan-tantanmen.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 48] '코메다커피 KITTE오사카점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '코메다커피 KITTE오사카점' AS v1, '기타' AS v2, '카페,우메다맛집,커피,디저트' AS v3, 3.9 AS v4, 27 AS v5, '우메다 킷테 오사카 내에 위치하여 편안한 분위기에서 커피와 디저트를 즐길 수 있는 유명 카페.' AS v6, '일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome-2-2 KITTE大阪' AS v7, 34.701200 AS v8, 135.495200 AS v9, '08:00 - 21:00' AS v10, '+81 6-6940-6118' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://komeda.co.jp' AS v13, '테이블석' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/komeda-shop.png' AS v18, '시로누와르' AS v19, '따뜻한 데니쉬 페이스트리 위에 부드러운 소프트아이스크림이 올라간 디저트' AS v20, '¥700' AS v21, '/images/food-img/umeda/menu-komeda.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

-- [데이터 49] '하브스 테이크아웃숍 다이마루 우메다점'
INSERT INTO RESTAURANT (RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL)
SELECT SEQ_RESTAURANT.NEXTVAL, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22
FROM (
    SELECT '하브스 테이크아웃숍 다이마루 우메다점' AS v1, '기타' AS v2, '케이크,디저트,우메다맛집,테이크아웃' AS v3, 4.1 AS v4, 60 AS v5, '신선한 과일과 부드러운 크림이 가득 채워진 프리미엄 케이크를 테이크아웃할 수 있는 우메다 대표 디저트 맛집.' AS v6, '일본 〒530-0001 Osaka, Kita Ward, Umeda, 3 Chome-1-1 大丸梅田店 B1F' AS v7, 34.702500 AS v8, 135.495800 AS v9, '10:00 - 20:00' AS v10, '+81 6-4797-0090' AS v11, '¥1,000 - ¥2,000' AS v12, 'https://harbs.co.jp' AS v13, '테이크아웃 전용' AS v14, '예약 불가' AS v15, '현금, 신용카드' AS v16, '일본어, 영어' AS v17, '/images/store-img/umeda/crepe-shop.png' AS v18, '과일 크레이프 케이크' AS v19, '얇은 크레이프 사이에 신선한 제철 과일과 생크림이 겹겹이 들어간 대표 케이크' AS v20, '¥950' AS v21, '/images/food-img/umeda/menu-crepe.png' AS v22
    FROM DUAL
) s
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT r
    WHERE r.NAME = s.v1
      AND r.ADDRESS = s.v7
);

PROMPT ===== SEED RESULT =====
SELECT COUNT(*) AS TOTAL_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' THEN 1 END) AS PUBLIC_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'N' THEN 1 END) AS PRIVATE_ROWS
FROM RESTAURANT;

SELECT RESTAURANT_ID, NAME, ADDRESS, IS_PUBLISHED
FROM RESTAURANT
ORDER BY RESTAURANT_ID;

PROMPT ===== SEED_DONE - REVIEW BEFORE COMMIT =====
SET VERIFY ON