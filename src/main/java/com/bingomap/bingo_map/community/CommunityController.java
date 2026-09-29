package com.bingomap.bingo_map.community;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class CommunityController {

    @GetMapping("/community")
    public String community() {
        return "forward:/community/community.html";
    }

    @GetMapping("/community/write")
    public String communityWrite() {
        return "forward:/community/community-write.html";
    }

    @GetMapping("/community/{id:\\d+}")
    public String communityDetail(@PathVariable Long id) {
        return "forward:/community/community-detail.html";
    }
}