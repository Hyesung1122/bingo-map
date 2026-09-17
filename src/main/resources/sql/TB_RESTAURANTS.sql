-- ====================================================================
-- [1단계: 기존 객체 정리 (초기화)]
-- 이미 만들어진 테이블이나 시퀀스가 있다면 충돌을 방지하기 위해 먼저 삭제합니다.
-- 처음 실행할 때는 삭제할 테이블이 없다는 오류가 뜰 수 있으나 정상입니다.
-- ====================================================================
DROP TABLE RESTAURANT CASCADE CONSTRAINTS;
DROP SEQUENCE SEQ_RESTAURANT;


-- ====================================================================
-- [2단계: 식당 고유번호(PK) 자동 생성기(시퀀스) 생성]
-- 식당 데이터가 들어올 때마다 번호(1, 2, 3...)를 자동으로 1씩 올려줍니다.
-- 스프링 부트 엔티티(Entity)의 SequenceGenerator 설정과 일치합니다.
-- ====================================================================
CREATE SEQUENCE SEQ_RESTAURANT
    START WITH 1          -- 시작 번호: 1번부터 시작
    INCREMENT BY 1        -- 증가 단위: 1씩 증가
    NOCACHE               -- 캐시 미사용 (서버 강제종료 시 번호 건너뜀 방지)
    NOCYCLE;              -- 번호 순환 없음 (최댓값 도달 후 다시 1로 돌아가지 않음)


-- ====================================================================
-- [3단계: 맛집(RESTAURANT) 테이블 생성]
-- 맛집의 기본 정보부터 상세 운영 정보까지 저장하는 테이블입니다.
-- ====================================================================
CREATE TABLE RESTAURANT (
    RESTAURANT_ID    NUMBER(19) PRIMARY KEY, -- 식당 고유 식별 번호 (기본키)
    NAME             VARCHAR2(100) NOT NULL, -- 식당 이름 (필수 입력값)
    CATEGORY         VARCHAR2(50),           -- 음식 종류 (타코야끼, 야끼소바 등 목록 필터용)
    TAGS             VARCHAR2(200),          -- 검색 및 뱃지용 태그 (쉼표로 구분)
    RATING           NUMBER(3,1),            -- 별점 평점 (예: 4.6, 4.4 등 소수점 1자리)
    REVIEW_COUNT     NUMBER(10),             -- 등록된 리뷰 총 개수
    DESCRIPTION      VARCHAR2(1000),         -- 식당 한 줄 소개 및 설명글
    ADDRESS          VARCHAR2(300),          -- 식당 실제 도로명/지번 주소
    LATITUDE         NUMBER(10,7),           -- 지도 위치 위도 좌표 (예: 34.6687290)
    LONGITUDE        NUMBER(10,7),           -- 지도 위치 경도 좌표 (예: 135.5012940)
    OPENING_HOURS    VARCHAR2(100),          -- 매장 영업 시간 (예: 09:00 - 21:00)
    PHONE            VARCHAR2(50),           -- 매장 전화번호 (전화걸기 버튼과 연동)
    PRICE_RANGE      VARCHAR2(50),           -- 1인당 예상 가격대 (예: ¥500 - ¥1,500)
    WEBSITE_URL      VARCHAR2(300),          -- 공식 웹사이트 또는 인스타그램 URL
    SEAT_INFO        VARCHAR2(100),          -- 좌석 형태 (예: 20석, 테이크아웃 전문 등)
    RESERVATION_INFO VARCHAR2(100),          -- 예약 가능 여부 (예: 예약 불가, 예약 필수)
    PAYMENT_METHODS  VARCHAR2(200),          -- 결제 수단 (예: 현금, 카드, PayPay)
    LANGUAGES        VARCHAR2(200),          -- 제공 메뉴판 언어 (예: 일본어, 한국어)
    MAIN_IMAGE_URL   VARCHAR2(500)           -- 대표 사진 경로 (static 폴더 기준 이미지 주소)
);


-- ====================================================================
-- [4단계: 테스트용 샘플 데이터 등록 (5건)]
-- 화면 목록과 상세 페이지가 비어있지 않도록 카테고리별로 5개 식당을 등록합니다.
-- ====================================================================

-- 데이터 1: 타코야끼 대표 매장 (쿠쿠루 도톤보리 본점)
INSERT INTO RESTAURANT (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, 
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, 
    PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, 
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL
) VALUES (
    SEQ_RESTAURANT.NEXTVAL,
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
    '/images/food-takoyaki.png'
);

-- 데이터 2: 야끼소바 전문 매장 (야끼소바 산페이)
INSERT INTO RESTAURANT (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, 
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, 
    PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, 
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL
) VALUES (
    SEQ_RESTAURANT.NEXTVAL,
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
    '/images/food-yakisoba.png'
);

-- 데이터 3: 오코노미야끼 전문 매장 (오코노미야끼 치보)
INSERT INTO RESTAURANT (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, 
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, 
    PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, 
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL
) VALUES (
    SEQ_RESTAURANT.NEXTVAL,
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
    '/images/food-okonomiyaki.png'
);

-- 데이터 4: 붕어빵/디저트 매장 (도톤보리 타이야끼)
INSERT INTO RESTAURANT (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, 
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, 
    PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, 
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL
) VALUES (
    SEQ_RESTAURANT.NEXTVAL,
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
    '/images/food-taiyaki.png'
);

-- 데이터 5: 닭튀김 매장 (카라아게 타로)
INSERT INTO RESTAURANT (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT, 
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, 
    PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO, 
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL
) VALUES (
    SEQ_RESTAURANT.NEXTVAL,
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
    '/images/food-karaage.png'
);


-- ====================================================================
-- [5단계: 영구 반영(COMMIT) 및 데이터 확인]
-- INSERT 작업 후 COMMIT을 누르지 않으면 스프링 부트에서 데이터를 조회할 수 없습니다.
-- ====================================================================
COMMIT;

-- 정상적으로 5건이 모두 삽입되었는지 테이블을 확인합니다.
SELECT RESTAURANT_ID, NAME, CATEGORY, RATING, REVIEW_COUNT, MAIN_IMAGE_URL FROM RESTAURANT;
UPDATE TB_RESTAURANT_MENU SET RESTAURANT_ID = 2 WHERE RESTAURANT_ID = 1;
COMMIT;
