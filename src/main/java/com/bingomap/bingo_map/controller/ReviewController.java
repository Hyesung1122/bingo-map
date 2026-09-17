package com.bingomap.bingo_map.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class ReviewController
{
    /** 리뷰 목록(맛집 카드형) 화면 */
    @GetMapping("/reviews")
    public String reviews() {
        return "forward:/reviews/reviews.html";
    }

    /** 리뷰 작성 화면 */
    @GetMapping("/reviews/write")
    public String reviewsWrite() {
        return "forward:/reviews/reviews-write.html";
    }

    /** 맛집 상세 + 리뷰 목록 화면 */
    @GetMapping("/reviews/restaurant/{restaurantId:\\d+}")
    public String restaurantDetail(@PathVariable Long restaurantId) {
        return "forward:/reviews/restaurant-detail.html";
    }

    /**
     * 리뷰 상세 화면 (id는 프론트에서 JS로 읽어 API 호출).
     * {id}를 숫자로만 제한해야 "/reviews" -> "/reviews/reviews.html" forward가
     * 다시 이 매핑에 잡혀 "reviews.html"을 Long으로 변환하려다 400 에러가 나는 걸 막는다.
     */
    @GetMapping("/reviews/{id:\\d+}")
    public String reviewDetail(@PathVariable Long id) {
        return "forward:/reviews/review-detail.html";
    }
}
