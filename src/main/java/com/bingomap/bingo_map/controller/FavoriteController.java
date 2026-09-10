package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FavoriteController
{
    @GetMapping("/favorites")
    public String favorites() {
        return "forward:/favorites/favorites.html";
    }
}
