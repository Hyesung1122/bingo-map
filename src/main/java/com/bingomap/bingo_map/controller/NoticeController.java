package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class NoticeController
{
    @GetMapping("/notices")
    public String notices() {
        return "forward:/notices/notices.html";
    }
}
