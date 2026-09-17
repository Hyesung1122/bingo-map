package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.MenuItemDto;
import com.bingomap.bingo_map.dto.RestaurantDto;
import com.bingomap.bingo_map.repository.RestaurantMenuItemRepository;
import com.bingomap.bingo_map.repository.RestaurantRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 리뷰 화면(작성/목록/상세)에서 실제 맛집 이름·사진을 보여주기 위한 읽기 전용 API.
 * 맛집 담당자가 자기 쪽 RestaurantApiController를 이미 만들어뒀다면 이 파일은 지우고
 * 그쪽 API를 쓰면 됨 (경로가 겹치지 않게 /api/restaurants 로 맞춰서 씀).
 */
@RestController
@RequestMapping("/api/restaurants")
public class RestaurantApiController {

    private final RestaurantRepository restaurantRepository;
    private final RestaurantMenuItemRepository menuItemRepository;

    public RestaurantApiController(RestaurantRepository restaurantRepository,
                                    RestaurantMenuItemRepository menuItemRepository) {
        this.restaurantRepository = restaurantRepository;
        this.menuItemRepository = menuItemRepository;
    }

    @GetMapping
    public List<RestaurantDto> getRestaurants() {
        return restaurantRepository.findAll().stream().map(RestaurantDto::new).toList();
    }

    @GetMapping("/{id:\\d+}")
    public RestaurantDto getRestaurant(@PathVariable Long id) {
        return restaurantRepository.findById(id).map(RestaurantDto::new).orElse(null);
    }

    @GetMapping("/{id:\\d+}/menu")
    public List<MenuItemDto> getMenu(@PathVariable Long id) {
        return menuItemRepository.findByRestaurantIdOrderByMenuIdAsc(id).stream().map(MenuItemDto::new).toList();
    }
}
