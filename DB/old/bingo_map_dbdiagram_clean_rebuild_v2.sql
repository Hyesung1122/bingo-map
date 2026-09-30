-- ============================================================
-- BinGo Map / DBdiagram 최종 구조 기준 Oracle 11g CLEAN REBUILD
-- 기반 파일: 붙여넣은 텍스트 (1)(8).txt
--
-- 실행 순서
--   1) 기존 BinGo Map 테이블 + 구형 테이블 DROP
--   2) DBdiagram 최종 테이블 CREATE
--   3) SEQUENCE / TRIGGER CREATE
--   4) 원본 테스트 데이터 INSERT
--   5) 정합성 확인
--
-- 주의
--   - BinGo Map 관련 기존 데이터는 모두 삭제됩니다.
--   - BONUS / DEPT / EMP / SALGRADE 같은 Oracle 기본 샘플 테이블은 건드리지 않습니다.
--   - DBdiagram에 없는 SYSTEM_SETTINGS / COMMUNITY_COMMENT는 생성하지 않습니다.
--   - DBdiagram의 reviews는 RESTAURANT_ID가 아니라 target_type + target_id를 사용합니다.
--   - Oracle 11g의 increment는 SEQUENCE + BEFORE INSERT TRIGGER로 구현합니다.
--   - DDL은 Oracle 특성상 자동 COMMIT됩니다.
-- ============================================================

SET SERVEROUTPUT ON
SET DEFINE OFF

-- ============================================================
-- 0. 기존 BinGo Map 객체 정리
--    화면에서 확인된 구형 객체 포함
-- ============================================================

BEGIN
    FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'USERS',
            'FAVORITES',
            'REVIEWS',
            'REVIEW',
            'TB_REVIEW',
            'REVIEW_IMAGE',
            'TB_REVIEW_IMAGE',
            'COMMUNITY_POST',
            'TB_COMMUNITY_POST',
            'COMMUNITY_COMMENT',
            'TB_COMMUNITY_COMMENT',
            'RESTAURANTS',
            'RESTAURANT',
            'RESTAURANT_MENU',
            'TB_RESTAURANT_MENU',
            'NOTICES',
            'WASTE_BIN',
            'SYSTEM_SETTINGS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;

    FOR s IN (
        SELECT sequence_name
        FROM user_sequences
        WHERE sequence_name IN (
            'USERS_SEQ',
            'FAVORITES_SEQ',
            'REVIEWS_SEQ',
            'RESTAURANTS_SEQ',
            'SEQ_RESTAURANT',
            'NOTICES_SEQ',
            'WASTE_BIN_SEQ',
            'SEQ_REVIEW',
            'SEQ_REVIEW_IMAGE',
            'SEQ_COMMUNITY_POST',
            'SEQ_COMMUNITY_COMMENT',
            'SEQ_RESTAURANT_MENU'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- ============================================================
-- 1. USERS
-- DBdiagram:
-- id, email, password, name, nickname, nationality, sns_type,
-- security_question, security_answer, notify_email, location_enabled,
-- role, created_at, updated_at
-- ============================================================

CREATE SEQUENCE users_seq
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE users (
    id                  NUMBER(10)     NOT NULL,
    email               VARCHAR2(100)  NOT NULL,
    password            VARCHAR2(255)  NOT NULL,
    name                VARCHAR2(50)   NOT NULL,
    nickname            VARCHAR2(30),
    nationality         VARCHAR2(50),
    sns_type            VARCHAR2(20),
    security_question   VARCHAR2(100),
    security_answer     VARCHAR2(255),
    notify_email        VARCHAR2(1),
    location_enabled    VARCHAR2(1),
    role                VARCHAR2(20)   DEFAULT 'USER' NOT NULL,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,

    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_role CHECK (role IN ('USER', 'ADMIN'))
);

CREATE OR REPLACE TRIGGER users_bi
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT users_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 2. FAVORITES
-- ============================================================

CREATE SEQUENCE favorites_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE favorites (
    id           NUMBER(10)     NOT NULL,
    user_id      NUMBER(10)     NOT NULL,
    target_type  VARCHAR2(20)   NOT NULL,
    target_id    VARCHAR2(100)  NOT NULL,
    target_name  VARCHAR2(200),
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP,

    CONSTRAINT pk_favorites PRIMARY KEY (id),
    CONSTRAINT fk_favorites_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT ck_favorites_target_type
        CHECK (target_type IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT uq_favorites_target
        UNIQUE (user_id, target_type, target_id)
);

CREATE OR REPLACE TRIGGER favorites_bi
BEFORE INSERT ON favorites
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT favorites_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 3. REVIEWS
-- DBdiagram 최종 구조:
-- id / user_id / target_type / target_id / rating / content
-- + 방문정보 / 추천 / 도움수 / created_at / updated_at
-- ============================================================

CREATE SEQUENCE reviews_seq
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE reviews (
    id                NUMBER(10)     NOT NULL,
    user_id           NUMBER(10)     NOT NULL,
    target_type       VARCHAR2(20)   NOT NULL,
    target_id         VARCHAR2(100)  NOT NULL,
    rating            NUMBER(2,1)    NOT NULL,
    content           VARCHAR2(2000),
    visit_date        DATE,
    visit_time_slot   VARCHAR2(20),
    visit_purpose     VARCHAR2(20),
    recommend_yn      NUMBER(1),
    help_count        NUMBER(10) DEFAULT 0,
    created_at        TIMESTAMP,
    updated_at        TIMESTAMP,

    CONSTRAINT pk_reviews PRIMARY KEY (id),
    CONSTRAINT fk_reviews_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT ck_reviews_target_type
        CHECK (target_type IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT ck_reviews_rating
        CHECK (rating BETWEEN 0.5 AND 5.0),
    CONSTRAINT ck_reviews_recommend
        CHECK (recommend_yn IN (0, 1))
);

CREATE OR REPLACE TRIGGER reviews_bi
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT reviews_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 4. REVIEW_IMAGE
-- ============================================================

CREATE SEQUENCE seq_review_image
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE review_image (
    id          NUMBER(19)     NOT NULL,
    review_id   NUMBER(19)     NOT NULL,
    image_url   VARCHAR2(255)  NOT NULL,
    sort_order  NUMBER(10),

    CONSTRAINT pk_review_image PRIMARY KEY (id),
    CONSTRAINT fk_review_image_review
        FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE OR REPLACE TRIGGER review_image_bi
BEFORE INSERT ON review_image
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT seq_review_image.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 5. COMMUNITY_POST
-- ============================================================

CREATE SEQUENCE seq_community_post
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE community_post (
    id          NUMBER(19)     NOT NULL,
    user_id     NUMBER(19)     NOT NULL,
    title       VARCHAR2(200)  NOT NULL,
    content     CLOB           NOT NULL,
    tags        VARCHAR2(200),
    view_count  NUMBER(10) DEFAULT 0,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP,

    CONSTRAINT pk_community_post PRIMARY KEY (id),
    CONSTRAINT fk_community_post_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE OR REPLACE TRIGGER community_post_bi
BEFORE INSERT ON community_post
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT seq_community_post.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 6. RESTAURANTS
-- DBdiagram 최종 PK = restaurant_id
-- ============================================================

CREATE SEQUENCE seq_restaurant
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE restaurants (
    restaurant_id      NUMBER(19)      NOT NULL,
    name               VARCHAR2(255)   NOT NULL,
    category           VARCHAR2(255),
    tags               VARCHAR2(255),
    rating             NUMBER(3,1),
    review_count       NUMBER(10),
    description        VARCHAR2(1000),
    address            VARCHAR2(4000),
    latitude           NUMBER(10,7),
    longitude          NUMBER(10,7),
    opening_hours      VARCHAR2(1000),
    phone              VARCHAR2(255),
    price_range        VARCHAR2(50),
    website_url        VARCHAR2(1000),
    seat_info          VARCHAR2(100),
    reservation_info   VARCHAR2(100),
    payment_methods    VARCHAR2(200),
    languages          VARCHAR2(200),
    main_image_url     VARCHAR2(500),
    menu_name          VARCHAR2(100),
    menu_description   VARCHAR2(500),
    menu_price         VARCHAR2(50),
    menu_image_url     VARCHAR2(500),
    osm_id             NUMBER(19),
    is_published       CHAR(1) DEFAULT 'N' NOT NULL,
    created_at         TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at         TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_restaurants PRIMARY KEY (restaurant_id),
    CONSTRAINT uq_restaurants_osm_id UNIQUE (osm_id),
    CONSTRAINT ck_restaurants_published CHECK (is_published IN ('Y', 'N'))
);

CREATE OR REPLACE TRIGGER restaurants_bi
BEFORE INSERT ON restaurants
FOR EACH ROW
BEGIN
    IF :NEW.restaurant_id IS NULL THEN
        SELECT seq_restaurant.NEXTVAL INTO :NEW.restaurant_id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 7. NOTICES
-- ============================================================

CREATE SEQUENCE notices_seq
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE notices (
    id          NUMBER(10)      NOT NULL,
    author_id   NUMBER(10)      NOT NULL,
    title       VARCHAR2(200)   NOT NULL,
    content     CLOB            NOT NULL,
    view_count  NUMBER(10) DEFAULT 0,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP,

    CONSTRAINT pk_notices PRIMARY KEY (id),
    CONSTRAINT fk_notices_author
        FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE OR REPLACE TRIGGER notices_bi
BEFORE INSERT ON notices
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT notices_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 8. WASTE_BIN
-- 원본 파일 기준 테스트 INSERT 없음
-- ============================================================

CREATE SEQUENCE waste_bin_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE waste_bin (
    id          NUMBER(10)     NOT NULL,
    osm_id      NUMBER(19)     NOT NULL,
    name        VARCHAR2(100),
    category    VARCHAR2(20)   NOT NULL,
    address     VARCHAR2(300),
    latitude    NUMBER(10,7)   NOT NULL,
    longitude   NUMBER(10,7)   NOT NULL,
    city        VARCHAR2(50)   DEFAULT 'osaka' NOT NULL,
    created_at  TIMESTAMP,
    updated_at  TIMESTAMP,

    CONSTRAINT pk_waste_bin PRIMARY KEY (id),
    CONSTRAINT uq_waste_bin_osm_id UNIQUE (osm_id),
    CONSTRAINT ck_waste_bin_category
        CHECK (category IN ('general', 'recycle', 'can'))
);

CREATE OR REPLACE TRIGGER waste_bin_bi
BEFORE INSERT ON waste_bin
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT waste_bin_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 9. RESTAURANT_MENU
-- ============================================================

CREATE SEQUENCE seq_restaurant_menu
    START WITH 11
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE restaurant_menu (
    id              NUMBER(19)     NOT NULL,
    restaurant_id   NUMBER(19)     NOT NULL,
    name            VARCHAR2(100)  NOT NULL,
    price           VARCHAR2(50),
    is_signature    NUMBER(1) DEFAULT 0,

    CONSTRAINT pk_restaurant_menu PRIMARY KEY (id),
    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT ck_restaurant_menu_signature
        CHECK (is_signature IN (0, 1))
);

CREATE OR REPLACE TRIGGER restaurant_menu_bi
BEFORE INSERT ON restaurant_menu
FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT seq_restaurant_menu.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/

-- ============================================================
-- 10. TEST DATA
-- 원본 파일의 데이터를 최종 DBdiagram 컬럼명에 맞춰 INSERT
-- ============================================================

-- ------------------------------------------------------------
-- USERS
-- ------------------------------------------------------------

INSERT INTO users (
    id, name, nickname, email, password, nationality, sns_type,
    role, security_question, security_answer, notify_email, location_enabled
) VALUES (
    1,
    '안태건', '알레띠NO7', 'atg1234@gmail.com', '$2b$12$BRih3Wu05PG6e/PCmwDJ7.Co6dKp7oK2tjV7aZzlIQQ.rWEhDNBl2',
    '한국', 'X', 'ADMIN', NULL, NULL, NULL, NULL
);

-- 회원 | 계정 4개

-- 유저1 곽동곤 | 이메일 알림, 위치 정보 YES
INSERT INTO users (
    id, name, nickname, email, password, nationality, sns_type,
    role, security_question, security_answer, notify_email, location_enabled
) VALUES (
    2,
    '곽동곤', '고재팬', 'kdk1234@gmail.com', '$2b$12$1DlEx1M4ng6DNvqgOdi3Xu.w033kXyRrpoYyXFavXQCyB8D9VONkC',
    '한국', 'X', 'USER', NULL, NULL, 'Y', 'Y'
);

-- 유저2 박주호 | 이메일 알림, 위치 정보 NO
INSERT INTO users (
    id, name, nickname, email, password, nationality, sns_type,
    role, security_question, security_answer, notify_email, location_enabled
) VALUES (
    3,
    '박주호', '주호누오', 'pjh1234@gmail.com', '$2b$12$RW2vV37AzG1CzoUF8dU9Juu97MedLlmsjAKlraoOvhuIaXgfl.6wO',
    '한국', 'X', 'USER', NULL, NULL, 'N', 'N'
);

-- 유저3 유해성 | 일본
INSERT INTO users (
    id, name, nickname, email, password, nationality, sns_type,
    role, security_question, security_answer, notify_email, location_enabled
) VALUES (
    4,
    '유해성', '유해성입니다', 'YHS1234@gmail.com', '$2b$12$2wo9lxyNV0M2ZdMXhZ93Se/B8GqZeSxtR8b2egt93QG4phMlWQrYa',
    '일본', 'X', 'USER', NULL, NULL, NULL, NULL
);

-- 유저4 장준환 | 미국
INSERT INTO users (
    id, name, nickname, email, password, nationality, sns_type,
    role, security_question, security_answer, notify_email, location_enabled
) VALUES (
    5,
    '장준환', '주난쥬난', 'jjh1234@gmail.com', '$2b$12$6pc0EyeG83RcTpf37qEwHu9VRXcSAz7qH5CsqBywa3Q4ERAS9/B/C',
    '미국', 'X', 'USER', NULL, NULL, NULL, NULL
);

COMMIT;

-- ------------------------------------------------------------
-- RESTAURANTS
-- 원본 INSERT의 id 컬럼만 restaurant_id로 변경
-- OSM_ID / IS_PUBLISHED는 원본 테스트 데이터에 없으므로 기본값 적용
-- ------------------------------------------------------------

INSERT INTO restaurants (
    restaurant_id, name, category, tags, rating, review_count,
    description, address, latitude, longitude,
    opening_hours, phone, price_range, website_url,
    seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description,
    menu_price, menu_image_url
) VALUES (
    1,
    '쿠쿠루 도톤보리 본점', '타코야끼', '도톤보리,타코야끼,오사카맛집',
    4.6, 1248,
    '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집',
    '1-10-5 Dotonbori, Chuo-ku, Osaka',
    34.668729, 135.501294,
    '09:00 - 21:00', '+81-6-6212-7381', '¥500 - ¥1,500', 'https://www.kukurutei.com',
    '20석', '예약 불가 (현장 대기)', '현금, 신용카드, 전자화폐', '일본어, 한국어 메뉴판',
    '/images/food-takoyaki.png',
    '명물 타코야끼 (8개)', '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴',
    '¥850',
    -- via.placeholder.com은 서비스 종료된 도메인 — 데모 전 실제 이미지 경로로 교체 필요
    'https://via.placeholder.com/64?text=Takoyaki'
);

INSERT INTO restaurants (
    restaurant_id, name, category, tags, rating, review_count,
    description, address, latitude, longitude,
    opening_hours, phone, price_range, website_url,
    seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description,
    menu_price, menu_image_url
) VALUES (
    2,
    '야끼소바 산페이', '야끼소바', '야끼소바,철판요리,감칠맛',
    4.4, 892,
    '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점',
    '1-7-14 Dotonbori, Chuo-ku, Osaka',
    34.668900, 135.502100,
    '10:30 - 20:30', '+81-6-6211-1234', '¥700 - ¥1,200', 'https://www.sanpei-osaka.jp',
    '15석 (카운터석)', '예약 불가', '현금, 신용카드', '일본어, 영어',
    '/images/food-yakisoba.png',
    '특제 소스 야끼소바', '진한 특제 소스와 쫄깃한 면발의 조화',
    '¥900',
    'https://via.placeholder.com/64?text=Yakisoba'
);

INSERT INTO restaurants (
    restaurant_id, name, category, tags, rating, review_count,
    description, address, latitude, longitude,
    opening_hours, phone, price_range, website_url,
    seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description,
    menu_price, menu_image_url
) VALUES (
    3,
    '오코노미야끼 치보 도톤보리빌딩점', '오코노미야끼', '오코노미야끼,철판구이,웨이팅맛집',
    4.5, 1102,
    '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장',
    '1-5-5 Dotonbori, Chuo-ku, Osaka',
    34.668500, 135.503200,
    '11:00 - 21:30', '+81-6-6212-2211', '¥1,000 - ¥2,500', 'https://www.chibo.com',
    '50석 (테이블 및 다찌석)', '전화 예약 가능', '현금, 신용카드, 모바일페이', '한국어 지원 (다국어 키오스크)',
    '/images/food-okonomiyaki.png',
    '치보 믹스 오코노미야끼', '새우, 오징어, 돼지고기가 모두 들어간 베스트 메뉴',
    '¥1,580',
    'https://via.placeholder.com/64?text=Okonomiyaki'
);

INSERT INTO restaurants (
    restaurant_id, name, category, tags, rating, review_count,
    description, address, latitude, longitude,
    opening_hours, phone, price_range, website_url,
    seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description,
    menu_price, menu_image_url
) VALUES (
    4,
    '도톤보리 타이야끼', '붕어빵', '길거리간식,붕어빵,디저트',
    4.3, 567,
    '국산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵',
    '1-8-22 Dotonbori, Chuo-ku, Osaka',
    34.668350, 135.500800,
    '10:00 - 19:00', '+81-6-6213-9876', '¥300 - ¥600', NULL,
    '없음 (테이크아웃 전용)', '예약 불가', '현금 전용', '일본어 메뉴',
    '/images/food-taiyaki.png',
    '통단팥 붕어빵', '달콤하고 부드러운 팥이 꽉 찬 인기 간식',
    '¥300',
    'https://via.placeholder.com/64?text=Taiyaki'
);

INSERT INTO restaurants (
    restaurant_id, name, category, tags, rating, review_count,
    description, address, latitude, longitude,
    opening_hours, phone, price_range, website_url,
    seat_info, reservation_info, payment_methods, languages,
    main_image_url, menu_name, menu_description,
    menu_price, menu_image_url
) VALUES (
    5,
    '카라아게 타로', '닭튀김', '치킨,가라아게,맥주안주',
    4.4, 734,
    '바삭한 튀김옷 속 육즙이 가득! 특제 마늘 간장 소스로 버무린 정통 일본식 닭튀김',
    '2-2-1 Nanba, Chuo-ku, Osaka',
    34.667800, 135.500200,
    '11:00 - 21:00', '+81-6-6631-5544', '¥600 - ¥1,000', 'https://www.karaage-taro.jp',
    '10석', '예약 불가', '현금, 신용카드', '일본어, 영어',
    '/images/food-karaage.png',
    '카라아게 타로 (오리지널)', '겉은 바삭하고 속은 촉촉한 대표 닭튀김',
    '¥680',
    'https://via.placeholder.com/64?text=Karaage'
);

COMMIT;

COMMIT;

-- ------------------------------------------------------------
-- REVIEWS
-- 원본 파일의 TB_REVIEW 5건에 있던 방문정보까지 최종 reviews에 보존
-- target_type = RESTAURANT
-- target_id = restaurants.id 값을 문자열로 저장
-- ------------------------------------------------------------

INSERT INTO reviews (
    id, user_id, target_type, target_id, rating, content,
    visit_date, visit_time_slot, visit_purpose, recommend_yn, help_count
) VALUES (
    1, 1, 'RESTAURANT', '1', 3,
    '그닥이던데.. 오바임.. ㅋㅋ',
    TRUNC(SYSDATE) - 10, '점심 11:00~14:00', '여행', 0, 2
);

INSERT INTO reviews (
    id, user_id, target_type, target_id, rating, content,
    visit_date, visit_time_slot, visit_purpose, recommend_yn, help_count
) VALUES (
    2, 2, 'RESTAURANT', '2', 1,
    '라멘집인줄 알고 갔네 아 ** !!',
    TRUNC(SYSDATE) - 8, '저녁 18:00~21:00', '친구모임', 0, 0
);

INSERT INTO reviews (
    id, user_id, target_type, target_id, rating, content,
    visit_date, visit_time_slot, visit_purpose, recommend_yn, help_count
) VALUES (
    3, 3, 'RESTAURANT', '3', 5,
    '맛있어요오오오오오ㅗ',
    TRUNC(SYSDATE) - 6, '저녁 18:00~21:00', '데이트', 1, 5
);

INSERT INTO reviews (
    id, user_id, target_type, target_id, rating, content,
    visit_date, visit_time_slot, visit_purpose, recommend_yn, help_count
) VALUES (
    4, 4, 'RESTAURANT', '4', 3.5,
    '타이야끼인가.. 조금은 아직 어렵습니다..',
    TRUNC(SYSDATE) - 4, '오후 14:00~18:00', '기타', 0, 1
);

INSERT INTO reviews (
    id, user_id, target_type, target_id, rating, content,
    visit_date, visit_time_slot, visit_purpose, recommend_yn, help_count
) VALUES (
    5, 5, 'RESTAURANT', '5', 5,
    '맛있어서 먹다가 울었음 ㅠㅠ',
    TRUNC(SYSDATE) - 2, '점심 11:00~14:00', '가족외식', 1, 3
);

COMMIT;

-- ------------------------------------------------------------
-- NOTICES
-- ------------------------------------------------------------

-- [v5 추가] 공지사항 테스트 데이터 (작성자 = 관리자 users.id 1)
-- ============================================================
INSERT INTO notices (id, author_id, title, content, view_count)
VALUES (1, 1, 'BinGo Map 오픈 안내', 'BinGo Map이 오픈했습니다. 오사카 여행 중 쓰레기통과 테이크아웃 맛집을 한 번에 찾아보세요.', 42);
INSERT INTO notices (id, author_id, title, content, view_count)
VALUES (2, 1, '쓰레기통 위치 데이터 안내', '쓰레기통 위치는 OpenStreetMap 데이터를 기반으로 제공되며 실제와 다를 수 있습니다.', 31);
INSERT INTO notices (id, author_id, title, content, view_count)
VALUES (3, 1, '리뷰 작성 가이드', '리뷰에는 사진을 최대 3장까지 첨부할 수 있습니다. 솔직한 후기를 남겨주세요.', 18);
INSERT INTO notices (id, author_id, title, content, view_count)
VALUES (4, 1, '커뮤니티 이용 수칙', '서로를 존중하는 커뮤니티를 만들어 주세요. 광고성·비방 글은 관리자에 의해 삭제될 수 있습니다.', 12);
INSERT INTO notices (id, author_id, title, content, view_count)
VALUES (5, 1, '다국어 지원 예정 안내', '일본어·영어 지원을 준비 중입니다. 조금만 기다려 주세요.', 7);

COMMIT;

-- ------------------------------------------------------------
-- RESTAURANT_MENU
-- 원본 TB_RESTAURANT_MENU -> restaurant_menu
-- MENU_ID -> id
-- ------------------------------------------------------------

INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (1, 1, '명물 타코야끼 (8개)', '¥850', 1);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (2, 1, '타코야끼 (12개)', '¥1,200', 0);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (3, 2, '특제 소스 야끼소바', '¥900', 1);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (4, 2, '야끼소바 + 계란', '¥1,050', 0);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (5, 3, '치보 믹스 오코노미야끼', '¥1,580', 1);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (6, 3, '돼지고기 오코노미야끼', '¥1,200', 0);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (7, 4, '통단팥 붕어빵', '¥300', 1);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (8, 4, '커스터드 붕어빵', '¥320', 0);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (9, 5, '카라아게 타로 (오리지널)', '¥680', 1);
INSERT INTO restaurant_menu (id, restaurant_id, name, price, is_signature)
VALUES (10, 5, '카라아게 (마늘 간장)', '¥720', 0);

COMMIT;

-- ------------------------------------------------------------
-- COMMUNITY_POST
-- 원본 TB_COMMUNITY_POST -> community_post
-- POST_ID -> id
-- ------------------------------------------------------------

INSERT INTO community_post (id, user_id, title, content, tags, view_count)
VALUES (
    1, 2,
    '도톤보리 쓰레기통 어디에 있나요?',
    '글리코 간판 근처에서 먹고 나서 쓰레기 버릴 곳을 못 찾겠어요. 아시는 분 계신가요?',
    '도톤보리,쓰레기통',
    25
);

INSERT INTO community_post (id, user_id, title, content, tags, view_count)
VALUES (
    2, 3,
    '타코야끼 웨이팅 팁',
    '점심시간 전인 11시 전에 가면 대기 없이 먹을 수 있었어요.',
    '타코야끼,팁',
    18
);

INSERT INTO community_post (id, user_id, title, content, tags, view_count)
VALUES (
    3, 4,
    '일본은 왜 길에 쓰레기통이 없을까요',
    '여행 중에 계속 궁금했는데 편의점 앞 분리수거함을 이용하면 된다고 하네요.',
    '일본여행,문화',
    40
);

INSERT INTO community_post (id, user_id, title, content, tags, view_count)
VALUES (
    4, 5,
    '오사카 2박 3일 맛집 코스 공유',
    '타코야끼 - 오코노미야끼 - 카라아게 순으로 돌았는데 동선이 좋았어요.',
    '코스,오사카맛집',
    33
);

INSERT INTO community_post (id, user_id, title, content, tags, view_count)
VALUES (
    5, 1,
    '커뮤니티 이용 안내',
    '궁금한 점이나 여행 정보를 자유롭게 공유해 주세요.',
    '공지',
    9
);

COMMIT;

-- ============================================================
-- 11. 정합성 점검
-- ============================================================

SELECT 'USERS' AS TABLE_NAME, COUNT(*) AS CNT FROM users
UNION ALL
SELECT 'FAVORITES', COUNT(*) FROM favorites
UNION ALL
SELECT 'REVIEWS', COUNT(*) FROM reviews
UNION ALL
SELECT 'REVIEW_IMAGE', COUNT(*) FROM review_image
UNION ALL
SELECT 'COMMUNITY_POST', COUNT(*) FROM community_post
UNION ALL
SELECT 'RESTAURANTS', COUNT(*) FROM restaurants
UNION ALL
SELECT 'NOTICES', COUNT(*) FROM notices
UNION ALL
SELECT 'WASTE_BIN', COUNT(*) FROM waste_bin
UNION ALL
SELECT 'RESTAURANT_MENU', COUNT(*) FROM restaurant_menu
ORDER BY 1;

SELECT table_name
FROM user_tables
WHERE table_name IN (
    'USERS',
    'FAVORITES',
    'REVIEWS',
    'REVIEW_IMAGE',
    'COMMUNITY_POST',
    'RESTAURANTS',
    'NOTICES',
    'WASTE_BIN',
    'RESTAURANT_MENU',
    'RESTAURANT',
    'TB_COMMUNITY_COMMENT',
    'TB_COMMUNITY_POST',
    'TB_REVIEW',
    'TB_REVIEW_IMAGE',
    'TB_RESTAURANT_MENU',
    'SYSTEM_SETTINGS'
)
ORDER BY table_name;

SELECT restaurant_id, name, is_published
FROM restaurants
ORDER BY restaurant_id;

SELECT r.id,
       u.name AS 작성자,
       r.target_type,
       r.target_id,
       r.rating,
       r.content,
       r.visit_date,
       r.visit_time_slot,
       r.visit_purpose,
       r.recommend_yn,
       r.help_count
FROM reviews r
JOIN users u ON r.user_id = u.id
ORDER BY r.id;

SELECT id, restaurant_id, name, price, is_signature
FROM restaurant_menu
ORDER BY id;

SELECT id, user_id, title, view_count
FROM community_post
ORDER BY id;

SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name IN (
    'USERS_SEQ',
    'FAVORITES_SEQ',
    'REVIEWS_SEQ',
    'SEQ_REVIEW_IMAGE',
    'SEQ_COMMUNITY_POST',
    'SEQ_RESTAURANT',
    'NOTICES_SEQ',
    'WASTE_BIN_SEQ',
    'SEQ_RESTAURANT_MENU'
)
ORDER BY sequence_name;

SET DEFINE ON
