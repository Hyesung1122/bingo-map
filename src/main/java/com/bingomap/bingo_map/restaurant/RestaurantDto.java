package com.bingomap.bingo_map.restaurant;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class RestaurantDto {

    private Long restaurantId;
    private String name;
    private String category;
    private String tags;
    private Double rating;
    private Integer reviewCount;
    private String description;
    private String address;
    private Double latitude;
    private Double longitude;
    private String openingHours;
    private String phone;
    private String priceRange;
    private String websiteUrl;
    private String seatInfo;
    private String reservationInfo;
    private String paymentMethods;
    private String languages;
    private String mainImageUrl;
    private String notice;
    private String menuName;
    private String menuDescription;
    private String menuPrice;
    private String menuImageUrl;
    private String region;

    public RestaurantDto(Restaurant restaurant) {
        this.restaurantId = restaurant.getId();
        this.name = restaurant.getName();
        this.category = restaurant.getCategory();
        this.tags = restaurant.getTags();
        this.rating = restaurant.getRating();
        this.reviewCount = restaurant.getReviewCount();
        this.description = restaurant.getDescription();
        this.address = restaurant.getAddress();
        this.latitude = restaurant.getLatitude();
        this.longitude = restaurant.getLongitude();
        this.openingHours = restaurant.getOpeningHours();
        this.phone = restaurant.getPhone();
        this.priceRange = restaurant.getPriceRange();
        this.websiteUrl = restaurant.getWebsiteUrl();
        this.seatInfo = restaurant.getSeatInfo();
        this.reservationInfo = restaurant.getReservationInfo();
        this.paymentMethods = restaurant.getPaymentMethods();
        this.languages = restaurant.getLanguages();
        this.mainImageUrl = restaurant.getMainImageUrl();
        this.menuName = restaurant.getMenuName();
        this.menuDescription = restaurant.getMenuDescription();
        this.menuPrice = restaurant.getMenuPrice();
        this.menuImageUrl = restaurant.getMenuImageUrl();
    }
}