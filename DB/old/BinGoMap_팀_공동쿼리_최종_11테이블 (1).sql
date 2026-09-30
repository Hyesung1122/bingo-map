-- ============================================================
-- BinGo Map 팀 공동 DB 쿼리
-- 기준: 0929 확정 DBML + SYSTEM_SETTINGS 추가
-- 목적: 팀원이 새/초기화된 개발 DB에 한 번 실행하는 전체 설치 스크립트
-- 실행 방법: Oracle SQL Developer에서 스크립트 실행(F5)
--
-- 최종 테이블 12개 (첨부 DBML 11개 + 현재 앱의 쓰레기통 제보 BIN_REPORTS)
--   USERS
--   FAVORITES
--   REVIEWS
--   REVIEW_IMAGE
--   COMMUNITY_POST
--   COMMUNITY_COMMENT
--   RESTAURANTS
--   NOTICES
--   WASTE_BIN
--   RESTAURANT_MENU
--   SYSTEM_SETTINGS
--   BIN_REPORTS
--
-- 레거시 중복 테이블은 정리함
--   RESTAURANT
--   REVIEW
--   TB_REVIEW
--   TB_REVIEW_IMAGE
--   TB_COMMUNITY_POST
--   TB_COMMUNITY_COMMENT
--   TB_RESTAURANT_MENU
--
-- 주의
--   1. 초기화 스크립트입니다. 실행하면 아래 공용 테이블의 기존 데이터가 삭제됩니다.
--   2. 아래 DROP 구문은 BinGo Map 공용 테이블/레거시 테이블만 대상으로 함.
--   3. BONUS / DEPT / EMP / SALGRADE 등 Oracle 기본 샘플 테이블은 건드리지 않음.
--   4. Oracle 11g 기준이라 increment는 SEQUENCE + BEFORE INSERT TRIGGER로 구현.
--   5. OSM 식당은 Loader가 IS_PUBLISHED='Y'로 적재하므로 목록에 표시됨.
--   6. OSM 쓰레기통 데이터는 애플리케이션 Loader가 적재.
-- ============================================================

SET SERVEROUTPUT ON
SET DEFINE OFF

-- ============================================================
-- 0. 기존 BinGo Map 객체 정리
-- ============================================================
BEGIN
    -- 최종 공용 테이블 + 현재까지 존재했던 중복/레거시 테이블
    FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            -- 최종 공용 테이블
            'USERS',
            'FAVORITES',
            'REVIEWS',
            'REVIEW_IMAGE',
            'COMMUNITY_POST',
            'COMMUNITY_COMMENT',
            'RESTAURANTS',
            'NOTICES',
            'WASTE_BIN',
            'RESTAURANT_MENU',
            'SYSTEM_SETTINGS',
            'BIN_REPORTS',
            -- 레거시/중복 테이블
            'RESTAURANT',
            'REVIEW',
            'TB_REVIEW',
            'TB_REVIEW_IMAGE',
            'TB_COMMUNITY_POST',
            'TB_COMMUNITY_COMMENT',
            'TB_RESTAURANT_MENU'
        )
    ) LOOP
        EXECUTE IMMEDIATE
            'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;

    -- 최종 스키마에서 사용하는 sequence + 과거 이름
    FOR s IN (
        SELECT sequence_name
        FROM user_sequences
        WHERE sequence_name IN (
            'USERS_SEQ',
            'FAVORITES_SEQ',
            'SEQ_REVIEW',
            'SEQ_REVIEW_IMAGE',
            'SEQ_COMMUNITY_POST',
            'SEQ_COMMUNITY_COMMENT',
            'SEQ_RESTAURANT',
            'SEQ_RESTAURANT_MENU',
            'BIN_REPORTS_SEQ',
            'NOTICES_SEQ',
            'WASTE_BIN_SEQ',
            -- 과거 식당 시퀀스 이름
            'RESTAURANTS_SEQ',
            'SEQ_RESTAURANTS',
            -- 과거 메뉴/리뷰 계열에서 쓰였을 수 있는 이름
            'SEQ_RESTAURANT_MENU'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE SEQUENCE USERS_SEQ
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE USERS (
    ID                  NUMBER(19)       NOT NULL,
    EMAIL               VARCHAR2(100)    NOT NULL,
    PASSWORD            VARCHAR2(255)    NOT NULL,
    NAME                VARCHAR2(50)     NOT NULL,
    NICKNAME            VARCHAR2(30),
    NATIONALITY         VARCHAR2(50),
    SNS_TYPE             VARCHAR2(20),
    SECURITY_QUESTION    VARCHAR2(100),
    SECURITY_ANSWER      VARCHAR2(255),
    NOTIFY_EMAIL         VARCHAR2(1),
    LOCATION_ENABLED     VARCHAR2(1),
    ROLE                 VARCHAR2(20)    DEFAULT 'USER' NOT NULL,
    CREATED_AT           TIMESTAMP,
    UPDATED_AT           TIMESTAMP,
    CONSTRAINT PK_USERS PRIMARY KEY (ID),
    CONSTRAINT UQ_USERS_EMAIL UNIQUE (EMAIL),
    CONSTRAINT CK_USERS_ROLE CHECK (ROLE IN ('USER', 'ADMIN'))
);

CREATE OR REPLACE TRIGGER USERS_BI
    BEFORE INSERT ON USERS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT USERS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 2. FAVORITES
-- ============================================================
CREATE SEQUENCE FAVORITES_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE FAVORITES (
    ID                  NUMBER(19)       NOT NULL,
    USER_ID             NUMBER(19)       NOT NULL,
    TARGET_TYPE         VARCHAR2(20)     NOT NULL,
    TARGET_ID           VARCHAR2(100)    NOT NULL,
    TARGET_NAME         VARCHAR2(200),
    CREATED_AT          TIMESTAMP,
    UPDATED_AT          TIMESTAMP,
    CONSTRAINT PK_FAVORITES PRIMARY KEY (ID),
    CONSTRAINT FK_FAVORITES_USER
        FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT CK_FAVORITES_TARGET_TYPE
        CHECK (TARGET_TYPE IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT UQ_FAVORITES_TARGET
        UNIQUE (USER_ID, TARGET_TYPE, TARGET_ID)
);

CREATE OR REPLACE TRIGGER FAVORITES_BI
    BEFORE INSERT ON FAVORITES
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT FAVORITES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 3. REVIEWS
-- ============================================================
CREATE SEQUENCE SEQ_REVIEW
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE REVIEWS (
    ID                  NUMBER(19)       NOT NULL,
    USER_ID             NUMBER(19)       NOT NULL,
    TARGET_TYPE         VARCHAR2(20)     NOT NULL,
    TARGET_ID           VARCHAR2(100)    NOT NULL,
    RATING              NUMBER(2,1)      NOT NULL,
    CONTENT             VARCHAR2(2000),
    VISIT_DATE          DATE,
    VISIT_TIME_SLOT     VARCHAR2(20),
    VISIT_PURPOSE       VARCHAR2(20),
    RECOMMEND_YN        NUMBER(1),
    HELP_COUNT          NUMBER(10)       DEFAULT 0,
    CREATED_AT          TIMESTAMP,
    UPDATED_AT          TIMESTAMP,
    CONSTRAINT PK_REVIEWS PRIMARY KEY (ID),
    CONSTRAINT FK_REVIEWS_USER
        FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT CK_REVIEWS_TARGET_TYPE
        CHECK (TARGET_TYPE IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT CK_REVIEWS_RATING
        CHECK (RATING BETWEEN 0.5 AND 5.0),
    CONSTRAINT CK_REVIEWS_RECOMMEND
        CHECK (RECOMMEND_YN IN (0, 1) OR RECOMMEND_YN IS NULL)
);

CREATE OR REPLACE TRIGGER REVIEWS_BI
    BEFORE INSERT ON REVIEWS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_REVIEW.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 4. REVIEW_IMAGE
-- ============================================================
CREATE SEQUENCE SEQ_REVIEW_IMAGE
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE REVIEW_IMAGE (
    ID                  NUMBER(19)       NOT NULL,
    REVIEW_ID           NUMBER(19)       NOT NULL,
    IMAGE_URL           VARCHAR2(255)    NOT NULL,
    SORT_ORDER          NUMBER(10),
    CONSTRAINT PK_REVIEW_IMAGE PRIMARY KEY (ID),
    CONSTRAINT FK_REVIEW_IMAGE_REVIEW
        FOREIGN KEY (REVIEW_ID) REFERENCES REVIEWS (ID)
);

CREATE OR REPLACE TRIGGER REVIEW_IMAGE_BI
    BEFORE INSERT ON REVIEW_IMAGE
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_REVIEW_IMAGE.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 5. COMMUNITY_POST
-- ============================================================
CREATE SEQUENCE SEQ_COMMUNITY_POST
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE COMMUNITY_POST (
    ID                  NUMBER(19)       NOT NULL,
    USER_ID             NUMBER(19)       NOT NULL,
    TITLE               VARCHAR2(200)    NOT NULL,
    CONTENT             CLOB             NOT NULL,
    TAGS                VARCHAR2(200),
    VIEW_COUNT          NUMBER(10)       DEFAULT 0,
    CREATED_AT          TIMESTAMP,
    UPDATED_AT          TIMESTAMP,
    CONSTRAINT PK_COMMUNITY_POST PRIMARY KEY (ID),
    CONSTRAINT FK_COMMUNITY_POST_USER
        FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE OR REPLACE TRIGGER COMMUNITY_POST_BI
    BEFORE INSERT ON COMMUNITY_POST
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_COMMUNITY_POST.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 6. COMMUNITY_COMMENT
-- ============================================================
CREATE SEQUENCE SEQ_COMMUNITY_COMMENT
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE COMMUNITY_COMMENT (
    ID                  NUMBER(19)       NOT NULL,
    POST_ID             NUMBER(19)       NOT NULL,
    USER_ID             NUMBER(19)       NOT NULL,
    CONTENT             VARCHAR2(1000)   NOT NULL,
    CREATED_AT          TIMESTAMP,
    CONSTRAINT PK_COMMUNITY_COMMENT PRIMARY KEY (ID),
    CONSTRAINT FK_COMMUNITY_COMMENT_POST
        FOREIGN KEY (POST_ID) REFERENCES COMMUNITY_POST (ID),
    CONSTRAINT FK_COMMUNITY_COMMENT_USER
        FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
);

CREATE OR REPLACE TRIGGER COMMUNITY_COMMENT_BI
    BEFORE INSERT ON COMMUNITY_COMMENT
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_COMMUNITY_COMMENT.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 7. RESTAURANTS
-- 0929 kdk 최종 구조 반영
-- ============================================================
CREATE SEQUENCE SEQ_RESTAURANT
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE RESTAURANTS (
    RESTAURANT_ID       NUMBER(19)       NOT NULL,
    NAME                VARCHAR2(255)    NOT NULL,
    CATEGORY            VARCHAR2(255),
    TAGS                VARCHAR2(255),
    RATING              NUMBER(3,1),
    REVIEW_COUNT        NUMBER(10),
    DESCRIPTION         VARCHAR2(1000),
    ADDRESS             VARCHAR2(4000),
    LATITUDE            NUMBER(10,7),
    LONGITUDE           NUMBER(10,7),
    OPENING_HOURS       VARCHAR2(1000),
    PHONE               VARCHAR2(255),
    PRICE_RANGE         VARCHAR2(50),
    WEBSITE_URL         VARCHAR2(1000),
    SEAT_INFO           VARCHAR2(100),
    RESERVATION_INFO    VARCHAR2(100),
    PAYMENT_METHODS     VARCHAR2(200),
    LANGUAGES           VARCHAR2(200),
    MAIN_IMAGE_URL      VARCHAR2(500),
    MENU_NAME           VARCHAR2(100),
    MENU_DESCRIPTION    VARCHAR2(500),
    MENU_PRICE          VARCHAR2(50),
    MENU_IMAGE_URL      VARCHAR2(500),
    OSM_ID              NUMBER(19),
    -- 이 프로젝트는 OSM에서 적재한 식당을 목록에 바로 노출합니다.
    IS_PUBLISHED         CHAR(1)         DEFAULT 'Y' NOT NULL,
    CREATED_AT          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_AT          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT PK_RESTAURANTS PRIMARY KEY (RESTAURANT_ID),
    CONSTRAINT UQ_RESTAURANTS_OSM_ID UNIQUE (OSM_ID),
    CONSTRAINT CK_RESTAURANTS_PUBLISHED CHECK (IS_PUBLISHED IN ('Y', 'N'))
);

CREATE OR REPLACE TRIGGER RESTAURANTS_BI
    BEFORE INSERT ON RESTAURANTS
    FOR EACH ROW
BEGIN
    IF :NEW.RESTAURANT_ID IS NULL THEN
        SELECT SEQ_RESTAURANT.NEXTVAL
        INTO :NEW.RESTAURANT_ID
        FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 11. BIN_REPORTS (현재 쓰레기통 제보 기능에서 사용)
-- ============================================================
CREATE SEQUENCE BIN_REPORTS_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE BIN_REPORTS (
    ID              NUMBER(19)       NOT NULL,
    USER_ID         NUMBER(19)       NOT NULL,
    LATITUDE        NUMBER(10,7)     NOT NULL,
    LONGITUDE       NUMBER(10,7)     NOT NULL,
    NAME            VARCHAR2(200),
    CATEGORY        VARCHAR2(20),
    ADDRESS         VARCHAR2(300),
    DESCRIPTION     VARCHAR2(500),
    STATUS          VARCHAR2(20)     DEFAULT 'PENDING' NOT NULL,
    REJECT_REASON   VARCHAR2(300),
    REVIEWED_BY     NUMBER(19),
    REVIEWED_AT     TIMESTAMP,
    CREATED_AT      TIMESTAMP        DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_AT      TIMESTAMP,
    CONSTRAINT PK_BIN_REPORTS PRIMARY KEY (ID),
    CONSTRAINT FK_BIN_REPORTS_USER FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
    CONSTRAINT CK_BIN_REPORTS_STATUS CHECK (STATUS IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT CK_BIN_REPORTS_CATEGORY CHECK (CATEGORY IN ('general', 'recycle', 'can') OR CATEGORY IS NULL)
);

CREATE OR REPLACE TRIGGER BIN_REPORTS_BI
    BEFORE INSERT ON BIN_REPORTS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT BIN_REPORTS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 8. NOTICES
-- ============================================================
CREATE SEQUENCE NOTICES_SEQ
    START WITH 6
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE NOTICES (
    ID                  NUMBER(19)       NOT NULL,
    AUTHOR_ID           NUMBER(19)       NOT NULL,
    TITLE               VARCHAR2(200)    NOT NULL,
    CONTENT             CLOB             NOT NULL,
    VIEW_COUNT          NUMBER(10)       DEFAULT 0,
    CREATED_AT          TIMESTAMP,
    UPDATED_AT          TIMESTAMP,
    CONSTRAINT PK_NOTICES PRIMARY KEY (ID),
    CONSTRAINT FK_NOTICES_AUTHOR
        FOREIGN KEY (AUTHOR_ID) REFERENCES USERS (ID)
);

CREATE OR REPLACE TRIGGER NOTICES_BI
    BEFORE INSERT ON NOTICES
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT NOTICES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 9. WASTE_BIN
-- ============================================================
CREATE SEQUENCE WASTE_BIN_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE WASTE_BIN (
    ID                  NUMBER(19)       NOT NULL,
    OSM_ID              NUMBER(19)       NOT NULL,
    NAME                VARCHAR2(100),
    CATEGORY            VARCHAR2(20)     NOT NULL,
    ADDRESS             VARCHAR2(300),
    LATITUDE            NUMBER(10,7)     NOT NULL,
    LONGITUDE           NUMBER(10,7)     NOT NULL,
    CITY                VARCHAR2(50)     DEFAULT 'osaka' NOT NULL,
    CREATED_AT          TIMESTAMP,
    UPDATED_AT          TIMESTAMP,
    CONSTRAINT PK_WASTE_BIN PRIMARY KEY (ID),
    CONSTRAINT UQ_WASTE_BIN_OSM_ID UNIQUE (OSM_ID),
    CONSTRAINT CK_WASTE_BIN_CATEGORY
        CHECK (CATEGORY IN ('general', 'recycle', 'can'))
);

CREATE OR REPLACE TRIGGER WASTE_BIN_BI
    BEFORE INSERT ON WASTE_BIN
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT WASTE_BIN_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 10. RESTAURANT_MENU
-- ============================================================
CREATE SEQUENCE SEQ_RESTAURANT_MENU
    START WITH 11
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE RESTAURANT_MENU (
    ID                  NUMBER(19)       NOT NULL,
    RESTAURANT_ID       NUMBER(19)       NOT NULL,
    NAME                VARCHAR2(100)    NOT NULL,
    PRICE               VARCHAR2(50),
    IS_SIGNATURE        NUMBER(1)        DEFAULT 0,
    CONSTRAINT PK_RESTAURANT_MENU PRIMARY KEY (ID),
    CONSTRAINT FK_MENU_RESTAURANT
        FOREIGN KEY (RESTAURANT_ID) REFERENCES RESTAURANTS (RESTAURANT_ID),
    CONSTRAINT CK_RESTAURANT_MENU_SIGNATURE
        CHECK (IS_SIGNATURE IN (0, 1) OR IS_SIGNATURE IS NULL)
);

CREATE OR REPLACE TRIGGER RESTAURANT_MENU_BI
    BEFORE INSERT ON RESTAURANT_MENU
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_RESTAURANT_MENU.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- 11. SYSTEM_SETTINGS
-- 관리자 설정 / 단일 행(id=1)
-- ============================================================
CREATE TABLE SYSTEM_SETTINGS (
    ID                  NUMBER(19)       NOT NULL,
    SIGNUP_ENABLED      VARCHAR2(1)      DEFAULT 'Y' NOT NULL,
    MAINTENANCE_MODE    VARCHAR2(1)      DEFAULT 'N' NOT NULL,
    MAINTENANCE_MESSAGE VARCHAR2(500),
    CONSTRAINT PK_SYSTEM_SETTINGS PRIMARY KEY (ID),
    CONSTRAINT CK_SETTINGS_SIGNUP CHECK (SIGNUP_ENABLED IN ('Y', 'N')),
    CONSTRAINT CK_SETTINGS_MAINT CHECK (MAINTENANCE_MODE IN ('Y', 'N'))
);

-- ============================================================
-- 12. 테스트 데이터
-- 기존 공동쿼리의 기본 테스트 데이터를 최종 테이블명/컬럼명에 맞게 이관
-- ============================================================

-- ------------------------------------------------------------
-- USERS 5개
-- ------------------------------------------------------------
INSERT INTO USERS (
    ID, NAME, NICKNAME, EMAIL, PASSWORD, NATIONALITY, SNS_TYPE,
    ROLE, SECURITY_QUESTION, SECURITY_ANSWER, NOTIFY_EMAIL, LOCATION_ENABLED,
    CREATED_AT, UPDATED_AT
) VALUES (
    1,
    '안태건', '알레띠NO7', 'atg1234@gmail.com', '$2b$12$BRih3Wu05PG6e/PCmwDJ7.Co6dKp7oK2tjV7aZzlIQQ.rWEhDNBl2',
    '한국', 'X', 'ADMIN', NULL, NULL, NULL, NULL, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO USERS (
    ID, NAME, NICKNAME, EMAIL, PASSWORD, NATIONALITY, SNS_TYPE,
    ROLE, SECURITY_QUESTION, SECURITY_ANSWER, NOTIFY_EMAIL, LOCATION_ENABLED,
    CREATED_AT, UPDATED_AT
) VALUES (
    2,
    '곽동곤', '고재팬', 'kdk1234@gmail.com', '$2b$12$1DlEx1M4ng6DNvqgOdi3Xu.w033kXyRrpoYyXFavXQCyB8D9VONkC',
    '한국', 'X', 'USER', NULL, NULL, 'Y', 'Y', SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO USERS (
    ID, NAME, NICKNAME, EMAIL, PASSWORD, NATIONALITY, SNS_TYPE,
    ROLE, SECURITY_QUESTION, SECURITY_ANSWER, NOTIFY_EMAIL, LOCATION_ENABLED,
    CREATED_AT, UPDATED_AT
) VALUES (
    3,
    '박주호', '주호누오', 'pjh1234@gmail.com', '$2b$12$RW2vV37AzG1CzoUF8d9UJuu97MedLlmsjAKlraoOvhuIaXgfl.6wO',
    '한국', 'X', 'USER', NULL, NULL, 'N', 'N', SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO USERS (
    ID, NAME, NICKNAME, EMAIL, PASSWORD, NATIONALITY, SNS_TYPE,
    ROLE, SECURITY_QUESTION, SECURITY_ANSWER, NOTIFY_EMAIL, LOCATION_ENABLED,
    CREATED_AT, UPDATED_AT
) VALUES (
    4,
    '유해성', '유해성입니다', 'YHS1234@gmail.com', '$2b$12$2wo9lxyNV0M2ZdMXhZ93Se/B8GqZeSxtR8b2egt93QG4phMlWQrYa',
    '일본', 'X', 'USER', NULL, NULL, NULL, NULL, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO USERS (
    ID, NAME, NICKNAME, EMAIL, PASSWORD, NATIONALITY, SNS_TYPE,
    ROLE, SECURITY_QUESTION, SECURITY_ANSWER, NOTIFY_EMAIL, LOCATION_ENABLED,
    CREATED_AT, UPDATED_AT
) VALUES (
    5,
    '장준환', '주난쥬난', 'jjh1234@gmail.com', '$2b$12$6pc0EyeG83RcTpf37qEwHu9VRXcSAz7qH5CsqBywa3Q4ERAS9/B/C',
    '미국', 'X', 'USER', NULL, NULL, NULL, NULL, SYSTIMESTAMP, SYSTIMESTAMP
);

-- ------------------------------------------------------------
-- RESTAURANTS 5개
-- OSM_ID는 실제 Loader 적재 데이터와 충돌하지 않도록 NULL.
-- 샘플 식당도 바로 목록에 표시되도록 IS_PUBLISHED='Y'.
-- ------------------------------------------------------------
INSERT INTO RESTAURANTS (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE,
    PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME,
    MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL, OSM_ID, IS_PUBLISHED
) VALUES (
    1, '쿠쿠루 도톤보리 본점', '타코야끼', '도톤보리,타코야끼,오사카맛집',
    4.6, 1248, '겉은 바삭, 속은 촉촉! 도톤보리 대표 타코야끼 맛집',
    '1-10-5 Dotonbori, Chuo-ku, Osaka', 34.668729, 135.501294,
    '09:00 - 21:00', '+81-6-6212-7381', '¥500 - ¥1,500', 'https://www.kukurutei.com',
    '20석', '예약 불가 (현장 대기)', '현금, 신용카드, 전자화폐', '일본어, 한국어 메뉴판',
    '/images/food-takoyaki.png', '명물 타코야끼 (8개)',
    '쿠쿠루만의 특제 육즙이 가득한 시그니처 메뉴', '¥850',
    'https://via.placeholder.com/64?text=Takoyaki', NULL, 'Y'
);

INSERT INTO RESTAURANTS (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE,
    PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME,
    MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL, OSM_ID, IS_PUBLISHED
) VALUES (
    2, '야끼소바 산페이', '야끼소바', '야끼소바,철판요리,감칠맛',
    4.4, 892, '특제 소스의 깊은 감칠맛이 살아있는 전통 철판 야끼소바 전문점',
    '1-7-14 Dotonbori, Chuo-ku, Osaka', 34.668900, 135.502100,
    '10:30 - 20:30', '+81-6-6211-1234', '¥700 - ¥1,200', 'https://www.sanpei-osaka.jp',
    '15석 (카운터석)', '예약 불가', '현금, 신용카드', '일본어, 영어',
    '/images/food-yakisoba.png', '특제 소스 야끼소바',
    '진한 특제 소스와 쫄깃한 면발의 조화', '¥900',
    'https://via.placeholder.com/64?text=Yakisoba', NULL, 'Y'
);

INSERT INTO RESTAURANTS (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE,
    PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME,
    MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL, OSM_ID, IS_PUBLISHED
) VALUES (
    3, '오코노미야끼 치보 도톤보리빌딩점', '오코노미야끼', '오코노미야끼,철판구이,웨이팅맛집',
    4.5, 1102, '풍미 가득한 일본 정통 부침개! 눈앞에서 구워주는 인기 오코노미야끼 매장',
    '1-5-5 Dotonbori, Chuo-ku, Osaka', 34.668500, 135.503200,
    '11:00 - 21:30', '+81-6-6212-2211', '¥1,000 - ¥2,500', 'https://www.chibo.com',
    '50석 (테이블 및 다찌석)', '전화 예약 가능', '현금, 신용카드, 모바일페이', '한국어 지원 (다국어 키오스크)',
    '/images/food-okonomiyaki.png', '치보 믹스 오코노미야끼',
    '새우, 오징어, 돼지고기가 모두 들어간 베스트 메뉴', '¥1,580',
    'https://via.placeholder.com/64?text=Okonomiyaki', NULL, 'Y'
);

INSERT INTO RESTAURANTS (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE,
    PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME,
    MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL, OSM_ID, IS_PUBLISHED
) VALUES (
    4, '도톤보리 타이야끼', '붕어빵', '길거리간식,붕어빵,디저트',
    4.3, 567, '국산 팥과 바삭한 크러스트의 조화! 따끈하게 즐기는 테이크아웃 붕어빵',
    '1-8-22 Dotonbori, Chuo-ku, Osaka', 34.668350, 135.500800,
    '10:00 - 19:00', '+81-6-6213-9876', '¥300 - ¥600', NULL,
    '없음 (테이크아웃 전용)', '예약 불가', '현금 전용', '일본어 메뉴',
    '/images/food-taiyaki.png', '통단팥 붕어빵',
    '달콤하고 부드러운 팥이 꽉 찬 인기 간식', '¥300',
    'https://via.placeholder.com/64?text=Taiyaki', NULL, 'Y'
);

INSERT INTO RESTAURANTS (
    RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
    DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE,
    PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
    PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL, MENU_NAME,
    MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL, OSM_ID, IS_PUBLISHED
) VALUES (
    5, '카라아게 타로', '닭튀김', '치킨,가라아게,맥주안주',
    4.4, 734, '바삭한 튀김옷 속 육즙이 가득! 특제 마늘 간장 소스로 버무린 정통 일본식 닭튀김',
    '2-2-1 Nanba, Chuo-ku, Osaka', 34.667800, 135.500200,
    '11:00 - 21:00', '+81-6-6631-5544', '¥600 - ¥1,000', 'https://www.karaage-taro.jp',
    '10석', '예약 불가', '현금, 신용카드', '일본어, 영어',
    '/images/food-karaage.png', '카라아게 타로 (오리지널)',
    '겉은 바삭하고 속은 촉촉한 대표 닭튀김', '¥680',
    'https://via.placeholder.com/64?text=Karaage', NULL, 'Y'
);

-- ------------------------------------------------------------
-- REVIEWS 5개
-- 기존 TB_REVIEW가 아니라 최종 reviews 구조로 통일
-- ------------------------------------------------------------
INSERT INTO REVIEWS (
    ID, USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
    VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN, HELP_COUNT,
    CREATED_AT, UPDATED_AT
) VALUES (
    1, 1, 'RESTAURANT', '1', 3, '그닥이던데.. 오바임.. ㅋㅋ',
    TRUNC(SYSDATE) - 10, '점심 11:00~14:00', '여행', 0, 2, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO REVIEWS (
    ID, USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
    VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN, HELP_COUNT,
    CREATED_AT, UPDATED_AT
) VALUES (
    2, 2, 'RESTAURANT', '2', 1, '라멘집인줄 알고 갔네 아 ** !!',
    TRUNC(SYSDATE) - 8, '저녁 18:00~21:00', '친구모임', 0, 0, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO REVIEWS (
    ID, USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
    VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN, HELP_COUNT,
    CREATED_AT, UPDATED_AT
) VALUES (
    3, 3, 'RESTAURANT', '3', 5, '맛있어요오오오오오ㅗ',
    TRUNC(SYSDATE) - 6, '저녁 18:00~21:00', '데이트', 1, 5, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO REVIEWS (
    ID, USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
    VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN, HELP_COUNT,
    CREATED_AT, UPDATED_AT
) VALUES (
    4, 4, 'RESTAURANT', '4', 3.5, '타이야끼인가.. 조금은 아직 어렵습니다..',
    TRUNC(SYSDATE) - 4, '오후 14:00~18:00', '기타', 0, 1, SYSTIMESTAMP, SYSTIMESTAMP
);

INSERT INTO REVIEWS (
    ID, USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
    VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN, HELP_COUNT,
    CREATED_AT, UPDATED_AT
) VALUES (
    5, 5, 'RESTAURANT', '5', 5, '맛있어서 먹다가 울었음 ㅠㅠ',
    TRUNC(SYSDATE) - 2, '점심 11:00~14:00', '가족외식', 1, 3, SYSTIMESTAMP, SYSTIMESTAMP
);

-- ------------------------------------------------------------
-- RESTAURANT_MENU 10개
-- TB_RESTAURANT_MENU를 최종 테이블로 통합
-- ------------------------------------------------------------
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(1, 1, '명물 타코야끼 (8개)', '¥850', 1);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(2, 1, '타코야끼 (12개)', '¥1,200', 0);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(3, 2, '특제 소스 야끼소바', '¥900', 1);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(4, 2, '야끼소바 + 계란', '¥1,050', 0);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(5, 3, '치보 믹스 오코노미야끼', '¥1,580', 1);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(6, 3, '돼지고기 오코노미야끼', '¥1,200', 0);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(7, 4, '통단팥 붕어빵', '¥300', 1);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(8, 4, '커스터드 붕어빵', '¥320', 0);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(9, 5, '카라아게 타로 (오리지널)', '¥680', 1);
INSERT INTO RESTAURANT_MENU (ID, RESTAURANT_ID, NAME, PRICE, IS_SIGNATURE) VALUES
(10, 5, '카라아게 (마늘 간장)', '¥720', 0);

-- ------------------------------------------------------------
-- SYSTEM_SETTINGS 1개 (반드시 id=1)
-- ------------------------------------------------------------
INSERT INTO SYSTEM_SETTINGS (
    ID, SIGNUP_ENABLED, MAINTENANCE_MODE, MAINTENANCE_MESSAGE
) VALUES (
    1, 'Y', 'N', NULL
);

-- ------------------------------------------------------------
-- NOTICES 5개
-- ------------------------------------------------------------
INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (1, 1, 'BinGo Map 오픈 안내',
        'BinGo Map이 오픈했습니다. 오사카 여행 중 쓰레기통과 테이크아웃 맛집을 한 번에 찾아보세요.',
        42, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (2, 1, '쓰레기통 위치 데이터 안내',
        '쓰레기통 위치는 OpenStreetMap 데이터를 기반으로 제공되며 실제와 다를 수 있습니다.',
        31, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (3, 1, '리뷰 작성 가이드',
        '리뷰에는 사진을 최대 3장까지 첨부할 수 있습니다. 솔직한 후기를 남겨주세요.',
        18, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (4, 1, '커뮤니티 이용 수칙',
        '서로를 존중하는 커뮤니티를 만들어 주세요. 광고성·비방 글은 관리자에 의해 삭제될 수 있습니다.',
        12, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (5, 1, '다국어 지원 예정 안내',
        '일본어·영어 지원을 준비 중입니다. 조금만 기다려 주세요.',
        7, SYSTIMESTAMP, SYSTIMESTAMP);

-- ------------------------------------------------------------
-- COMMUNITY_POST 5개
-- ------------------------------------------------------------
INSERT INTO COMMUNITY_POST (ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (1, 2, '도톤보리 쓰레기통 어디에 있나요?',
        '글리코 간판 근처에서 먹고 나서 쓰레기 버릴 곳을 못 찾겠어요. 아시는 분 계신가요?',
        '도톤보리,쓰레기통', 25, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO COMMUNITY_POST (ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (2, 3, '타코야끼 웨이팅 팁',
        '점심시간 전인 11시 전에 가면 대기 없이 먹을 수 있었어요.',
        '타코야끼,팁', 18, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO COMMUNITY_POST (ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (3, 4, '일본은 왜 길에 쓰레기통이 없을까요',
        '여행 중에 계속 궁금했는데 편의점 앞 분리수거함을 이용하면 된다고 하네요.',
        '일본여행,문화', 40, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO COMMUNITY_POST (ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (4, 5, '오사카 2박 3일 맛집 코스 공유',
        '타코야끼 - 오코노미야끼 - 카라아게 순으로 돌았는데 동선이 좋았어요.',
        '코스,오사카맛집', 33, SYSTIMESTAMP, SYSTIMESTAMP);

INSERT INTO COMMUNITY_POST (ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
VALUES (5, 1, '커뮤니티 이용 안내',
        '궁금한 점이나 여행 정보를 자유롭게 공유해 주세요.',
        '공지', 9, SYSTIMESTAMP, SYSTIMESTAMP);

COMMIT;

-- ============================================================
-- 13. 정합성 점검
-- ============================================================

-- 최종 12개 테이블이 모두 존재하는지 확인
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'USERS',
    'FAVORITES',
    'REVIEWS',
    'REVIEW_IMAGE',
    'COMMUNITY_POST',
    'COMMUNITY_COMMENT',
    'RESTAURANTS',
    'NOTICES',
    'WASTE_BIN',
    'RESTAURANT_MENU',
    'SYSTEM_SETTINGS',
    'BIN_REPORTS'
)
ORDER BY table_name;

-- 레거시/중복 테이블이 남아 있지 않은지 확인
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'RESTAURANT',
    'REVIEW',
    'TB_REVIEW',
    'TB_REVIEW_IMAGE',
    'TB_COMMUNITY_POST',
    'TB_COMMUNITY_COMMENT',
    'TB_RESTAURANT_MENU'
)
ORDER BY table_name;

-- 기본 테스트 데이터 건수
SELECT 'USERS' AS TABLE_NAME, COUNT(*) AS CNT FROM USERS
UNION ALL SELECT 'FAVORITES', COUNT(*) FROM FAVORITES
UNION ALL SELECT 'REVIEWS', COUNT(*) FROM REVIEWS
UNION ALL SELECT 'REVIEW_IMAGE', COUNT(*) FROM REVIEW_IMAGE
UNION ALL SELECT 'COMMUNITY_POST', COUNT(*) FROM COMMUNITY_POST
UNION ALL SELECT 'COMMUNITY_COMMENT', COUNT(*) FROM COMMUNITY_COMMENT
UNION ALL SELECT 'RESTAURANTS', COUNT(*) FROM RESTAURANTS
UNION ALL SELECT 'NOTICES', COUNT(*) FROM NOTICES
UNION ALL SELECT 'WASTE_BIN', COUNT(*) FROM WASTE_BIN
UNION ALL SELECT 'RESTAURANT_MENU', COUNT(*) FROM RESTAURANT_MENU
UNION ALL SELECT 'SYSTEM_SETTINGS', COUNT(*) FROM SYSTEM_SETTINGS
UNION ALL SELECT 'BIN_REPORTS', COUNT(*) FROM BIN_REPORTS
ORDER BY TABLE_NAME;

-- 시퀀스 확인 (LAST_NUMBER = 다음에 사용될 번호)
SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name IN (
    'USERS_SEQ',
    'FAVORITES_SEQ',
    'SEQ_REVIEW',
    'SEQ_REVIEW_IMAGE',
    'SEQ_COMMUNITY_POST',
    'SEQ_COMMUNITY_COMMENT',
    'SEQ_RESTAURANT',
    'NOTICES_SEQ',
    'WASTE_BIN_SEQ',
    'SEQ_RESTAURANT_MENU',
    'BIN_REPORTS_SEQ'
)
ORDER BY sequence_name;

-- 트리거 상태 확인
SELECT trigger_name, table_name, status
FROM user_triggers
WHERE trigger_name IN (
    'USERS_BI',
    'FAVORITES_BI',
    'REVIEWS_BI',
    'REVIEW_IMAGE_BI',
    'COMMUNITY_POST_BI',
    'COMMUNITY_COMMENT_BI',
    'RESTAURANTS_BI',
    'NOTICES_BI',
    'WASTE_BIN_BI',
    'RESTAURANT_MENU_BI',
    'BIN_REPORTS_BI'
)
ORDER BY trigger_name;

-- ============================================================
-- 끝
-- ============================================================
