//장준환
package com.bingomap.bingo_map.restaurant;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

//장준환
@Controller
@RequestMapping("/restaurants")
public class RestaurantController {

    // 주변 맛집 목록 페이지 - 데이터는 화면의 JS가 /api/restaurants를 fetch해서 채움
    @GetMapping({"", "/"})
    public String restaurantsPage() {
        return "restaurants/restaurants";
    }

    // 주변 맛집 상세 페이지 - 데이터는 화면의 JS가 /api/restaurants/{id}를 fetch해서 채움
    @GetMapping({"/detail", "/{id:[0-9]+}"})
    public String restaurantDetailPage() {
        return "restaurants/detail";
    }
}