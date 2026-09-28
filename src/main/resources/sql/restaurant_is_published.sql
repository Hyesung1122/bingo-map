-- ====================================================================
-- RESTAURANT 테이블 보강 마이그레이션
-- 실제 DB 확인 결과, 아래 3가지가 전부 빠져 있는 상태였음:
--   1) OSM_ID          - RestaurantDbLoader가 필요로 하는 컬럼 (아직 없었음)
--   2) IS_PUBLISHED    - 공개 여부 (Y/N)
--   3) CREATED_AT/UPDATED_AT - BaseEntity가 관리하는 생성/수정 일시
-- ddl-auto: none 이므로 수동으로 1회 실행. 순서 중요 (위에서부터 그대로).
-- ====================================================================

-- 1) OSM Loader가 중복 방지용으로 조회하는 OSM_ID 컬럼 추가
--    - OSM 노드 ID는 정수라 NUMBER(19)로 저장 (RestaurantDbLoader에서 long으로 다룸)
--    - 기존 수기 등록 5건은 OSM에서 온 게 아니므로 NULL로 채워짐 (정상)
--    - UNIQUE 제약: Oracle은 NULL을 여러 개 허용하므로 기존 5건(NULL)끼리는 충돌 안 남
ALTER TABLE RESTAURANT ADD (
    OSM_ID NUMBER(19)
);
ALTER TABLE RESTAURANT ADD CONSTRAINT UQ_RESTAURANT_OSM_ID UNIQUE (OSM_ID);

-- 2) 공개 여부 컬럼 추가 (기본값 'N' → 이후 새로 들어오는 행은 자동으로 비공개 처리됨)
ALTER TABLE RESTAURANT ADD (
    IS_PUBLISHED CHAR(1) DEFAULT 'N' NOT NULL
);
ALTER TABLE RESTAURANT ADD CONSTRAINT CK_RESTAURANT_IS_PUBLISHED
    CHECK (IS_PUBLISHED IN ('Y', 'N'));

-- 3) BaseEntity 대응: 생성일시 / 수정일시 컬럼 추가
ALTER TABLE RESTAURANT ADD (
    CREATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- 4) 기존 수기 등록 5건(쿠쿠루/산페이/치보/타이야끼/카라아게)은
--    이미 정보가 갖춰져 있으므로 바로 공개 처리
--    (2번에서 컬럼을 추가하는 순간 전부 기본값 'N'으로 채워지므로, 이 UPDATE로 되돌려야 함)
UPDATE RESTAURANT SET IS_PUBLISHED = 'Y' WHERE OSM_ID IS NULL;

COMMIT;

-- 확인용 조회
DESC RESTAURANT;
SELECT IS_PUBLISHED, COUNT(*) FROM RESTAURANT GROUP BY IS_PUBLISHED;
