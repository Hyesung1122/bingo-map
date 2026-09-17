package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;

/**
 * 맛집 담당 팀원이 만든 RESTAURANT 테이블을 읽기 전용으로 매핑한 엔티티.
 * (주의) 맛집 담당자가 이미 자기 쪽에 같은 이름의 엔티티를 만들어뒀다면,
 * 코드 합칠 때 이 클래스는 지우고 그쪽 엔티티를 쓰면 됨 — 테이블 구조만 맞으면 리뷰 쪽 코드는 그대로 동작함.
 */
@Entity
@Table(name = "RESTAURANT")
public class Restaurant {

    @Id
    @Column(name = "RESTAURANT_ID")
    private Long restaurantId;

    @Column(name = "NAME")
    private String name;

    @Column(name = "CATEGORY")
    private String category;

    @Column(name = "RATING")
    private Double rating;

    @Column(name = "ADDRESS")
    private String address;

    @Column(name = "MAIN_IMAGE_URL")
    private String mainImageUrl;

    @Column(name = "LATITUDE")
    private java.math.BigDecimal latitude;

    @Column(name = "LONGITUDE")
    private java.math.BigDecimal longitude;

    @Column(name = "OPENING_HOURS")
    private String openingHours;

    @Column(name = "PHONE")
    private String phone;

    @Column(name = "PRICE_RANGE")
    private String priceRange;

    @Column(name = "WEBSITE_URL")
    private String websiteUrl;

    @Column(name = "DESCRIPTION")
    private String description;

    protected Restaurant() {
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
