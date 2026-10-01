package com.bingomap.bingo_map.restaurant;

import com.bingomap.bingo_map.restaurant.menu.MenuItemDto;
import com.bingomap.bingo_map.restaurant.menu.RestaurantMenuItemRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 주변 맛집 데이터 REST API.
 * map.html이 /api/bins를 fetch하는 것과 같은 패턴: 이 컨트롤러는 JSON만 반환하고,
 * 화면(restaurants.html / detail.html)의 JS가 fetch로 받아서 직접 그림.
 *
 * 원래 이 파일은 리뷰 담당자가 임시로 만들어둔 것이었는데,
 * 맛집 담당자가 정식으로 만들면서 대체함. /menu는 리뷰 화면이 그대로 쓰고 있어서 유지.
 * ※ 예전에 만든 RestaurantAdminApiController.java는 publish/unpublish가 여기로
 *   합쳐졌으니 삭제할 것 (안 지우면 같은 경로가 겹쳐서 서버 시작 시 에러남).
 */
@RestController
@RequestMapping("/api/restaurants")
public class RestaurantApiController {

    private final RestaurantService restaurantService;
    private final RestaurantMenuItemRepository menuItemRepository;

    public RestaurantApiController(RestaurantService restaurantService,
                                   RestaurantMenuItemRepository menuItemRepository) {
        this.restaurantService = restaurantService;
        this.menuItemRepository = menuItemRepository;
    }

    // 맛집 목록 (지역 필터 + 페이징) - restaurants.html의 JS가 fetch
    @GetMapping
    public RestaurantListResponse getRestaurants(
            @RequestParam(value = "region", defaultValue = "dotonbori") String region,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size);
        Page<RestaurantDto> result = restaurantService.findPagedByRegion(region, pageable);

        return new RestaurantListResponse(
                result.getContent(),
                result.getNumber(),
                result.getTotalPages(),
                result.getTotalElements()
        );
    }

    // 홈 인기 테이크아웃 맛집 (리뷰 순위 + 기존 평점 기반 보완, 최대 10개)
    @GetMapping("/popular")
    public List<RestaurantDto> getPopularRestaurants() {
        return restaurantService.getPopularTakeoutRestaurants(10);
    }

    // 맛집 상세 - detail.html의 JS가 fetch
    @GetMapping("/{id:\\d+}")
    public ResponseEntity<RestaurantDto> getRestaurant(@PathVariable Long id) {
        RestaurantDto restaurant = restaurantService.findById(id);
        if (restaurant == null) {
            return ResponseEntity.notFound().build();
        }
        restaurant.setRegion(restaurantService.resolveRegion(restaurant.getAddress()));
        return ResponseEntity.ok(restaurant);
    }

    // 주변 다른 맛집 추천 - detail.html의 JS가 fetch
    @GetMapping("/{id:\\d+}/nearby")
    public ResponseEntity<List<RestaurantDto>> getNearbyRestaurants(
            @PathVariable Long id,
            @RequestParam(value = "limit", defaultValue = "4") int limit) {

        RestaurantDto restaurant = restaurantService.findById(id);
        if (restaurant == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(restaurantService.getNearbyRestaurants(restaurant, limit));
    }

    // 리뷰 화면이 쓰고 있는 메뉴 조회 (기존 그대로 유지)
    @GetMapping("/{id:\\d+}/menu")
    public List<MenuItemDto> getMenu(@PathVariable Long id) {
        return menuItemRepository.findByRestaurantIdOrderByMenuIdAsc(id).stream().map(MenuItemDto::new).toList();
    }

    @PostMapping("/{id}/publish")
    public Map<String, Object> publish(@PathVariable Long id) {
        restaurantService.publish(id);
        return Map.of("result", "OK", "restaurantId", id, "isPublished", "Y");
    }

    @PostMapping("/{id}/unpublish")
    public Map<String, Object> unpublish(@PathVariable Long id) {
        restaurantService.unpublish(id);
        return Map.of("result", "OK", "restaurantId", id, "isPublished", "N");
    }

    // 목록 API 응답 형태 고정용
    public record RestaurantListResponse(
            List<RestaurantDto> content,
            int currentPage,
            int totalPages,
            long totalElements
    ) {}
}
