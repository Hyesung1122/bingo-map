package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.user.LoginController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteApiController {

    private final FavoriteService favoriteService;

    public FavoriteApiController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public ResponseEntity<?> getFavorites(HttpServletRequest request) {
        Long userId = getLoginUserId(request);
        if (userId == null) return unauthorized();
        return ResponseEntity.ok(favoriteService.findByUser(userId));
    }

    @PostMapping
    public ResponseEntity<?> addFavorite(@RequestBody FavoriteRequestDto requestDto,
                                         HttpServletRequest request) {
        Long userId = getLoginUserId(request);
        if (userId == null) return unauthorized();

        try {
            return ResponseEntity.ok(favoriteService.add(userId, requestDto));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(Map.of("message", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteFavorite(@PathVariable Long id,
                                            HttpServletRequest request) {
        Long userId = getLoginUserId(request);
        if (userId == null) return unauthorized();

        try {
            favoriteService.delete(userId, id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private Long getLoginUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object value = session.getAttribute(LoginController.SESSION_USER_ID);
        return value instanceof Long ? (Long) value : null;
    }

    private ResponseEntity<Map<String, String>> unauthorized() {
        return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
    }
}
