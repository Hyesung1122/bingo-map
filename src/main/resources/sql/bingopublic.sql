DROP TABLE reviews CASCADE CONSTRAINTS;
DROP TABLE favorites CASCADE CONSTRAINTS;
DROP TABLE notices CASCADE CONSTRAINTS;
DROP TABLE restaurants CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP SEQUENCE users_seq;
DROP SEQUENCE favorites_seq;
DROP SEQUENCE reviews_seq;
DROP SEQUENCE restaurants_seq;
DROP SEQUENCE notices_seq;
CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE users (
    id          NUMBER          NOT NULL,
    email       VARCHAR2(100)   NOT NULL,
    password    VARCHAR2(255)   NOT NULL,
    name        VARCHAR2(50)    NOT NULL,
    role        VARCHAR2(20)    DEFAULT 'USER' NOT NULL,
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
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
CREATE SEQUENCE restaurants_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE restaurants (
    id          NUMBER          NOT NULL,
    name        VARCHAR2(200)   NOT NULL,
    category    VARCHAR2(50),
    address     VARCHAR2(300),
    latitude    NUMBER          NOT NULL,
    longitude   NUMBER          NOT NULL,
    image_url   VARCHAR2(300),
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_restaurants PRIMARY KEY (id)
);
CREATE OR REPLACE TRIGGER restaurants_bi
    BEFORE INSERT ON restaurants
    FOR EACH ROW
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT restaurants_seq.NEXTVAL INTO :NEW.id FROM dual;
    END IF;
END;
/
CREATE SEQUENCE favorites_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE favorites (
    id          NUMBER          NOT NULL,
    user_id     NUMBER          NOT NULL,
    target_type VARCHAR2(20)    NOT NULL,
    target_id   VARCHAR2(100)   NOT NULL,
    target_name VARCHAR2(200),
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_favorites PRIMARY KEY (id),
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT ck_favorites_target_type CHECK (target_type IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT uq_favorites_target UNIQUE (user_id, target_type, target_id)
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
CREATE SEQUENCE reviews_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE reviews (
    id          NUMBER          NOT NULL,
    user_id     NUMBER          NOT NULL,
    target_type VARCHAR2(20)    NOT NULL,
    target_id   VARCHAR2(100)   NOT NULL,
    rating      NUMBER(1)       NOT NULL,
    content     VARCHAR2(1000),
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_reviews PRIMARY KEY (id),
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT ck_reviews_target_type CHECK (target_type IN ('WASTE_BIN', 'RESTAURANT')),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5)
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
CREATE SEQUENCE notices_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE TABLE notices (
    id          NUMBER          NOT NULL,
    author_id   NUMBER          NOT NULL,
    title       VARCHAR2(200)   NOT NULL,
    content     CLOB            NOT NULL,
    view_count  NUMBER          DEFAULT 0 NOT NULL,
    created_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    updated_at  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_notices PRIMARY KEY (id),
    CONSTRAINT fk_notices_author FOREIGN KEY (author_id) REFERENCES users (id)
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
SELECT table_name FROM user_tables ORDER BY table_name;