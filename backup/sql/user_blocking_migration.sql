-- Run once against an existing Oracle database before starting the app with user blocking enabled.
-- Fresh installations using DB/BinGoMap_팀_공통쿼리(최종)_좋아요추가.sql already create these columns.
ALTER TABLE USERS ADD (
    BLOCKED_UNTIL TIMESTAMP,
    BLOCKED_PERMANENT CHAR(1) DEFAULT 'N' NOT NULL
);

-- Allow the new intermediate management role on existing databases.
ALTER TABLE USERS DROP CONSTRAINT CK_USERS_ROLE;
ALTER TABLE USERS ADD CONSTRAINT CK_USERS_ROLE CHECK (ROLE IN ('USER', 'MANAGER', 'ADMIN'));
