// RestaurantService.java (기존 그대로, 변경 없음)
package com.bingomap.bingo_map.restaurant;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;

    public RestaurantService(RestaurantRepository restaurantRepository) {
        this.restaurantRepository = restaurantRepository;
    }

    private static final List<String> SHINSAIBASHI_KEYWORDS = List.of(
            "신사이바시", "Shinsaibashi", "미나미센바", "Minamisenba", "南船場",
            "신세카이", "Shinsekai", "에비스히가시", "Ebisuhigashi", "에비스니시", "Ebisunishi", "556"
    );
    private static final List<String> UMEDA_KEYWORDS = List.of(
            "우메다", "Umeda", "소네자키", "Sonezaki", "도야마초", "Doyamacho",
            "시바타", "Shibata", "가쿠다초", "Kakudacho", "530"
    );
    private static final List<String> DOTONBORI_KEYWORDS = List.of(
            "도톤보리", "Dotonbori", "난바", "Namba", "센니치마에", "Sennichimae",
            "사쿠라가와", "Sakuragawa", "542"
    );

    // [목록 API용] 지역별 페이징 조회
    public Page<RestaurantDto> findPagedByRegion(String region, Pageable pageable) {
        List<String> keywords = switch (region) {
            case "umeda" -> UMEDA_KEYWORDS;
            case "shinsaibashi" -> SHINSAIBASHI_KEYWORDS;
            default -> DOTONBORI_KEYWORDS;
        };

        List<Restaurant> filtered = restaurantRepository.findByIsPublished("Y").stream()
                .filter(r -> r.getAddress() != null && containsAny(r.getAddress(), keywords))
                .collect(Collectors.toList());

        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        List<RestaurantDto> pageContent = start >= filtered.size()
                ? List.of()
                : filtered.subList(start, end).stream().map(this::toDto).collect(Collectors.toList());

        return new PageImpl<>(pageContent, pageable, filtered.size());
    }

    public String resolveRegion(String address) {
        if (address == null) return "dotonbori";
        if (containsAny(address, SHINSAIBASHI_KEYWORDS)) return "shinsaibashi";
        if (containsAny(address, UMEDA_KEYWORDS)) return "umeda";
        return "dotonbori";
    }

    private boolean containsAny(String address, List<String> keywords) {
        for (String keyword : keywords) {
            if (address.contains(keyword)) return true;
        }
        return false;
    }

    // [상세 API용]
    public RestaurantDto findById(Long id) {
        if (id == null) id = 1L;
        Long targetId = id;
        Restaurant restaurant = restaurantRepository.findById(targetId)
                .orElseGet(() -> restaurantRepository.findAll().stream().findFirst().orElse(null));
        return restaurant == null ? null : toDto(restaurant);
    }

    // [주변 추천 API용]
    public List<RestaurantDto> getNearbyRestaurants(RestaurantDto current, int limit) {
        if (current == null || current.getLatitude() == null || current.getLongitude() == null) {
            return List.of();
        }
        return restaurantRepository.findByIsPublished("Y").stream()
                .filter(r -> !r.getId().equals(current.getRestaurantId()))
                .filter(r -> r.getLatitude() != null && r.getLongitude() != null)
                .sorted(Comparator.comparingDouble(r ->
                        calculateDistance(current.getLatitude(), current.getLongitude(),
                                r.getLatitude(), r.getLongitude())))
                .limit(limit)
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    @Transactional
    public void publish(Long id) {
        restaurantRepository.findById(id).ifPresent(r -> r.setIsPublished("Y"));
    }

    @Transactional
    public void unpublish(Long id) {
        restaurantRepository.findById(id).ifPresent(r -> r.setIsPublished("N"));
    }

    private RestaurantDto toDto(Restaurant r) {
        RestaurantDto dto = new RestaurantDto();
        dto.setRestaurantId(r.getId());
        dto.setName(r.getName());
        dto.setCategory(r.getCategory());
        dto.setTags(r.getTags());
        dto.setRating(r.getRating() != null ? r.getRating() : 0.0);
        dto.setReviewCount(r.getReviewCount() != null ? r.getReviewCount() : 0);
        dto.setDescription(r.getDescription());
        dto.setAddress(r.getAddress());
        dto.setLatitude(r.getLatitude());
        dto.setLongitude(r.getLongitude());
        dto.setOpeningHours(r.getOpeningHours());
        dto.setPhone(r.getPhone());
        dto.setPriceRange(r.getPriceRange());
        dto.setWebsiteUrl(r.getWebsiteUrl());
        dto.setSeatInfo(r.getSeatInfo());
        dto.setReservationInfo(r.getReservationInfo());
        dto.setPaymentMethods(r.getPaymentMethods());
        dto.setLanguages(r.getLanguages());
        dto.setMainImageUrl(r.getMainImageUrl());
        dto.setMenuName(r.getMenuName());
        dto.setMenuPrice(r.getMenuPrice());
        dto.setMenuDescription(r.getMenuDescription());
        dto.setMenuImageUrl(r.getMenuImageUrl());
        return dto;
    }
}