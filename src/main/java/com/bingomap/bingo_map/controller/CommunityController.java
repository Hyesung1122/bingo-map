package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class CommunityController {

    /** 게시판 목록 */
    @GetMapping("/community")
    public String community() {
        return "forward:/community/community.html";
    }

    /** 글쓰기 */
    @GetMapping("/community/write")
    public String communityWrite() {
        return "forward:/community/community-write.html";
    }

    /** 게시글 상세 (id는 숫자만 매칭 - /community 목록 forward와 충돌 방지) */
    @GetMapping("/community/{id:\\d+}")
    public String communityDetail(@PathVariable Long id) {
        return "forward:/community/community-detail.html";
    }
}
