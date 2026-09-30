package com.bingomap.bingo_map.restaurant;

import com.bingomap.bingo_map.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "RESTAURANTS")
@Getter
@Setter
@NoArgsConstructor
public class Restaurant extends BaseEntity {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "restaurant_seq"
    )
    @SequenceGenerator(
            name = "restaurant_seq",
            sequenceName = "SEQ_RESTAURANT",
            allocationSize = 1
    )
    @Column(name = "RESTAURANT_ID")
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

    @Column(name = "OPENING_HOURS")
    private String openingHours;

    private String phone;

    @Column(name = "PRICE_RANGE")
    private String priceRange;

    @Column(name = "WEBSITE_URL")
    private String websiteUrl;

    @Column(name = "SEAT_INFO")
    private String seatInfo;

    @Column(name = "RESERVATION_INFO")
    private String reservationInfo;

    @Column(name = "PAYMENT_METHODS")
    private String paymentMethods;

    private String languages;

    @Column(name = "MAIN_IMAGE_URL")
    private String mainImageUrl;

    @Column(name = "MENU_NAME")
    private String menuName;

    @Column(name = "MENU_DESCRIPTION")
    private String menuDescription;

    @Column(name = "MENU_PRICE")
    private String menuPrice;

    @Column(name = "MENU_IMAGE_URL")
    private String menuImageUrl;

    @Column(name = "OSM_ID")
    private Long osmId;

    @Column(name = "IS_PUBLISHED")
    private String isPublished;
}