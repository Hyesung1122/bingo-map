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
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final WasteBinService wasteBinService;

    public FavoriteService(
            FavoriteRepository favoriteRepository,
            UserRepository userRepository,
            RestaurantRepository restaurantRepository,
            WasteBinService wasteBinService
    ) {
        this.favoriteRepository = favoriteRepository;
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.wasteBinService = wasteBinService;
    }

    public List<FavoriteResponseDto> findByUser(Long userId) {
        List<Favorite> favorites = favoriteRepository
                .findByUserUserIdOrderByCreatedAtDesc(userId);

        Set<Long> restaurantIds = favorites.stream()
                .filter(favorite -> favorite.getTargetType() == TargetType.RESTAURANT)
                .map(favorite -> parseId(favorite.getTargetId()))
                .filter(id -> id != null)
                .collect(Collectors.toSet());

        Map<Long, Restaurant> restaurants = restaurantRepository.findAllById(restaurantIds)
                .stream()
                .collect(Collectors.toMap(Restaurant::getRestaurantId, Function.identity()));

        Map<Long, com.bingomap.bingo_map.map.WasteBinDto> wasteBins = favorites.stream()
                .filter(favorite -> favorite.getTargetType() == TargetType.WASTE_BIN)
                .map(favorite -> parseId(favorite.getTargetId()))
                .filter(id -> id != null)
                .findAny()
                .map(ignored -> wasteBinService.getWasteBins("osaka").stream()
                        .filter(bin -> bin.getOsmId() != null)
                        .collect(Collectors.toMap(
                                com.bingomap.bingo_map.map.WasteBinDto::getOsmId,
                                Function.identity(),
                                (first, duplicate) -> first
                        )))
                .orElseGet(Map::of);

        return favorites.stream()
                .map(favorite -> toResponse(favorite, restaurants, wasteBins))
                .toList();
    }

    public List<FavoriteStatusDto> findStatusesByUserAndType(
            Long userId,
            TargetType targetType
    ) {
        return favoriteRepository
                .findByUserUserIdAndTargetTypeOrderByCreatedAtDesc(userId, targetType)
                .stream()
                .map(favorite -> new FavoriteStatusDto(
                        favorite.getTargetId(),
                        favorite.getId()
                ))
                .toList();
    }

    @Transactional
    public FavoriteResponseDto add(
            Long userId,
            FavoriteRequestDto request
    ) {

        if (request == null
                || request.targetType() == null
                || request.targetId() == null
                || request.targetId().isBlank()) {

            throw new IllegalArgumentException(
                    "즐겨찾기 대상 정보가 없습니다."
            );
        }

        String targetId =
                request.targetId().trim();

        if (favoriteRepository
                .existsByUserUserIdAndTargetTypeAndTargetId(
                        userId,
                        request.targetType(),
                        targetId
                )) {

            throw new IllegalStateException(
                    "이미 즐겨찾기에 저장된 항목입니다."
            );
        }

        User user =
                userRepository.findById(userId)
                        .orElseThrow(
                                () -> new IllegalArgumentException(
                                        "사용자를 찾을 수 없습니다."
                                )
                        );

        String targetName =
                request.targetName();

        if (request.targetType() == TargetType.RESTAURANT) {
            try {
                Restaurant restaurant = restaurantRepository
                        .findById(Long.valueOf(targetId))
                        .filter(found -> "Y".equals(found.getIsPublished()))
                        .orElseThrow(() -> new IllegalArgumentException(
                                "공개된 맛집을 찾을 수 없습니다."
                        ));
                targetName = restaurant.getName();
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("올바르지 않은 맛집 번호입니다.");
            }
        }

        if (targetName == null
                || targetName.isBlank()) {

            targetName =
                    resolveName(
                            request.targetType(),
                            targetId
                    );
        }

        try {

            Favorite saved =
                    favoriteRepository.save(
                            new Favorite(
                                    user,
                                    request.targetType(),
                                    targetId,
                                    targetName
                            )
                    );

            return toResponse(saved);

        } catch (DataIntegrityViolationException e) {

            throw new IllegalStateException(
                    "이미 즐겨찾기에 저장된 항목입니다."
            );
        }
    }

    @Transactional
    public void delete(
            Long userId,
            Long favoriteId
    ) {

        if (favoriteRepository.deleteByIdAndUserUserId(favoriteId, userId) == 0) {
            throw new IllegalArgumentException(
                    "즐겨찾기를 찾을 수 없습니다."
            );
        }
    }

    private FavoriteResponseDto toResponse(
            Favorite favorite,
            Map<Long, Restaurant> restaurants,
            Map<Long, com.bingomap.bingo_map.map.WasteBinDto> wasteBins
    ) {
        Long targetNumericId = parseId(favorite.getTargetId());
        TargetLocation location = switch (favorite.getTargetType()) {
            case RESTAURANT -> {
                Restaurant restaurant = targetNumericId == null ? null : restaurants.get(targetNumericId);
                yield restaurant == null
                        ? new TargetLocation("주소 정보 없음", null, null)
                        : new TargetLocation(restaurant.getAddress(), restaurant.getLatitude(), restaurant.getLongitude());
            }
            case WASTE_BIN -> {
                com.bingomap.bingo_map.map.WasteBinDto bin = targetNumericId == null ? null : wasteBins.get(targetNumericId);
                yield bin == null
                        ? new TargetLocation("지도에서 위치를 확인하세요", null, null)
                        : new TargetLocation(bin.getAddress(), bin.getLat(), bin.getLon());
            }
        };

        return new FavoriteResponseDto(
                favorite.getId(),
                favorite.getTargetType(),
                favorite.getTargetId(),
                favorite.getTargetName(),
                location.location(),
                location.latitude(),
                location.longitude(),
                favorite.getCreatedAt()
        );
    }

    private FavoriteResponseDto toResponse(Favorite favorite) {
        TargetLocation location = resolveLocation(favorite.getTargetType(), favorite.getTargetId());
        return new FavoriteResponseDto(
                favorite.getId(),
                favorite.getTargetType(),
                favorite.getTargetId(),
                favorite.getTargetName(),
                location.location(),
                location.latitude(),
                location.longitude(),
                favorite.getCreatedAt()
        );
    }

    private Long parseId(String value) {
        try {
            return value == null ? null : Long.valueOf(value);
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private String resolveName(
            TargetType type,
            String targetId
    ) {

        if (type == TargetType.RESTAURANT) {

            try {

                return restaurantRepository
                        .findById(Long.valueOf(targetId))
                        .map(Restaurant::getName)
                        .orElse("맛집");

            } catch (NumberFormatException ignored) {

                return "맛집";
            }
        }

        if (type == TargetType.WASTE_BIN) {

            try {

                long osmId =
                        Long.parseLong(targetId);

                return wasteBinService
                        .getWasteBins("osaka")
                        .stream()
                        .filter(bin ->
                                bin.getOsmId() != null
                                        && bin.getOsmId() == osmId
                        )
                        .map(bin -> bin.getName())
                        .findFirst()
                        .orElse("쓰레기통");

            } catch (NumberFormatException ignored) {

                return "쓰레기통";
            }
        }

        return "대상";
    }

    private TargetLocation resolveLocation(
            TargetType type,
            String targetId
    ) {

        if (type == TargetType.RESTAURANT) {

            try {

                return restaurantRepository
                        .findById(Long.valueOf(targetId))
                        .map(r ->
                                new TargetLocation(
                                        r.getAddress(),
                                        r.getLatitude(),
                                        r.getLongitude()
                                )
                        )
                        .orElse(
                                new TargetLocation(
                                        "주소 정보 없음",
                                        null,
                                        null
                                )
                        );

            } catch (NumberFormatException ignored) {

                return new TargetLocation(
                        "주소 정보 없음",
                        null,
                        null
                );
            }
        }

        if (type == TargetType.WASTE_BIN) {

            try {

                long osmId =
                        Long.parseLong(targetId);

                return wasteBinService
                        .getWasteBins("osaka")
                        .stream()
                        .filter(bin ->
                                bin.getOsmId() != null
                                        && bin.getOsmId() == osmId
                        )
                        .findFirst()
                        .map(bin ->
                                new TargetLocation(
                                        bin.getAddress(),
                                        bin.getLat(),
                                        bin.getLon()
                                )
                        )
                        .orElse(
                                new TargetLocation(
                                        "지도에서 위치를 확인하세요",
                                        null,
                                        null
                                )
                        );

            } catch (NumberFormatException ignored) {

                return new TargetLocation(
                        "지도에서 위치를 확인하세요",
                        null,
                        null
                );
            }
        }

        return new TargetLocation(
                "위치 정보 없음",
                null,
                null
        );
    }

    private record TargetLocation(
            String location,
            Double latitude,
            Double longitude
    ) {
    }
}
