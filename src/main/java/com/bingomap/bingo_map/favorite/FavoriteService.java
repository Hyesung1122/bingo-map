package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.TargetType;
import com.bingomap.bingo_map.map.WasteBinService;
import com.bingomap.bingo_map.restaurant.Restaurant;
import com.bingomap.bingo_map.restaurant.RestaurantRepository;
import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final WasteBinService wasteBinService;

    public FavoriteService(FavoriteRepository favoriteRepository,
                           UserRepository userRepository,
                           RestaurantRepository restaurantRepository,
                           WasteBinService wasteBinService) {
        this.favoriteRepository = favoriteRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.wasteBinService = wasteBinService;
    }

    public List<FavoriteResponseDto> findByUser(Long userId) {
        return favoriteRepository.findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public FavoriteResponseDto add(Long userId, FavoriteRequestDto request) {
        if (request == null || request.targetType() == null
                || request.targetId() == null || request.targetId().isBlank()) {
            throw new IllegalArgumentException("즐겨찾기 대상 정보가 없습니다.");
        }

        String targetId = request.targetId().trim();
        if (favoriteRepository.existsByUserUserIdAndTargetTypeAndTargetId(
                userId, request.targetType(), targetId)) {
            throw new IllegalStateException("이미 즐겨찾기에 저장된 항목입니다.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        String targetName = request.targetName();
        if (targetName == null || targetName.isBlank()) {
            targetName = resolveName(request.targetType(), targetId);
        }

        try {
            Favorite saved = favoriteRepository.save(
                    new Favorite(user, request.targetType(), targetId, targetName));
            return toResponse(saved);
        } catch (DataIntegrityViolationException e) {
            throw new IllegalStateException("이미 즐겨찾기에 저장된 항목입니다.");
        }
    }

    @Transactional
    public void delete(Long userId, Long favoriteId) {
        if (!favoriteRepository.existsById(favoriteId)) {
            throw new IllegalArgumentException("즐겨찾기를 찾을 수 없습니다.");
        }
        favoriteRepository.deleteByIdAndUserUserId(favoriteId, userId);
    }

    private FavoriteResponseDto toResponse(Favorite favorite) {
        TargetLocation location = resolveLocation(favorite.getTargetType(), favorite.getTargetId());
        String displayLocation = location.location();

        return new FavoriteResponseDto(
                favorite.getId(),
                favorite.getTargetType(),
                favorite.getTargetId(),
                favorite.getTargetName(),
                displayLocation,
                location.latitude(),
                location.longitude(),
                favorite.getCreatedAt()
        );
    }

    private String resolveName(TargetType type, String targetId) {
        if (type == TargetType.RESTAURANT) {
            try {
                return restaurantRepository.findById(Long.valueOf(targetId))
                        .map(Restaurant::getName)
                        .orElse("맛집");
            } catch (NumberFormatException ignored) {
                return "맛집";
            }
        }
        return "쓰레기통";
    }

    private TargetLocation resolveLocation(TargetType type, String targetId) {
        if (type == TargetType.RESTAURANT) {
            try {
                return restaurantRepository.findById(Long.valueOf(targetId))
                        .map(r -> new TargetLocation(r.getAddress(), r.getLatitude(), r.getLongitude()))
                        .orElse(new TargetLocation("주소 정보 없음", null, null));
            } catch (NumberFormatException ignored) {
                return new TargetLocation("주소 정보 없음", null, null);
            }
        }

        try {
            long binId = Long.parseLong(targetId);
            return wasteBinService.getWasteBins("osaka").stream()
                    .filter(bin -> bin.getId() != null && bin.getId() == binId)
                    .findFirst()
                    .map(bin -> new TargetLocation(bin.getAddress(), bin.getLat(), bin.getLon()))
                    .orElse(new TargetLocation("지도에서 위치를 확인하세요", null, null));
        } catch (NumberFormatException ignored) {
            return new TargetLocation("지도에서 위치를 확인하세요", null, null);
        }
    }

    private record TargetLocation(String location, Double latitude, Double longitude) {}
}
