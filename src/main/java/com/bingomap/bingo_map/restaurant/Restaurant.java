package com.bingomap.bingo_map.restaurant;

import com.bingomap.bingo_map.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
//0928 kdk 리팩토링
@Table(name = "restaurants")
@Getter
@Setter
@NoArgsConstructor
public class Restaurant extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "SEQ_RESTAURANT_GEN")
    @SequenceGenerator(name = "SEQ_RESTAURANT_GEN", sequenceName = "restaurants_seq", allocationSize = 1)  // SEQ_RESTAURANT → restaurants_seq
    @Column(name = "id")

    private Long id;
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

    // 공개 여부: "Y"면 지도·목록에 노출, "N"이면 DB에는 있지만 화면에는 안 나오는 비공개 후보 상태
    // (DB 컬럼에 DEFAULT 'N'이 걸려 있어서, 이 필드를 안 채워도 새로 저장되는 식당은 자동으로 N이 됨)
    @Column(name = "IS_PUBLISHED")
    private String isPublished;
}