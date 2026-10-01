package com.bingomap.bingo_map.community;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * [10/01 유해성] DB 컬럼 추가 없이 TAGS 컬럼에 말머리 / 요청 상태 / 비공개 여부를 함께 저장.
 * "#" 으로 시작하는 태그는 예약 태그(서버만 붙임), 나머지는 사용자가 쓴 일반 태그.
 *   예) "#요청,#접수,#비공개,쓰레기통,도톤보리"
 */
final class CommunityTags {

    static final String FREE = "자유";
    static final String QUESTION = "질문";
    static final String TIP = "꿀팁";
    static final String REQUEST = "요청";
    static final String NOTICE = "공지";

    static final List<String> CATEGORIES = List.of(FREE, NOTICE, QUESTION, TIP, REQUEST);
    static final List<String> STATUSES = List.of("접수", "처리중", "완료", "반려");
    static final String FIRST_STATUS = "접수";

    private static final String PRIVATE = "비공개";
    private static final int MAX_BYTES = 200;   // TAGS VARCHAR2(200) 바이트 기준

    String category = FREE;
    String status;                 // 요청 글만
    boolean privateRequest;        // 요청 글만
    List<String> userTags = new ArrayList<>();

    /** DB 에 저장된 TAGS 문자열을 나눔 */
    static CommunityTags parse(String raw) {
        CommunityTags t = new CommunityTags();
        if (raw == null || raw.isBlank()) {
            return t;
        }
        for (String part : raw.split(",")) {
            String tag = part.trim();
            if (tag.isEmpty()) {
                continue;
            }
            if (!tag.startsWith("#")) {
                t.userTags.add(tag);
                continue;
            }
            String name = tag.substring(1);
            if (CATEGORIES.contains(name)) {
                t.category = name;
            } else if (STATUSES.contains(name)) {
                t.status = name;
            } else if (PRIVATE.equals(name)) {
                t.privateRequest = true;
            }
        }
        return t;
    }

    /** 사용자가 입력한 태그. "#" 은 떼어내서 예약 태그를 흉내낼 수 없게 함 */
    static List<String> cleanUserTags(String input) {
        if (input == null || input.isBlank()) {
            return new ArrayList<>();
        }
        Set<String> tags = Arrays.stream(input.split(","))
                .map(s -> s.trim().replaceFirst("^#+", "").trim())
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toCollection(LinkedHashSet::new));
        return new ArrayList<>(tags);
    }

    /** 화면이 보낸 말머리를 정리. 모르는 값은 자유, 공지는 관리자만 */
    static String normalizeCategory(String category, boolean admin) {
        String c = category == null ? FREE : category.trim();
        if (!CATEGORIES.contains(c)) {
            return FREE;
        }
        if (NOTICE.equals(c) && !admin) {
            return FREE;
        }
        return c;
    }

    boolean isRequest() {
        return REQUEST.equals(category);
    }

    /**
     * 관리자가 쓴 글에 예전 방식의 "공지" 일반 태그가 있으면 공지 말머리로 취급
     * (기존 테스트 데이터 "커뮤니티 이용 안내" 같은 글)
     */
    String effectiveCategory(boolean authorAdmin) {
        if (FREE.equals(category) && authorAdmin && userTags.contains(NOTICE)) {
            return NOTICE;
        }
        return category;
    }

    /** DB 에 저장할 TAGS 문자열. 200바이트를 넘으면 400 */
    String toRaw() {
        List<String> parts = new ArrayList<>();
        if (!FREE.equals(category)) {
            parts.add("#" + category);
        }
        if (isRequest()) {
            parts.add("#" + (status == null ? FIRST_STATUS : status));
            if (privateRequest) {
                parts.add("#" + PRIVATE);
            }
        }
        parts.addAll(userTags);

        if (parts.isEmpty()) {
            return null;
        }
        String raw = String.join(",", parts);
        if (raw.getBytes(StandardCharsets.UTF_8).length > MAX_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "태그가 너무 길어요. 태그 수를 줄여주세요.");
        }
        return raw;
    }
}
