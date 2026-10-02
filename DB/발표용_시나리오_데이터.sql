-- ============================================================
-- [10/02 유해성] 발표용 시나리오 데이터 (리뷰 + 커뮤니티 통합본)
-- SQL Developer 에서 전체 선택 후 F5 (스크립트 실행)
--
-- ★ 여러 번 실행해도 안전함
--   [0] 단계에서 이 파일(및 예전 버전)이 넣은 발표용 데이터를 먼저 지우고 다시 넣음
--   → 글·리뷰가 두 번씩 쌓이지 않음. 팀 공통쿼리의 기본 데이터는 건드리지 않음
--
-- 실행 전 확인
--   1. 팀 공통쿼리(최종) SETUP + OSM Loader + 2번 공개 선별(APPLY)까지 끝난 DB
--   2. COMMUNITY_POST_LIKE 테이블 존재 (좋아요_테이블만_추가.sql 실행)
--   3. 회원: 1 안태건(관리자) / 2 곽동곤 / 3 박주호 / 4 유해성 / 5 장준환
--
-- 구성
--   [0] 기존 발표용 데이터 정리
--   [1] 리뷰 16개 (식당 9곳, 대표 메뉴 사진, 도움이 돼요, 방문 정보) + 식당 평점 재계산
--   [2] 커뮤니티 글 14개 (자유 4 · 질문 3 · 꿀팁 4 · 요청 4) + 댓글 24 + 좋아요 21
--   [3] 확인용 조회
--
-- 시연 포인트
--   리뷰  : 리뷰 많은순 1~3위 = 히로시마풍 오코노미야키 플라자 / 감메드 카페 / 포켓몬 카페
--           맛집 상세 "👍 추천 유저 리뷰" = 도움이 돼요가 가장 많은 리뷰
--   커뮤니티: 글 14개 → 2페이지 (관리자 공지 "커뮤니티 이용 안내"는 모든 페이지 맨 위 고정)
--           좋아요 인기글 1번 5 > 3번 4 > 4번 3 > 9·10·13번 2
--           요청 글: 완료 / 처리중 / 반려 + 관리자 답변, 비공개 요청은 작성자·관리자만 보임
--           오른쪽 "리뷰 많은 맛집 TOP 3" 는 [1] 리뷰 데이터 기준
--
-- 발표 후 지우기: 파일 맨 아래 [정리] 안내 참고 ([0] 블록만 실행하면 됨)
-- ============================================================

SET SERVEROUTPUT ON

PROMPT ============================================================
PROMPT [0] 기존 발표용 데이터 정리
PROMPT ============================================================

DECLARE
    TYPE T_LIST IS TABLE OF VARCHAR2(2000);

    -- 커뮤니티 발표용 글 제목 (예전 버전의 "오픈 안내" 포함)
    V_TITLES T_LIST := T_LIST(
        'BinGo Map 커뮤니티 오픈 안내 🎉',
        '도톤보리 쓰레기통 위치 총정리 (글리코 간판 기준)',
        'USJ 근처에 페트병 버릴 곳 있나요?',
        '오사카 2박 3일 맛집 코스 후기',
        '일본 분리배출, 이것만 알면 끝 ♻️',
        '신사이바시 쪽 쓰레기통 위치 추가해 주세요',
        '오사카성 근처 테이크아웃 맛집 추천해 주세요',
        '편의점 앞에서 먹고 정리했더니 직원분이 고맙다고 하셨어요 😊',
        '감메드 카페 영업시간 정보가 달라요',
        '타코야끼 먹고 남은 꼬치·용기 처리 팁',
        '포켓몬 카페 예약 성공 후기 🎉',
        '커뮤니티 글에 사진 올리는 기능 추가해 주세요',
        '자판기 옆 수거함에 컵라면 용기 버려도 되나요?',
        'BinGo Map 경로 안내로 식당 → 쓰레기통 바로 찾기',
        '닉네임 변경 문의드려요'
    );

    -- 리뷰 발표용 내용
    V_CONTENTS T_LIST := T_LIST(
        '면이 들어간 히로시마풍은 처음이었는데 양배추가 달고 소스가 진해서 너무 맛있었어요. 철판 앞자리 추천!',
        '웨이팅 20분 정도 있었지만 회전이 빨라요. 먹고 나서 근처 편의점 분리수거함까지 지도로 바로 찾았어요.',
        '스페셜은 양이 꽤 많아요. 둘이서 하나 시키고 야키소바 추가하면 딱 좋습니다.',
        '한국어 메뉴판은 없지만 사진 메뉴라 주문 어렵지 않았어요.',
        '24시간 영업이라 새벽 도착하자마자 갔어요. 오므라이스 비프 카레 부드럽고 카레가 진해요!',
        '신사이바시 쇼핑하다 쉬어 가기 좋아요. 디저트 메뉴도 다양합니다.',
        '맛은 괜찮은데 점심시간엔 자리가 좀 좁아요. 테이크아웃 추천.',
        '예약 성공해서 다녀왔어요! 피카츄 플레이트 비주얼 최고고 아이들이 정말 좋아했어요 🎉',
        '음료 컵 굿즈까지 챙겨 왔어요. 예약은 한 달 전에 꼭 하세요.',
        '맛보다는 분위기! 사진 찍기 너무 좋아요.',
        '갓 구운 치즈타르트가 따뜻하고 꾸덕해요. 상자째 들고 다니며 먹기 좋아요.',
        '줄은 길지만 금방 빠져요. 다 먹은 상자는 매장 앞 수거함에 버리면 돼요.',
        '자가제면 냉우동 면발이 쫄깃해요. 더운 날 강추!',
        '어패 돈코츠 국물이 진하고 츠케멘 면이 두꺼워서 만족스러웠어요.',
        '철솥 비리야니 향신료 향이 좋아요. 맵기 조절 가능해요.',
        '오마카세 코스 하나하나 정성이 느껴져요. 특별한 날 추천합니다.'
    );

    V_POSTS   NUMBER := 0;
    V_REVIEWS NUMBER := 0;
BEGIN
    -- 커뮤니티: 좋아요 → 댓글 → 글 순서로 삭제 (FK)
    FOR I IN 1 .. V_TITLES.COUNT LOOP
        DELETE FROM COMMUNITY_POST_LIKE WHERE POST_ID IN (SELECT ID FROM COMMUNITY_POST WHERE TITLE = V_TITLES(I));
        DELETE FROM COMMUNITY_COMMENT   WHERE POST_ID IN (SELECT ID FROM COMMUNITY_POST WHERE TITLE = V_TITLES(I));
        DELETE FROM COMMUNITY_POST      WHERE TITLE = V_TITLES(I);
        V_POSTS := V_POSTS + SQL%ROWCOUNT;
    END LOOP;

    -- 리뷰: 사진 → 리뷰 순서로 삭제 (FK)
    FOR I IN 1 .. V_CONTENTS.COUNT LOOP
        DELETE FROM REVIEW_IMAGE WHERE REVIEW_ID IN (SELECT ID FROM REVIEWS WHERE CONTENT = V_CONTENTS(I));
        DELETE FROM REVIEWS WHERE CONTENT = V_CONTENTS(I);
        V_REVIEWS := V_REVIEWS + SQL%ROWCOUNT;
    END LOOP;

    -- 리뷰가 지워진 식당의 평점 / 리뷰 수 다시 계산
    UPDATE RESTAURANTS R
    SET (RATING, REVIEW_COUNT) = (
        SELECT ROUND(AVG(V.RATING), 1), COUNT(*)
        FROM REVIEWS V
        WHERE V.TARGET_TYPE = 'RESTAURANT' AND V.TARGET_ID = TO_CHAR(R.RESTAURANT_ID)
    )
    WHERE R.REVIEW_COUNT > 0;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('기존 발표용 데이터 정리: 글 ' || V_POSTS || '개, 리뷰 ' || V_REVIEWS || '개 삭제');
END;
/

PROMPT ============================================================
PROMPT [1] 리뷰 데이터
PROMPT ============================================================

DECLARE
    V_ADDED   NUMBER := 0;
    V_SKIPPED NUMBER := 0;

    -- 리뷰 1개 추가 (식당 이름으로 찾기, 식당 번호는 DB 마다 다를 수 있음). P_PHOTO = 1 이면 대표 메뉴 사진 첨부
    PROCEDURE ADD_REVIEW(P_USER NUMBER, P_RESTAURANT VARCHAR2, P_RATING NUMBER, P_CONTENT VARCHAR2,
                         P_VISIT_DAYS_AGO NUMBER, P_TIME_SLOT VARCHAR2, P_PURPOSE VARCHAR2,
                         P_HELP NUMBER, P_PHOTO NUMBER, P_HOURS_AGO NUMBER) IS
        V_RID   NUMBER;
        V_IMG   VARCHAR2(500);
        V_ID    NUMBER;
    BEGIN
        SELECT RESTAURANT_ID, MENU_IMAGE_URL INTO V_RID, V_IMG
        FROM RESTAURANTS
        WHERE NAME = P_RESTAURANT AND IS_PUBLISHED = 'Y' AND ROWNUM = 1;

        INSERT INTO REVIEWS (USER_ID, TARGET_TYPE, TARGET_ID, RATING, CONTENT,
                             VISIT_DATE, VISIT_TIME_SLOT, VISIT_PURPOSE, RECOMMEND_YN,
                             HELP_COUNT, CREATED_AT, UPDATED_AT)
        VALUES (P_USER, 'RESTAURANT', TO_CHAR(V_RID), P_RATING, P_CONTENT,
                CASE WHEN P_VISIT_DAYS_AGO IS NULL THEN NULL ELSE TRUNC(SYSDATE) - P_VISIT_DAYS_AGO END,
                P_TIME_SLOT, P_PURPOSE, NULL,
                P_HELP,
                SYSTIMESTAMP - NUMTODSINTERVAL(P_HOURS_AGO, 'HOUR'),
                SYSTIMESTAMP - NUMTODSINTERVAL(P_HOURS_AGO, 'HOUR'))
        RETURNING ID INTO V_ID;

        -- REVIEW_IMAGE.IMAGE_URL 은 255바이트까지라 긴 경로는 사진 없이 저장
        IF P_PHOTO = 1 AND V_IMG IS NOT NULL AND LENGTHB(V_IMG) <= 255 THEN
            INSERT INTO REVIEW_IMAGE (REVIEW_ID, IMAGE_URL, SORT_ORDER) VALUES (V_ID, V_IMG, 0);
        END IF;

        V_ADDED := V_ADDED + 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_SKIPPED := V_SKIPPED + 1;
            DBMS_OUTPUT.PUT_LINE('건너뜀(공개 식당 없음): ' || P_RESTAURANT);
    END;
BEGIN
    -- ── 히로시마풍 오코노미야키 플라자 (리뷰 4개 → 리뷰 많은순 1위)
    ADD_REVIEW(3, '히로시마풍 오코노미야키 플라자', 5.0,
        '면이 들어간 히로시마풍은 처음이었는데 양배추가 달고 소스가 진해서 너무 맛있었어요. 철판 앞자리 추천!',
        5, '저녁 18:00~21:00', '여행', 9, 1, 100);
    ADD_REVIEW(2, '히로시마풍 오코노미야키 플라자', 4.5,
        '웨이팅 20분 정도 있었지만 회전이 빨라요. 먹고 나서 근처 편의점 분리수거함까지 지도로 바로 찾았어요.',
        4, '점심 11:00~14:00', '친구모임', 4, 0, 90);
    ADD_REVIEW(5, '히로시마풍 오코노미야키 플라자', 4.0,
        '스페셜은 양이 꽤 많아요. 둘이서 하나 시키고 야키소바 추가하면 딱 좋습니다.',
        3, '저녁 18:00~21:00', '데이트', 2, 1, 80);
    ADD_REVIEW(4, '히로시마풍 오코노미야키 플라자', 4.5,
        '한국어 메뉴판은 없지만 사진 메뉴라 주문 어렵지 않았어요.',
        NULL, NULL, NULL, 1, 0, 70);

    -- ── 감메드 카페 (리뷰 3개)
    ADD_REVIEW(4, '감메드 카페', 4.5,
        '24시간 영업이라 새벽 도착하자마자 갔어요. 오므라이스 비프 카레 부드럽고 카레가 진해요!',
        6, '심야 21:00~24:00', '여행', 6, 1, 96);
    ADD_REVIEW(2, '감메드 카페', 4.0,
        '신사이바시 쇼핑하다 쉬어 가기 좋아요. 디저트 메뉴도 다양합니다.',
        2, '오후 14:00~18:00', '친구모임', 1, 0, 50);
    ADD_REVIEW(5, '감메드 카페', 3.5,
        '맛은 괜찮은데 점심시간엔 자리가 좀 좁아요. 테이크아웃 추천.',
        1, '점심 11:00~14:00', '기타', 0, 0, 30);

    -- ── 포켓몬 카페 (리뷰 3개)
    ADD_REVIEW(3, '포켓몬 카페', 5.0,
        '예약 성공해서 다녀왔어요! 피카츄 플레이트 비주얼 최고고 아이들이 정말 좋아했어요 🎉',
        7, '점심 11:00~14:00', '가족외식', 8, 1, 110);
    ADD_REVIEW(5, '포켓몬 카페', 4.5,
        '음료 컵 굿즈까지 챙겨 왔어요. 예약은 한 달 전에 꼭 하세요.',
        8, '오후 14:00~18:00', '데이트', 3, 0, 105);
    ADD_REVIEW(2, '포켓몬 카페', 4.0,
        '맛보다는 분위기! 사진 찍기 너무 좋아요.',
        NULL, NULL, NULL, 0, 0, 60);

    -- ── 파블로 (리뷰 2개)
    ADD_REVIEW(4, '파블로', 4.5,
        '갓 구운 치즈타르트가 따뜻하고 꾸덕해요. 상자째 들고 다니며 먹기 좋아요.',
        3, '오후 14:00~18:00', '여행', 2, 1, 45);
    ADD_REVIEW(3, '파블로', 4.0,
        '줄은 길지만 금방 빠져요. 다 먹은 상자는 매장 앞 수거함에 버리면 돼요.',
        2, '오후 14:00~18:00', '친구모임', 1, 0, 40);

    -- ── 리뷰 1개씩
    ADD_REVIEW(5, '아와한다 제면소', 4.5,
        '자가제면 냉우동 면발이 쫄깃해요. 더운 날 강추!',
        4, '점심 11:00~14:00', '여행', 2, 1, 75);
    ADD_REVIEW(2, '카부키고멘 텐진바시 본점', 5.0,
        '어패 돈코츠 국물이 진하고 츠케멘 면이 두꺼워서 만족스러웠어요.',
        5, '저녁 18:00~21:00', '친구모임', 3, 1, 85);
    ADD_REVIEW(4, '다이아몬드 비리야니', 4.0,
        '철솥 비리야니 향신료 향이 좋아요. 맵기 조절 가능해요.',
        9, '저녁 18:00~21:00', '데이트', 1, 1, 120);
    ADD_REVIEW(3, '스시 키노스케', 5.0,
        '오마카세 코스 하나하나 정성이 느껴져요. 특별한 날 추천합니다.',
        10, '저녁 18:00~21:00', '데이트', 4, 1, 130);

    -- 식당 평점 / 리뷰 수 다시 계산 (리뷰가 있는 식당만)
    UPDATE RESTAURANTS R
    SET (RATING, REVIEW_COUNT) = (
        SELECT ROUND(AVG(V.RATING), 1), COUNT(*)
        FROM REVIEWS V
        WHERE V.TARGET_TYPE = 'RESTAURANT' AND V.TARGET_ID = TO_CHAR(R.RESTAURANT_ID)
    )
    WHERE EXISTS (
        SELECT 1 FROM REVIEWS V
        WHERE V.TARGET_TYPE = 'RESTAURANT' AND V.TARGET_ID = TO_CHAR(R.RESTAURANT_ID)
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('리뷰 데이터 추가: ' || V_ADDED || '개 (건너뜀 ' || V_SKIPPED || '개)');
END;
/

PROMPT ============================================================
PROMPT [2] 커뮤니티 데이터
PROMPT ============================================================

DECLARE
    P1 NUMBER;  P2 NUMBER;  P3 NUMBER;  P4 NUMBER;  P5 NUMBER;  P6 NUMBER;  P7 NUMBER;
    P8 NUMBER;  P9 NUMBER;  P10 NUMBER; P11 NUMBER; P12 NUMBER; P13 NUMBER; P14 NUMBER;

    FUNCTION ADD_POST(P_USER NUMBER, P_TITLE VARCHAR2, P_CONTENT VARCHAR2,
                      P_TAGS VARCHAR2, P_VIEWS NUMBER, P_HOURS_AGO NUMBER) RETURN NUMBER IS
        V_ID NUMBER;
    BEGIN
        INSERT INTO COMMUNITY_POST (USER_ID, TITLE, CONTENT, TAGS, VIEW_COUNT, CREATED_AT, UPDATED_AT)
        VALUES (P_USER, P_TITLE, P_CONTENT, P_TAGS, P_VIEWS,
                SYSTIMESTAMP - NUMTODSINTERVAL(P_HOURS_AGO, 'HOUR'),
                SYSTIMESTAMP - NUMTODSINTERVAL(P_HOURS_AGO, 'HOUR'))
        RETURNING ID INTO V_ID;
        RETURN V_ID;
    END;

    PROCEDURE ADD_COMMENT(P_POST NUMBER, P_USER NUMBER, P_CONTENT VARCHAR2, P_HOURS_AGO NUMBER) IS
    BEGIN
        INSERT INTO COMMUNITY_COMMENT (POST_ID, USER_ID, CONTENT, CREATED_AT)
        VALUES (P_POST, P_USER, P_CONTENT, SYSTIMESTAMP - NUMTODSINTERVAL(P_HOURS_AGO, 'HOUR'));
    END;

    PROCEDURE ADD_LIKE(P_POST NUMBER, P_USER NUMBER) IS
    BEGIN
        INSERT INTO COMMUNITY_POST_LIKE (POST_ID, USER_ID) VALUES (P_POST, P_USER);
    END;
BEGIN
    -- 1. 꿀팁 (인기글 1위)
    P1 := ADD_POST(3, '도톤보리 쓰레기통 위치 총정리 (글리코 간판 기준)',
        '1) 글리코 간판 맞은편 편의점 앞 분리수거함 (페트·캔)' || CHR(10) ||
        '2) 에비스바시 다리 건너 드러그스토어 입구 옆' || CHR(10) ||
        '3) 타코야끼 가게 대부분은 가게 앞에서 먹으면 용기를 회수해 줘요.' || CHR(10) ||
        'BinGo Map 지도에서 "근처 쓰레기통"으로 보면 더 정확해요!',
        '#꿀팁', 128, 120);

    -- 2. 질문 (유저끼리 답변)
    P2 := ADD_POST(2, 'USJ 근처에 페트병 버릴 곳 있나요?',
        '유니버설 스튜디오 나와서 역까지 걸어가는데 페트병 버릴 곳을 못 찾았어요. 아시는 분?',
        '#질문', 64, 110);

    -- 3. 자유 (인기글 2위)
    P3 := ADD_POST(5, '오사카 2박 3일 맛집 코스 후기',
        '1일차 도톤보리 오코노미야키 → 2일차 신사이바시 오므라이스 → 3일차 텐진바시 츠케멘.' || CHR(10) ||
        '다 먹고 나서 지도에서 바로 쓰레기통 찾을 수 있어서 편했어요 👍',
        NULL, 87, 100);

    -- 4. 꿀팁 (인기글 3위)
    P4 := ADD_POST(4, '일본 분리배출, 이것만 알면 끝 ♻️',
        '· 가연 쓰레기: 휴지, 음식물 묻은 종이' || CHR(10) ||
        '· 페트병: 뚜껑과 라벨 떼고 헹궈서' || CHR(10) ||
        '· 캔·병: 자판기 옆 전용 수거함' || CHR(10) ||
        '편의점 쓰레기통은 그 가게에서 산 물건 위주로 버리는 게 매너예요.',
        '#꿀팁', 75, 90);

    -- 5. 요청 · 완료
    P5 := ADD_POST(4, '신사이바시 쪽 쓰레기통 위치 추가해 주세요',
        '신사이바시스지 상점가 북쪽 입구 편의점 앞에 분리수거함이 있는데 지도에 안 나와요.',
        '#요청,#완료', 21, 80);

    -- 6. 질문
    P6 := ADD_POST(4, '오사카성 근처 테이크아웃 맛집 추천해 주세요',
        '오사카성 공원에서 피크닉하면서 먹을 만한 곳 있을까요? 다 먹고 버릴 곳도 가까우면 좋겠어요.',
        '#질문', 48, 72);

    -- 7. 자유
    P7 := ADD_POST(2, '편의점 앞에서 먹고 정리했더니 직원분이 고맙다고 하셨어요 😊',
        '삼각김밥 먹고 쓰레기 분리해서 버렸더니 직원분이 "아리가또"라고 해 주셨어요. 작은 매너가 여행을 더 즐겁게 하네요.',
        NULL, 39, 64);

    -- 8. 요청 · 처리중
    P8 := ADD_POST(3, '감메드 카페 영업시간 정보가 달라요',
        '지도에는 24시간이라고 나오는데 가 보니 새벽 2시~6시는 문을 닫았어요. 확인 부탁드려요.',
        '#요청,#처리중', 15, 56);

    -- 9. 꿀팁
    P9 := ADD_POST(5, '타코야끼 먹고 남은 꼬치·용기 처리 팁',
        '타코야끼 가게 앞에 전용 수거함이 있는 곳이 많아요. 가게 앞에서 다 먹고 바로 반납하면 들고 다닐 필요가 없어요. 꼬치는 휴지로 감싸서 버리기!',
        '#꿀팁', 52, 48);

    -- 10. 자유
    P10 := ADD_POST(3, '포켓몬 카페 예약 성공 후기 🎉',
        '한 달 전에 예약 열리자마자 들어가서 겨우 성공했어요. 피카츄 플레이트 너무 귀여워서 먹기 아까웠어요. 맛집 리뷰에도 남겨 뒀어요!',
        NULL, 66, 40);

    -- 11. 요청 · 반려
    P11 := ADD_POST(2, '커뮤니티 글에 사진 올리는 기능 추가해 주세요',
        '쓰레기통 위치를 사진으로 보여 주면 더 찾기 쉬울 것 같아요.',
        '#요청,#반려', 18, 32);

    -- 12. 질문
    P12 := ADD_POST(5, '자판기 옆 수거함에 컵라면 용기 버려도 되나요?',
        '편의점에서 컵라면 먹고 나왔는데 자판기 옆 수거함밖에 없더라고요. 여기 버려도 되는 건가요?',
        '#질문', 33, 24);

    -- 13. 꿀팁
    P13 := ADD_POST(2, 'BinGo Map 경로 안내로 식당 → 쓰레기통 바로 찾기',
        '맛집 상세에서 경로 안내를 누르면 식당에서 가장 가까운 쓰레기통까지 길을 알려 줘요. 테이크아웃할 때 진짜 유용합니다.',
        '#꿀팁', 41, 16);

    -- 14. 요청 · 접수 · 비공개 (작성자·관리자만 보임)
    P14 := ADD_POST(5, '닉네임 변경 문의드려요',
        '가입할 때 닉네임을 잘못 입력했는데 변경할 수 있을까요? 개인 정보가 들어가서 비공개로 남깁니다.',
        '#요청,#접수,#비공개', 2, 3);

    -- 댓글
    ADD_COMMENT(P1, 2, '2번 위치 저도 써 봤는데 진짜 있어요. 감사합니다!', 115);
    ADD_COMMENT(P1, 5, '글리코 간판 앞은 사람이 너무 많아서 이 정보 꿀이네요', 112);
    ADD_COMMENT(P1, 3, '도움 되셨다니 다행이에요 🙌', 111);

    ADD_COMMENT(P2, 4, '유니버설 시티역 개찰구 앞 자판기 옆에 수거함 있어요!', 108);
    ADD_COMMENT(P2, 5, '시티워크 1층 편의점 앞에도 페트·캔 분리수거함 있어요. BinGo Map 지도에서 "근처 쓰레기통" 누르면 바로 나와요 👍', 105);
    ADD_COMMENT(P2, 2, '두 분 덕분에 찾았어요! 감사합니다 🙏', 104);

    ADD_COMMENT(P3, 3, '3일차 츠케멘 가게 이름 알려 주실 수 있나요?', 95);
    ADD_COMMENT(P3, 5, '카부키고멘 텐진바시 본점이에요! 맛집 리뷰에 남겨 뒀어요', 94);

    ADD_COMMENT(P4, 2, '라벨 떼는 건 몰랐네요. 저장해 둘게요!', 85);

    ADD_COMMENT(P5, 1, '[관리자] 제보 감사합니다. 확인 후 지도에 반영했어요! (상태: 완료)', 70);
    ADD_COMMENT(P5, 4, '빠른 처리 감사합니다 👍', 68);

    ADD_COMMENT(P6, 3, '텐진바시 쪽 리카쇼쿠도 카레 테이크아웃 돼요! 공원까지 걸어서 15분 정도예요.', 70);
    ADD_COMMENT(P6, 2, '카페 태양의 탑 푸딩도 추천해요. 공원 입구에 분리수거함 있어요.', 66);
    ADD_COMMENT(P6, 4, '둘 다 가 볼게요 감사해요!', 65);

    ADD_COMMENT(P7, 5, '저도 이런 경험 있어요 ㅎㅎ 기분 좋아지죠', 60);

    ADD_COMMENT(P8, 1, '[관리자] 매장에 확인 중이에요. 확인되는 대로 수정하겠습니다.', 50);

    ADD_COMMENT(P9, 4, '꼬치는 휴지로 감싸는 거 좋은 팁이네요!', 45);

    ADD_COMMENT(P10, 2, '와 부러워요… 예약 팁 더 알려 주세요!', 38);
    ADD_COMMENT(P10, 3, '오전 10시에 예약 열리는데 미리 로그인해 두면 돼요!', 37);

    ADD_COMMENT(P11, 1, '[관리자] 좋은 의견 감사합니다. 사진 저장 공간 문제로 이번에는 반영이 어려워 반려되었어요. 추후 다시 검토할게요.', 30);

    ADD_COMMENT(P12, 3, '자판기 옆은 캔·페트 전용이라 컵라면 용기는 안 돼요. 컵라면 산 편의점에 버리시는 게 맞아요.', 22);
    ADD_COMMENT(P12, 4, '국물은 꼭 비우고 버려야 해요!', 20);
    ADD_COMMENT(P12, 5, '아하 몰랐네요. 감사합니다!', 19);

    ADD_COMMENT(P13, 5, '이거 진짜 편해요. 테이크아웃하고 바로 써먹었어요', 12);

    -- 좋아요 (인기글 순위: 1번 5 > 3번 4 > 4번 3 > 9·10·13번 2 > 2·6·7번 1)
    ADD_LIKE(P1, 1); ADD_LIKE(P1, 2); ADD_LIKE(P1, 3); ADD_LIKE(P1, 4); ADD_LIKE(P1, 5);
    ADD_LIKE(P3, 1); ADD_LIKE(P3, 2); ADD_LIKE(P3, 3); ADD_LIKE(P3, 4);
    ADD_LIKE(P4, 2); ADD_LIKE(P4, 3); ADD_LIKE(P4, 5);
    ADD_LIKE(P9, 3); ADD_LIKE(P9, 4);
    ADD_LIKE(P10, 2); ADD_LIKE(P10, 5);
    ADD_LIKE(P13, 4); ADD_LIKE(P13, 5);
    ADD_LIKE(P2, 4);
    ADD_LIKE(P6, 3);
    ADD_LIKE(P7, 5);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('커뮤니티 데이터 추가: 글 14개');
END;
/

PROMPT ============================================================
PROMPT [3] 확인
PROMPT ============================================================

-- 리뷰 많은 식당 순
SELECT R.NAME, R.RATING, R.REVIEW_COUNT
FROM RESTAURANTS R
WHERE R.REVIEW_COUNT > 0
ORDER BY R.REVIEW_COUNT DESC, R.RATING DESC;

-- 커뮤니티 글 목록 (같은 제목이 2번 이상 나오면 안 됨)
SELECT TITLE, COUNT(*) AS CNT
FROM COMMUNITY_POST
GROUP BY TITLE
ORDER BY CNT DESC, TITLE;


-- ============================================================
-- [정리] 발표 후 발표용 데이터만 지우기
--   이 파일의 [0] 블록(DECLARE ~ END; /)만 선택해서 실행하세요.
--   리뷰·커뮤니티 발표용 데이터가 모두 지워지고 식당 평점도 다시 계산됩니다.
-- ============================================================
