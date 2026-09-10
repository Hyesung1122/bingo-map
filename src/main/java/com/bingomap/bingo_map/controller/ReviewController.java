package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ReviewController
{
    @GetMapping("/reviews")
    public String reviews() {
        return "forward:/reviews/reviews.html";
    }
}
