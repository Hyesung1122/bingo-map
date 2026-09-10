package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MapContoller
{
    @GetMapping("/map")
    public String map()
    {
        return "forward:/map/map.html";
    }
}