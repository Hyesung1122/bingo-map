package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RestaurantController
{
    @GetMapping("/restaurants")
    public String restaurants() {
        return "forward:/restaurants/restaurants.html";
    }
}
