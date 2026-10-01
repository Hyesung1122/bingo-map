-- ============================================================
-- BinGo Map 팀 공통 SQL 1번 통합본 (2026-10-01)
-- 기준: 첨부 1번의 스키마/BCrypt 계정/공개 정책 + 첨부 12테이블 SQL의 추가 2개 테이블
-- Oracle 11g / XE, SQL Developer 전체 F5 실행
--
-- [팀에서 사용할 실행 순서]
-- 1. 이 파일을 BINGO_MODE = SETUP으로 실행 (기존 1번을 대체).
-- 2. BingoMapApplication 실행 -> OSM 쓰레기통/식당 적재 성공 확인.
-- 3. 기존 2번 공개 선별 파일을 APPLY로 실행.
--    기존 2번 파일 내용은 이번 통합에서 변경하지 않았습니다.
-- 별도의 3번 초기화 SQL이나 로그인 복구 SQL은 실행하지 않습니다.
--
-- [보존 / 추가 내용]
-- 기존 10개 테이블, 시퀀스 시작값, 트리거, 공통 계정 5개의 BCrypt 저장값 유지.
-- SYSTEM_SETTINGS 테이블 + 기본 설정 1행 추가.
-- BIN_REPORTS 테이블 + BIN_REPORTS_SEQ + BIN_REPORTS_BI 추가.
-- 공통 공지 5개 / 커뮤니티 글 5개는 1번 그대로 유지.
-- 식당 / 리뷰 / 메뉴 예시 INSERT 없음. RESTAURANTS.IS_PUBLISHED 기본값 N 유지.
-- OSM 식당은 Loader로 적재하며, 이 SQL만으로 사이트의 식당 목록이 채워지지 않습니다.
--
-- [주의]
-- SETUP은 기존 프로젝트 테이블과 데이터를 삭제하고 다시 만드는 초기화 모드입니다.
-- 보존할 DB에는 SETUP으로 재실행하지 마세요. 앱을 종료하고 설치하세요.
-- Oracle DDL은 오류가 나도 이미 수행된 변경을 ROLLBACK으로 되돌릴 수 없습니다.
-- 오류가 발생하면 스크립트를 중단합니다. 오류를 무시하고 다음 단계로 넘어가지 마세요.
-- 앱과 SQL Developer는 같은 DB/사용자에 접속해야 합니다.
-- 이번 프로젝트 ZIP은 빈 파일이어서 최신 앱 전체는 확인하지 못했습니다.
-- 비밀번호 호환성은 이전 LoginService의 BCryptPasswordEncoder를 기준으로 검증했습니다.
--
-- [1번의 기존 기능 유지]
-- PUBLISH: 데이터 삭제 없이 공개 후보만 조회합니다.
-- APPLY: 데이터 삭제 없이 공개 여부를 변경하고 자동 COMMIT합니다.
-- 팀은 위의 기본 순서처럼 이 파일은 SETUP, 공개 선별은 기존 2번으로 사용하면 됩니다.
-- ============================================================

SET SERVEROUTPUT ON
SET DEFINE ON
SET VERIFY OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE BINGO_MODE = SETUP

PROMPT ============================================================
PROMPT [0] 현재 접속 정보
PROMPT ============================================================

SELECT USER AS CONNECTED_USER,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS CURRENT_SCHEMA,
       SYS_CONTEXT('USERENV', 'DB_NAME') AS DB_NAME
FROM DUAL;

PROMPT ============================================================
PROMPT [1] SETUP / PUBLISH 모드 확인
PROMPT ============================================================

BEGIN
    IF UPPER(TRIM('&&BINGO_MODE')) NOT IN ('SETUP', 'PUBLISH', 'APPLY') THEN
        RAISE_APPLICATION_ERROR(
            -20020,
            'BINGO_MODE는 SETUP / PUBLISH / APPLY 중 하나여야 합니다.'
        );
    END IF;
END;
/

PROMPT ============================================================
PROMPT [2] SETUP
PROMPT ============================================================

DECLARE
    V_MODE VARCHAR2(20) := UPPER(TRIM('&&BINGO_MODE'));
BEGIN
    IF V_MODE = 'SETUP' THEN

        DBMS_OUTPUT.PUT_LINE('=== CLEAN REBUILD START ===');

        -- --------------------------------------------------------
        -- 기존 테이블 삭제
        -- --------------------------------------------------------
        FOR T IN (
            SELECT TABLE_NAME
            FROM USER_TABLES
            WHERE TABLE_NAME IN (
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

                -- 레거시
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
                'DROP TABLE "' || T.TABLE_NAME || '" CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('DROP TABLE ' || T.TABLE_NAME);
        END LOOP;

        -- --------------------------------------------------------
        -- 기존 시퀀스 삭제
        -- --------------------------------------------------------
        FOR S IN (
            SELECT SEQUENCE_NAME
            FROM USER_SEQUENCES
            WHERE SEQUENCE_NAME IN (
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
                'BIN_REPORTS_SEQ',

                -- 레거시
                'RESTAURANTS_SEQ',
                'REVIEWS_SEQ',
                'REVIEW_SEQ',
                'TB_REVIEW_SEQ',
                'TB_REVIEW_IMAGE_SEQ',
                'TB_RESTAURANT_MENU_SEQ',
                'SYSTEM_SETTINGS_SEQ'
            )
        ) LOOP
            EXECUTE IMMEDIATE
                'DROP SEQUENCE "' || S.SEQUENCE_NAME || '"';
            DBMS_OUTPUT.PUT_LINE('DROP SEQUENCE ' || S.SEQUENCE_NAME);
        END LOOP;

        -- ========================================================
        -- USERS
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE USERS_SEQ
                START WITH 6
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE USERS (
                ID                  NUMBER(19)      NOT NULL,
                EMAIL               VARCHAR2(100)   NOT NULL,
                PASSWORD            VARCHAR2(255)   NOT NULL,
                NAME                VARCHAR2(50)    NOT NULL,
                NICKNAME            VARCHAR2(30),
                NATIONALITY         VARCHAR2(50),
                SNS_TYPE            VARCHAR2(20),
                SECURITY_QUESTION   VARCHAR2(100),
                SECURITY_ANSWER     VARCHAR2(255),
                NOTIFY_EMAIL        VARCHAR2(1),
                LOCATION_ENABLED    VARCHAR2(1),
                ROLE                VARCHAR2(20)    DEFAULT 'USER' NOT NULL,
                CREATED_AT          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_USERS PRIMARY KEY (ID),
                CONSTRAINT UQ_USERS_EMAIL UNIQUE (EMAIL),
                CONSTRAINT CK_USERS_ROLE CHECK (ROLE IN ('USER', 'ADMIN'))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER USERS_BI
            BEFORE INSERT ON USERS
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT USERS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- FAVORITES
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE FAVORITES_SEQ
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE FAVORITES (
                ID           NUMBER(19)      NOT NULL,
                USER_ID      NUMBER(19)      NOT NULL,
                TARGET_TYPE  VARCHAR2(20)    NOT NULL,
                TARGET_ID    VARCHAR2(100)   NOT NULL,
                TARGET_NAME  VARCHAR2(200),
                CREATED_AT   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_FAVORITES PRIMARY KEY (ID),
                CONSTRAINT FK_FAVORITES_USER
                    FOREIGN KEY (USER_ID) REFERENCES USERS(ID),
                CONSTRAINT CK_FAVORITES_TARGET_TYPE
                    CHECK (TARGET_TYPE IN ('WASTE_BIN', 'RESTAURANT')),
                CONSTRAINT UQ_FAVORITES_TARGET
                    UNIQUE (USER_ID, TARGET_TYPE, TARGET_ID)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER FAVORITES_BI
            BEFORE INSERT ON FAVORITES
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT FAVORITES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- REVIEWS
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_REVIEW
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE REVIEWS (
                ID               NUMBER(19)      NOT NULL,
                USER_ID          NUMBER(19)      NOT NULL,
                TARGET_TYPE      VARCHAR2(20)    NOT NULL,
                TARGET_ID        VARCHAR2(100)   NOT NULL,
                RATING           NUMBER(2,1)     NOT NULL,
                CONTENT          VARCHAR2(2000),
                VISIT_DATE       DATE,
                VISIT_TIME_SLOT  VARCHAR2(20),
                VISIT_PURPOSE    VARCHAR2(20),
                RECOMMEND_YN     NUMBER(1),
                HELP_COUNT       NUMBER(10)     DEFAULT 0 NOT NULL,
                CREATED_AT       TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT       TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_REVIEWS PRIMARY KEY (ID),
                CONSTRAINT FK_REVIEWS_USER
                    FOREIGN KEY (USER_ID) REFERENCES USERS(ID),
                CONSTRAINT CK_REVIEWS_TARGET_TYPE
                    CHECK (TARGET_TYPE IN ('WASTE_BIN', 'RESTAURANT')),
                CONSTRAINT CK_REVIEWS_RATING
                    CHECK (RATING BETWEEN 0.5 AND 5.0),
                CONSTRAINT CK_REVIEWS_RECOMMEND
                    CHECK (RECOMMEND_YN IN (0, 1))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER REVIEWS_BI
            BEFORE INSERT ON REVIEWS
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT SEQ_REVIEW.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;

                IF :NEW.HELP_COUNT IS NULL THEN
                    :NEW.HELP_COUNT := 0;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- REVIEW_IMAGE
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_REVIEW_IMAGE
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE REVIEW_IMAGE (
                ID          NUMBER(19)      NOT NULL,
                REVIEW_ID   NUMBER(19)      NOT NULL,
                IMAGE_URL   VARCHAR2(255)   NOT NULL,
                SORT_ORDER  NUMBER(10),

                CONSTRAINT PK_REVIEW_IMAGE PRIMARY KEY (ID),
                CONSTRAINT FK_REVIEW_IMAGE_REVIEW
                    FOREIGN KEY (REVIEW_ID) REFERENCES REVIEWS(ID)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER REVIEW_IMAGE_BI
            BEFORE INSERT ON REVIEW_IMAGE
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT SEQ_REVIEW_IMAGE.NEXTVAL
                    INTO :NEW.ID
                    FROM DUAL;
                END IF;
            END;
        ]';

        -- ========================================================
        -- COMMUNITY_POST
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_COMMUNITY_POST
                START WITH 6
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE COMMUNITY_POST (
                ID          NUMBER(19)      NOT NULL,
                USER_ID     NUMBER(19)      NOT NULL,
                TITLE       VARCHAR2(200)   NOT NULL,
                CONTENT     CLOB            NOT NULL,
                TAGS        VARCHAR2(200),
                VIEW_COUNT  NUMBER(10)      DEFAULT 0 NOT NULL,
                CREATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT  TIMESTAMP,

                CONSTRAINT PK_COMMUNITY_POST PRIMARY KEY (ID),
                CONSTRAINT FK_COMMUNITY_POST_USER
                    FOREIGN KEY (USER_ID) REFERENCES USERS(ID)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER COMMUNITY_POST_BI
            BEFORE INSERT ON COMMUNITY_POST
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT SEQ_COMMUNITY_POST.NEXTVAL
                    INTO :NEW.ID
                    FROM DUAL;
                END IF;

                IF :NEW.VIEW_COUNT IS NULL THEN
                    :NEW.VIEW_COUNT := 0;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- COMMUNITY_COMMENT
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_COMMUNITY_COMMENT
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE COMMUNITY_COMMENT (
                ID          NUMBER(19)      NOT NULL,
                POST_ID     NUMBER(19)      NOT NULL,
                USER_ID     NUMBER(19)      NOT NULL,
                CONTENT     VARCHAR2(1000)  NOT NULL,
                CREATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_COMMUNITY_COMMENT PRIMARY KEY (ID),
                CONSTRAINT FK_COMMUNITY_COMMENT_POST
                    FOREIGN KEY (POST_ID) REFERENCES COMMUNITY_POST(ID),
                CONSTRAINT FK_COMMUNITY_COMMENT_USER
                    FOREIGN KEY (USER_ID) REFERENCES USERS(ID)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER COMMUNITY_COMMENT_BI
            BEFORE INSERT ON COMMUNITY_COMMENT
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT SEQ_COMMUNITY_COMMENT.NEXTVAL
                    INTO :NEW.ID
                    FROM DUAL;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- RESTAURANTS
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_RESTAURANT
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE RESTAURANTS (
                RESTAURANT_ID     NUMBER(19)      NOT NULL,
                NAME              VARCHAR2(255)   NOT NULL,
                CATEGORY          VARCHAR2(255),
                TAGS              VARCHAR2(255),
                RATING            NUMBER(3,1),
                REVIEW_COUNT      NUMBER(10),
                DESCRIPTION       VARCHAR2(1000),
                ADDRESS           VARCHAR2(4000),
                LATITUDE          NUMBER(10,7),
                LONGITUDE         NUMBER(10,7),
                OPENING_HOURS     VARCHAR2(1000),
                PHONE             VARCHAR2(255),
                PRICE_RANGE       VARCHAR2(50),
                WEBSITE_URL       VARCHAR2(1000),
                SEAT_INFO         VARCHAR2(100),
                RESERVATION_INFO  VARCHAR2(100),
                PAYMENT_METHODS   VARCHAR2(200),
                LANGUAGES         VARCHAR2(200),
                MAIN_IMAGE_URL    VARCHAR2(500),
                MENU_NAME         VARCHAR2(100),
                MENU_DESCRIPTION  VARCHAR2(500),
                MENU_PRICE        VARCHAR2(50),
                MENU_IMAGE_URL    VARCHAR2(500),
                OSM_ID            NUMBER(19),
                IS_PUBLISHED      CHAR(1) DEFAULT 'N' NOT NULL,
                CREATED_AT        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_RESTAURANTS PRIMARY KEY (RESTAURANT_ID),
                CONSTRAINT UQ_RESTAURANTS_OSM_ID UNIQUE (OSM_ID),
                CONSTRAINT CK_RESTAURANTS_IS_PUBLISHED
                    CHECK (IS_PUBLISHED IN ('Y', 'N'))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER RESTAURANTS_BI
            BEFORE INSERT ON RESTAURANTS
            FOR EACH ROW
            BEGIN
                IF :NEW.RESTAURANT_ID IS NULL THEN
                    SELECT SEQ_RESTAURANT.NEXTVAL
                    INTO :NEW.RESTAURANT_ID
                    FROM DUAL;
                END IF;

                IF :NEW.IS_PUBLISHED IS NULL THEN
                    :NEW.IS_PUBLISHED := 'N';
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- NOTICES
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE NOTICES_SEQ
                START WITH 6
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE NOTICES (
                ID          NUMBER(19)      NOT NULL,
                AUTHOR_ID   NUMBER(19)      NOT NULL,
                TITLE       VARCHAR2(200)   NOT NULL,
                CONTENT     CLOB            NOT NULL,
                VIEW_COUNT  NUMBER(10)      DEFAULT 0 NOT NULL,
                CREATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_NOTICES PRIMARY KEY (ID),
                CONSTRAINT FK_NOTICES_AUTHOR
                    FOREIGN KEY (AUTHOR_ID) REFERENCES USERS(ID)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER NOTICES_BI
            BEFORE INSERT ON NOTICES
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT NOTICES_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;

                IF :NEW.VIEW_COUNT IS NULL THEN
                    :NEW.VIEW_COUNT := 0;
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- WASTE_BIN
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE WASTE_BIN_SEQ
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE WASTE_BIN (
                ID          NUMBER(19)      NOT NULL,
                OSM_ID      NUMBER(19)      NOT NULL,
                NAME        VARCHAR2(100),
                CATEGORY    VARCHAR2(20)    NOT NULL,
                ADDRESS     VARCHAR2(300),
                LATITUDE    NUMBER(10,7)    NOT NULL,
                LONGITUDE   NUMBER(10,7)    NOT NULL,
                CITY        VARCHAR2(50)    DEFAULT 'osaka' NOT NULL,
                CREATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
                UPDATED_AT  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,

                CONSTRAINT PK_WASTE_BIN PRIMARY KEY (ID),
                CONSTRAINT UQ_WASTE_BIN_OSM_ID UNIQUE (OSM_ID),
                CONSTRAINT CK_WASTE_BIN_CATEGORY
                    CHECK (CATEGORY IN ('general', 'recycle', 'can'))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER WASTE_BIN_BI
            BEFORE INSERT ON WASTE_BIN
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT WASTE_BIN_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;

                IF :NEW.CITY IS NULL THEN
                    :NEW.CITY := 'osaka';
                END IF;

                IF :NEW.CREATED_AT IS NULL THEN
                    :NEW.CREATED_AT := SYSTIMESTAMP;
                END IF;

                IF :NEW.UPDATED_AT IS NULL THEN
                    :NEW.UPDATED_AT := SYSTIMESTAMP;
                END IF;
            END;
        ]';

        -- ========================================================
        -- RESTAURANT_MENU
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE SEQ_RESTAURANT_MENU
                START WITH 1
                INCREMENT BY 1
                NOCACHE
                NOCYCLE
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE TABLE RESTAURANT_MENU (
                ID             NUMBER(19)     NOT NULL,
                RESTAURANT_ID  NUMBER(19)     NOT NULL,
                NAME           VARCHAR2(100)  NOT NULL,
                PRICE          VARCHAR2(50),
                IS_SIGNATURE   NUMBER(1)      DEFAULT 0,

                CONSTRAINT PK_RESTAURANT_MENU PRIMARY KEY (ID),
                CONSTRAINT FK_RESTAURANT_MENU_RESTAURANT
                    FOREIGN KEY (RESTAURANT_ID)
                    REFERENCES RESTAURANTS(RESTAURANT_ID),
                CONSTRAINT CK_RESTAURANT_MENU_SIGNATURE
                    CHECK (IS_SIGNATURE IN (0, 1))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER RESTAURANT_MENU_BI
            BEFORE INSERT ON RESTAURANT_MENU
            FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT SEQ_RESTAURANT_MENU.NEXTVAL
                    INTO :NEW.ID
                    FROM DUAL;
                END IF;
            END;
        ]';

        -- ========================================================
        -- 추가 통합: SYSTEM_SETTINGS / BIN_REPORTS
        -- ========================================================
        EXECUTE IMMEDIATE q'[
            CREATE TABLE SYSTEM_SETTINGS (
                ID                  NUMBER(19)       NOT NULL,
                SIGNUP_ENABLED      VARCHAR2(1)      DEFAULT 'Y' NOT NULL,
                MAINTENANCE_MODE    VARCHAR2(1)      DEFAULT 'N' NOT NULL,
                MAINTENANCE_MESSAGE VARCHAR2(500),
                CONSTRAINT PK_SYSTEM_SETTINGS PRIMARY KEY (ID),
                CONSTRAINT CK_SETTINGS_SIGNUP CHECK (SIGNUP_ENABLED IN ('Y', 'N')),
                CONSTRAINT CK_SETTINGS_MAINT CHECK (MAINTENANCE_MODE IN ('Y', 'N'))
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE SEQUENCE BIN_REPORTS_SEQ
                START WITH 1
                INCREMENT BY 1
                NOCACHE
        ]';

        EXECUTE IMMEDIATE q'[
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
                CONSTRAINT FK_BIN_REPORTS_USER
                    FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
                CONSTRAINT CK_BIN_REPORTS_STATUS
                    CHECK (STATUS IN ('PENDING', 'APPROVED', 'REJECTED')),
                CONSTRAINT CK_BIN_REPORTS_CATEGORY
                    CHECK (CATEGORY IN ('general', 'recycle', 'can') OR CATEGORY IS NULL)
            )
        ]';

        EXECUTE IMMEDIATE q'[
            CREATE OR REPLACE TRIGGER BIN_REPORTS_BI
                BEFORE INSERT ON BIN_REPORTS
                FOR EACH ROW
            BEGIN
                IF :NEW.ID IS NULL THEN
                    SELECT BIN_REPORTS_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
                END IF;
            END;
        ]';

        -- 관리자 기본 설정: 회원가입 허용, 점검 모드 해제
        EXECUTE IMMEDIATE q'[
            INSERT INTO SYSTEM_SETTINGS (
                ID, SIGNUP_ENABLED, MAINTENANCE_MODE, MAINTENANCE_MESSAGE
            ) VALUES (
                1, 'Y', 'N', NULL
            )
        ]';

        -- ========================================================
        -- 공통 테스트 데이터
        -- ========================================================

        DECLARE
            V_INVALID NUMBER;
        BEGIN
            SELECT COUNT(*) INTO V_INVALID
            FROM USER_OBJECTS
            WHERE OBJECT_TYPE = 'TRIGGER' AND STATUS <> 'VALID'
              AND OBJECT_NAME IN ('USERS_BI', 'FAVORITES_BI', 'REVIEWS_BI', 'REVIEW_IMAGE_BI', 'COMMUNITY_POST_BI', 'COMMUNITY_COMMENT_BI', 'RESTAURANTS_BI', 'NOTICES_BI', 'WASTE_BIN_BI', 'RESTAURANT_MENU_BI', 'BIN_REPORTS_BI');
            IF V_INVALID > 0 THEN
                RAISE_APPLICATION_ERROR(-20021, 'Invalid trigger detected. Check USER_ERRORS.');
            END IF;
        END;

        -- 테스트 계정 5개
        EXECUTE IMMEDIATE q'[
            INSERT INTO USERS (
                ID, EMAIL, PASSWORD, NAME, NICKNAME, NATIONALITY, SNS_TYPE,
                SECURITY_QUESTION, SECURITY_ANSWER,
                NOTIFY_EMAIL, LOCATION_ENABLED, ROLE
            ) VALUES (
                1,
                'atg1234@gmail.com',
                '$2b$12$BRih3Wu05PG6e/PCmwDJ7.Co6dKp7oK2tjV7aZzlIQQ.rWEhDNBl2',
                '안태건',
                '알레띠NO7',
                '한국',
                'X',
                NULL, NULL, NULL, NULL,
                'ADMIN'
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO USERS (
                ID, EMAIL, PASSWORD, NAME, NICKNAME, NATIONALITY, SNS_TYPE,
                SECURITY_QUESTION, SECURITY_ANSWER,
                NOTIFY_EMAIL, LOCATION_ENABLED, ROLE
            ) VALUES (
                2,
                'kdk1234@gmail.com',
                '$2b$12$1DlEx1M4ng6DNvqgOdi3Xu.w033kXyRrpoYyXFavXQCyB8D9VONkC',
                '곽동곤',
                '고재팬',
                '한국',
                'X',
                NULL, NULL, 'Y', 'Y',
                'USER'
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO USERS (
                ID, EMAIL, PASSWORD, NAME, NICKNAME, NATIONALITY, SNS_TYPE,
                SECURITY_QUESTION, SECURITY_ANSWER,
                NOTIFY_EMAIL, LOCATION_ENABLED, ROLE
            ) VALUES (
                3,
                'pjh1234@gmail.com',
                '$2b$12$RW2vV37AzG1CzoUF8dU9Juu97MedLlmsjAKlraoOvhuIaXgfl.6wO',
                '박주호',
                '주호누오',
                '한국',
                'X',
                NULL, NULL, 'N', 'N',
                'USER'
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO USERS (
                ID, EMAIL, PASSWORD, NAME, NICKNAME, NATIONALITY, SNS_TYPE,
                SECURITY_QUESTION, SECURITY_ANSWER,
                NOTIFY_EMAIL, LOCATION_ENABLED, ROLE
            ) VALUES (
                4,
                'YHS1234@gmail.com',
                '$2b$12$2wo9lxyNV0M2ZdMXhZ93Se/B8GqZeSxtR8b2egt93QG4phMlWQrYa',
                '유해성',
                '유해성입니다',
                '일본',
                'X',
                NULL, NULL, NULL, NULL,
                'USER'
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO USERS (
                ID, EMAIL, PASSWORD, NAME, NICKNAME, NATIONALITY, SNS_TYPE,
                SECURITY_QUESTION, SECURITY_ANSWER,
                NOTIFY_EMAIL, LOCATION_ENABLED, ROLE
            ) VALUES (
                5,
                'jjh1234@gmail.com',
                '$2b$12$6pc0EyeG83RcTpf37qEwHu9VRXcSAz7qH5CsqBywa3Q4ERAS9/B/C',
                '장준환',
                '주난쥬난',
                '미국',
                'X',
                NULL, NULL, NULL, NULL,
                'USER'
            )
        ]';

        -- 공지사항 5개
        EXECUTE IMMEDIATE q'[
            INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT)
            VALUES (
                1, 1,
                'BinGo Map 오픈 안내',
                'BinGo Map이 오픈했습니다. 오사카 여행 중 쓰레기통과 테이크아웃 맛집을 한 번에 찾아보세요.',
                42
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT)
            VALUES (
                2, 1,
                '쓰레기통 위치 데이터 안내',
                '쓰레기통 위치는 OpenStreetMap 데이터를 기반으로 제공되며 실제와 다를 수 있습니다.',
                31
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT)
            VALUES (
                3, 1,
                '리뷰 작성 가이드',
                '리뷰에는 사진을 최대 3장까지 첨부할 수 있습니다. 솔직한 후기를 남겨주세요.',
                18
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT)
            VALUES (
                4, 1,
                '커뮤니티 이용 수칙',
                '서로를 존중하는 커뮤니티를 만들어 주세요. 광고성·비방 글은 관리자에 의해 삭제될 수 있습니다.',
                12
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO NOTICES (ID, AUTHOR_ID, TITLE, CONTENT, VIEW_COUNT)
            VALUES (
                5, 1,
                '다국어 지원 예정 안내',
                '일본어·영어 지원을 준비 중입니다. 조금만 기다려 주세요.',
                7
            )
        ]';

        -- 커뮤니티 게시글 5개
        EXECUTE IMMEDIATE q'[
            INSERT INTO COMMUNITY_POST (
                ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT
            ) VALUES (
                1, 2,
                '도톤보리 쓰레기통 어디에 있나요?',
                '글리코 간판 근처에서 먹고 나서 쓰레기 버릴 곳을 못 찾겠어요. 아시는 분 계신가요?',
                '도톤보리,쓰레기통',
                25
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO COMMUNITY_POST (
                ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT
            ) VALUES (
                2, 3,
                '타코야끼 웨이팅 팁',
                '점심시간 전인 11시 전에 가면 대기 없이 먹을 수 있었어요.',
                '타코야끼,팁',
                18
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO COMMUNITY_POST (
                ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT
            ) VALUES (
                3, 4,
                '일본은 왜 길에 쓰레기통이 없을까요',
                '여행 중에 계속 궁금했는데 편의점 앞 분리수거함을 이용하면 된다고 하네요.',
                '일본여행,문화',
                40
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO COMMUNITY_POST (
                ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT
            ) VALUES (
                4, 5,
                '오사카 2박 3일 맛집 코스 공유',
                '타코야끼 - 오코노미야끼 - 카라아게 순으로 돌았는데 동선이 좋았어요.',
                '코스,오사카맛집',
                33
            )
        ]';

        EXECUTE IMMEDIATE q'[
            INSERT INTO COMMUNITY_POST (
                ID, USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT
            ) VALUES (
                5, 1,
                '커뮤니티 이용 안내',
                '궁금한 점이나 여행 정보를 자유롭게 공유해 주세요.',
                '공지',
                9
            )
        ]';

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('=== TEAM SETUP COMPLETE ===');

    ELSE
        DBMS_OUTPUT.PUT_LINE('SETUP skipped. Current mode = ' || V_MODE);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

PROMPT ============================================================
PROMPT [3] SETUP 결과
PROMPT ============================================================

SELECT 'USERS' AS TABLE_NAME, COUNT(*) AS CNT FROM USERS
UNION ALL
SELECT 'FAVORITES', COUNT(*) FROM FAVORITES
UNION ALL
SELECT 'REVIEWS', COUNT(*) FROM REVIEWS
UNION ALL
SELECT 'REVIEW_IMAGE', COUNT(*) FROM REVIEW_IMAGE
UNION ALL
SELECT 'COMMUNITY_POST', COUNT(*) FROM COMMUNITY_POST
UNION ALL
SELECT 'COMMUNITY_COMMENT', COUNT(*) FROM COMMUNITY_COMMENT
UNION ALL
SELECT 'RESTAURANTS', COUNT(*) FROM RESTAURANTS
UNION ALL
SELECT 'NOTICES', COUNT(*) FROM NOTICES
UNION ALL
SELECT 'WASTE_BIN', COUNT(*) FROM WASTE_BIN
UNION ALL
SELECT 'RESTAURANT_MENU', COUNT(*) FROM RESTAURANT_MENU
UNION ALL
SELECT 'SYSTEM_SETTINGS', COUNT(*) FROM SYSTEM_SETTINGS
UNION ALL
SELECT 'BIN_REPORTS', COUNT(*) FROM BIN_REPORTS
ORDER BY 1;

PROMPT ============================================================
PROMPT [4] PUBLICATION
PROMPT ============================================================
PROMPT PUBLISH 모드는 조회만 합니다.
PROMPT APPLY 모드는 RESTAURANTS.IS_PUBLISHED를 실제 변경합니다.
PROMPT RESTAURANTS가 OSM Loader로 채워진 뒤 실행하세요.
PROMPT ============================================================

DECLARE
    V_MODE VARCHAR2(20) := UPPER(TRIM('&&BINGO_MODE'));
BEGIN
    IF V_MODE IN ('PUBLISH', 'APPLY') THEN
        DBMS_OUTPUT.PUT_LINE('PUBLICATION MODE = ' || V_MODE);

        -- --------------------------------------------------------
        -- 공개 후보 계산
        -- --------------------------------------------------------
        DECLARE
            V_TOTAL NUMBER;
            V_DETAIL NUMBER;
            V_BASIC NUMBER;
            V_INCOMPLETE NUMBER;
            V_PLANNED NUMBER;
            V_TO_PUBLISH NUMBER;
            V_TO_HIDE NUMBER;
        BEGIN
            WITH
            CONFIG AS (
                SELECT 50 AS TARGET_COUNT,
                       34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
                       135.35 AS MIN_LON, 135.65 AS MAX_LON
                FROM DUAL
            ),
            FEATURES AS (
                SELECT R.*,
                       P.TARGET_COUNT,

                       CASE
                         WHEN TRIM(R.NAME) IS NOT NULL
                          AND LOWER(TRIM(R.NAME)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요', '이름 없음', 'unnamed')
                          AND TRIM(R.ADDRESS) IS NOT NULL
                          AND LOWER(TRIM(R.ADDRESS)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                          AND TRIM(R.OPENING_HOURS) IS NOT NULL
                          AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요', 'off', 'closed')
                         THEN 1 ELSE 0
                       END AS HAS_BASIC,

                       CASE
                         WHEN TRIM(R.CATEGORY) IS NOT NULL
                          AND LOWER(TRIM(R.CATEGORY)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND TRIM(R.CATEGORY) <> '기타'
                         THEN 1 ELSE 0
                       END AS HAS_CATEGORY,

                       CASE
                         WHEN TRIM(R.PHONE) IS NOT NULL
                          AND LOWER(TRIM(R.PHONE)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                         THEN 1 ELSE 0
                       END AS HAS_PHONE,

                       CASE
                         WHEN TRIM(R.WEBSITE_URL) IS NOT NULL
                          AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND (
                              LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%'
                              OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%'
                          )
                         THEN 1 ELSE 0
                       END AS HAS_WEBSITE,

                       CASE
                         WHEN TRIM(R.DESCRIPTION) IS NOT NULL
                          AND LOWER(TRIM(R.DESCRIPTION)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                         THEN 1 ELSE 0
                       END AS HAS_DESCRIPTION,

                       CASE
                         WHEN TRIM(R.MENU_NAME) IS NOT NULL
                          AND LOWER(TRIM(R.MENU_NAME)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                         THEN 1 ELSE 0
                       END AS HAS_MENU,

                       CASE
                         WHEN TRIM(R.MENU_PRICE) IS NOT NULL
                          AND LOWER(TRIM(R.MENU_PRICE)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]')
                         THEN 1 ELSE 0
                       END AS HAS_PRICE,

                       CASE
                         WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL
                          AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND (
                              TRIM(R.MAIN_IMAGE_URL) LIKE '/%'
                              OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%'
                              OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%'
                          )
                          AND NOT REGEXP_LIKE(
                              LOWER(R.MAIN_IMAGE_URL),
                              'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image'
                          )
                         THEN 1 ELSE 0
                       END AS HAS_MAIN_PHOTO,

                       CASE
                         WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL
                          AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN
                              ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                               '미등록', '확인 필요')
                          AND (
                              TRIM(R.MENU_IMAGE_URL) LIKE '/%'
                              OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%'
                              OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%'
                          )
                          AND NOT REGEXP_LIKE(
                              LOWER(R.MENU_IMAGE_URL),
                              'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image'
                          )
                         THEN 1 ELSE 0
                       END AS HAS_MENU_PHOTO

                FROM RESTAURANTS R
                CROSS JOIN CONFIG P
                WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
                  AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
            ),
            CLASSIFIED AS (
                SELECT F.*,
                       CASE
                         WHEN HAS_BASIC = 1
                          AND HAS_CATEGORY = 1
                          AND HAS_DESCRIPTION = 1
                          AND HAS_MENU = 1
                          AND HAS_PRICE = 1
                          AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1)
                         THEN 1
                         WHEN HAS_BASIC = 1
                         THEN 2
                         ELSE 3
                       END AS INFO_TIER,

                       HAS_PHONE * 2
                       + HAS_WEBSITE * 2
                       + HAS_CATEGORY
                       + HAS_DESCRIPTION
                       + HAS_MENU
                       + HAS_PRICE
                       + HAS_MAIN_PHOTO
                       + HAS_MENU_PHOTO AS INFO_SCORE
                FROM FEATURES F
            ),
            RANKED AS (
                SELECT C.*,
                       COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END)
                           OVER () AS DETAIL_COUNT,
                       ROW_NUMBER() OVER (
                           PARTITION BY INFO_TIER
                           ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
                       ) AS TIER_RANK
                FROM CLASSIFIED C
            ),
            DECISIONS AS (
                SELECT Q.*,
                       CASE
                         WHEN INFO_TIER = 1 THEN 'Y'
                         WHEN INFO_TIER = 2
                          AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0)
                         THEN 'Y'
                         ELSE 'N'
                       END AS NEXT_PUBLISHED
                FROM RANKED Q
            )
            SELECT COUNT(*),
                   COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END),
                   COUNT(CASE WHEN INFO_TIER = 2 THEN 1 END),
                   COUNT(CASE WHEN INFO_TIER = 3 THEN 1 END),
                   COUNT(CASE WHEN NEXT_PUBLISHED = 'Y' THEN 1 END),
                   COUNT(CASE WHEN IS_PUBLISHED = 'N' AND NEXT_PUBLISHED = 'Y' THEN 1 END),
                   COUNT(CASE WHEN IS_PUBLISHED = 'Y' AND NEXT_PUBLISHED = 'N' THEN 1 END)
            INTO V_TOTAL, V_DETAIL, V_BASIC, V_INCOMPLETE,
                 V_PLANNED, V_TO_PUBLISH, V_TO_HIDE
            FROM DECISIONS;

            DBMS_OUTPUT.PUT_LINE('AREA_ROWS      = ' || V_TOTAL);
            DBMS_OUTPUT.PUT_LINE('DETAIL_READY   = ' || V_DETAIL);
            DBMS_OUTPUT.PUT_LINE('BASIC_READY    = ' || V_BASIC);
            DBMS_OUTPUT.PUT_LINE('INCOMPLETE     = ' || V_INCOMPLETE);
            DBMS_OUTPUT.PUT_LINE('PLANNED_PUBLIC = ' || V_PLANNED);
            DBMS_OUTPUT.PUT_LINE('TO_PUBLISH     = ' || V_TO_PUBLISH);
            DBMS_OUTPUT.PUT_LINE('TO_HIDE        = ' || V_TO_HIDE);
        END;

        -- --------------------------------------------------------
        -- APPLY일 때만 실제 공개값 변경
        -- --------------------------------------------------------
        IF V_MODE = 'APPLY' THEN

            MERGE INTO RESTAURANTS TARGET
            USING (
                WITH
                CONFIG AS (
                    SELECT 50 AS TARGET_COUNT,
                           34.55 AS MIN_LAT, 34.82 AS MAX_LAT,
                           135.35 AS MIN_LON, 135.65 AS MAX_LON
                    FROM DUAL
                ),
                FEATURES AS (
                    SELECT R.*,
                           P.TARGET_COUNT,

                           CASE
                             WHEN TRIM(R.NAME) IS NOT NULL
                              AND LOWER(TRIM(R.NAME)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요', '이름 없음', 'unnamed')
                              AND TRIM(R.ADDRESS) IS NOT NULL
                              AND LOWER(TRIM(R.ADDRESS)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND TRIM(R.ADDRESS) <> '주소 정보 없음'
                              AND TRIM(R.OPENING_HOURS) IS NOT NULL
                              AND LOWER(TRIM(R.OPENING_HOURS)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요', 'off', 'closed')
                             THEN 1 ELSE 0
                           END AS HAS_BASIC,

                           CASE
                             WHEN TRIM(R.CATEGORY) IS NOT NULL
                              AND LOWER(TRIM(R.CATEGORY)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND TRIM(R.CATEGORY) <> '기타'
                             THEN 1 ELSE 0
                           END AS HAS_CATEGORY,

                           CASE
                             WHEN TRIM(R.PHONE) IS NOT NULL
                              AND LOWER(TRIM(R.PHONE)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                             THEN 1 ELSE 0
                           END AS HAS_PHONE,

                           CASE
                             WHEN TRIM(R.WEBSITE_URL) IS NOT NULL
                              AND LOWER(TRIM(R.WEBSITE_URL)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND (
                                  LOWER(TRIM(R.WEBSITE_URL)) LIKE 'http://%'
                                  OR LOWER(TRIM(R.WEBSITE_URL)) LIKE 'https://%'
                              )
                             THEN 1 ELSE 0
                           END AS HAS_WEBSITE,

                           CASE
                             WHEN TRIM(R.DESCRIPTION) IS NOT NULL
                              AND LOWER(TRIM(R.DESCRIPTION)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                             THEN 1 ELSE 0
                           END AS HAS_DESCRIPTION,

                           CASE
                             WHEN TRIM(R.MENU_NAME) IS NOT NULL
                              AND LOWER(TRIM(R.MENU_NAME)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                             THEN 1 ELSE 0
                           END AS HAS_MENU,

                           CASE
                             WHEN TRIM(R.MENU_PRICE) IS NOT NULL
                              AND LOWER(TRIM(R.MENU_PRICE)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND REGEXP_LIKE(R.MENU_PRICE, '[0-9]')
                             THEN 1 ELSE 0
                           END AS HAS_PRICE,

                           CASE
                             WHEN TRIM(R.MAIN_IMAGE_URL) IS NOT NULL
                              AND LOWER(TRIM(R.MAIN_IMAGE_URL)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND (
                                  TRIM(R.MAIN_IMAGE_URL) LIKE '/%'
                                  OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'http://%'
                                  OR LOWER(TRIM(R.MAIN_IMAGE_URL)) LIKE 'https://%'
                              )
                              AND NOT REGEXP_LIKE(
                                  LOWER(R.MAIN_IMAGE_URL),
                                  'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image'
                              )
                             THEN 1 ELSE 0
                           END AS HAS_MAIN_PHOTO,

                           CASE
                             WHEN TRIM(R.MENU_IMAGE_URL) IS NOT NULL
                              AND LOWER(TRIM(R.MENU_IMAGE_URL)) NOT IN
                                  ('-', 'unknown', 'n/a', 'null', '정보 없음', '정보없음',
                                   '미등록', '확인 필요')
                              AND (
                                  TRIM(R.MENU_IMAGE_URL) LIKE '/%'
                                  OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'http://%'
                                  OR LOWER(TRIM(R.MENU_IMAGE_URL)) LIKE 'https://%'
                              )
                              AND NOT REGEXP_LIKE(
                                  LOWER(R.MENU_IMAGE_URL),
                                  'placeholder|placehold[.]co|placehold[.]it|dummyimage|no[-_]?image|no[-_]?photo|default[-_]?image'
                              )
                             THEN 1 ELSE 0
                           END AS HAS_MENU_PHOTO

                    FROM RESTAURANTS R
                    CROSS JOIN CONFIG P
                    WHERE R.LATITUDE BETWEEN P.MIN_LAT AND P.MAX_LAT
                      AND R.LONGITUDE BETWEEN P.MIN_LON AND P.MAX_LON
                ),
                CLASSIFIED AS (
                    SELECT F.*,
                           CASE
                             WHEN HAS_BASIC = 1
                              AND HAS_CATEGORY = 1
                              AND HAS_DESCRIPTION = 1
                              AND HAS_MENU = 1
                              AND HAS_PRICE = 1
                              AND (HAS_MAIN_PHOTO = 1 OR HAS_MENU_PHOTO = 1)
                             THEN 1
                             WHEN HAS_BASIC = 1
                             THEN 2
                             ELSE 3
                           END AS INFO_TIER,

                           HAS_PHONE * 2
                           + HAS_WEBSITE * 2
                           + HAS_CATEGORY
                           + HAS_DESCRIPTION
                           + HAS_MENU
                           + HAS_PRICE
                           + HAS_MAIN_PHOTO
                           + HAS_MENU_PHOTO AS INFO_SCORE
                    FROM FEATURES F
                ),
                RANKED AS (
                    SELECT C.*,
                           COUNT(CASE WHEN INFO_TIER = 1 THEN 1 END)
                               OVER () AS DETAIL_COUNT,
                           ROW_NUMBER() OVER (
                               PARTITION BY INFO_TIER
                               ORDER BY INFO_SCORE DESC, RESTAURANT_ID ASC
                           ) AS TIER_RANK
                    FROM CLASSIFIED C
                ),
                DECISIONS AS (
                    SELECT Q.*,
                           CASE
                             WHEN INFO_TIER = 1 THEN 'Y'
                             WHEN INFO_TIER = 2
                              AND TIER_RANK <= GREATEST(TARGET_COUNT - DETAIL_COUNT, 0)
                             THEN 'Y'
                             ELSE 'N'
                           END AS NEXT_PUBLISHED
                    FROM RANKED Q
                )
                SELECT RESTAURANT_ID, NEXT_PUBLISHED
                FROM DECISIONS
            ) CHOSEN
            ON (TARGET.RESTAURANT_ID = CHOSEN.RESTAURANT_ID)
            WHEN MATCHED THEN
                UPDATE SET
                    TARGET.IS_PUBLISHED = CHOSEN.NEXT_PUBLISHED,
                    TARGET.UPDATED_AT = SYSTIMESTAMP
                WHERE TARGET.IS_PUBLISHED <> CHOSEN.NEXT_PUBLISHED;

            DBMS_OUTPUT.PUT_LINE(
                'PUBLICATION CHANGED_ROWS = ' || SQL%ROWCOUNT
            );

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('PUBLICATION COMMIT DONE.');

        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('PUBLICATION skipped. Current mode = SETUP');
    END IF;
END;
/

PROMPT ============================================================
PROMPT [5] 최종 상태 확인
PROMPT ============================================================

SELECT 'USERS' AS TABLE_NAME, COUNT(*) AS CNT FROM USERS
UNION ALL
SELECT 'FAVORITES', COUNT(*) FROM FAVORITES
UNION ALL
SELECT 'REVIEWS', COUNT(*) FROM REVIEWS
UNION ALL
SELECT 'REVIEW_IMAGE', COUNT(*) FROM REVIEW_IMAGE
UNION ALL
SELECT 'COMMUNITY_POST', COUNT(*) FROM COMMUNITY_POST
UNION ALL
SELECT 'COMMUNITY_COMMENT', COUNT(*) FROM COMMUNITY_COMMENT
UNION ALL
SELECT 'RESTAURANTS', COUNT(*) FROM RESTAURANTS
UNION ALL
SELECT 'NOTICES', COUNT(*) FROM NOTICES
UNION ALL
SELECT 'WASTE_BIN', COUNT(*) FROM WASTE_BIN
UNION ALL
SELECT 'RESTAURANT_MENU', COUNT(*) FROM RESTAURANT_MENU
UNION ALL
SELECT 'SYSTEM_SETTINGS', COUNT(*) FROM SYSTEM_SETTINGS
UNION ALL
SELECT 'BIN_REPORTS', COUNT(*) FROM BIN_REPORTS
ORDER BY 1;

SELECT COUNT(*) AS RESTAURANT_TOTAL,
       COUNT(OSM_ID) AS RESTAURANT_OSM_ROWS,
       COUNT(CASE WHEN IS_PUBLISHED = 'Y' THEN 1 END) AS RESTAURANT_PUBLIC_ROWS
FROM RESTAURANTS;

PROMPT ============================================================
PROMPT [6] 레거시 객체 확인
PROMPT ============================================================

SELECT OBJECT_NAME, OBJECT_TYPE
FROM USER_OBJECTS
WHERE OBJECT_NAME IN (
    'RESTAURANT',
    'REVIEW',
    'TB_REVIEW',
    'TB_REVIEW_IMAGE',
    'TB_COMMUNITY_POST',
    'TB_COMMUNITY_COMMENT',
    'TB_RESTAURANT_MENU'
)
ORDER BY OBJECT_TYPE, OBJECT_NAME;

PROMPT ============================================================
PROMPT TEAM_COMMON_SQL_DONE
PROMPT ============================================================
PROMPT SETUP: DB 초기화 + 공통 테스트 데이터 완료
PROMPT PUBLISH: OSM Loader 이후 공개 후보 조회
PROMPT APPLY  : 공개 상태 반영 완료
PROMPT ============================================================


-- 공통 계정 5개의 저장 형식 확인 (비밀번호 문자열은 출력하지 않습니다).
SELECT ID, EMAIL, ROLE,
       CASE WHEN REGEXP_LIKE(PASSWORD, '^[$]2[aby][$][0-9]{2}[$][./A-Za-z0-9]{53}$')
            THEN 'BCRYPT' ELSE 'CHECK_REQUIRED' END AS PASSWORD_FORMAT
FROM USERS
WHERE ID BETWEEN 1 AND 5
ORDER BY ID;

SELECT TRIGGER_NAME, TABLE_NAME, STATUS
FROM USER_TRIGGERS
WHERE TRIGGER_NAME IN ('USERS_BI', 'FAVORITES_BI', 'REVIEWS_BI', 'REVIEW_IMAGE_BI', 'COMMUNITY_POST_BI', 'COMMUNITY_COMMENT_BI', 'RESTAURANTS_BI', 'NOTICES_BI', 'WASTE_BIN_BI', 'RESTAURANT_MENU_BI', 'BIN_REPORTS_BI')
ORDER BY TRIGGER_NAME;

UNDEFINE BINGO_MODE
SET VERIFY ON
SET DEFINE ON
WHENEVER SQLERROR CONTINUE NONE
