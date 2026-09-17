package com.bingomap.bingo_map.dto;

import com.bingomap.bingo_map.entity.Restaurant;

public class RestaurantDto {
    private Long restaurantId;
    private String name;
    private String category;
    private Double rating;
    private String address;
    private String mainImageUrl;
    private java.math.BigDecimal latitude;
    private java.math.BigDecimal longitude;
    private String openingHours;
    private String phone;
    private String priceRange;
    private String websiteUrl;
    private String description;

    public RestaurantDto(Restaurant r) {
        this.restaurantId = r.getRestaurantId();
        this.name = r.getName();
        this.category = r.getCategory();
        this.rating = r.getRating();
        this.address = r.getAddress();
        this.mainImageUrl = r.getMainImageUrl();
        this.latitude = r.getLatitude();
        this.longitude = r.getLongitude();
        this.openingHours = r.getOpeningHours();
        this.phone = r.getPhone();
        this.priceRange = r.getPriceRange();
        this.websiteUrl = r.getWebsiteUrl();
        this.description = r.getDescription();
    }

    public Long getRestaurantId() { return restaurantId; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public Double getRating() { return rating; }
    public String getAddress() { return address; }
    public String getMainImageUrl() { return mainImageUrl; }
    public java.math.BigDecimal getLatitude() { return latitude; }
    public java.math.BigDecimal getLongitude() { return longitude; }
    public String getOpeningHours() { return openingHours; }
    public String getPhone() { return phone; }
    public String getPriceRange() { return priceRange; }
    public String getWebsiteUrl() { return websiteUrl; }
    public String getDescription() { return description; }
}
