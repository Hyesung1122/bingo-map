package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;

/**
 * 맛집 메뉴 항목. RESTAURANT 테이블과는 별도 테이블로 분리해서
 * 맛집 담당자 테이블 구조를 건드리지 않고 리뷰 쪽에서 추가함.
 */
@Entity
@Table(name = "TB_RESTAURANT_MENU")
public class RestaurantMenuItem {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "menu_seq")
    @SequenceGenerator(name = "menu_seq", sequenceName = "SEQ_RESTAURANT_MENU", allocationSize = 1)
    @Column(name = "MENU_ID")
    private Long menuId;

    @Column(name = "RESTAURANT_ID", nullable = false)
    private Long restaurantId;

    @Column(name = "NAME", nullable = false, length = 100)
    private String name;

    @Column(name = "PRICE", length = 50)
    private String price;

    @Column(name = "IS_SIGNATURE")
    private Integer isSignature;

    protected RestaurantMenuItem() {
    }

    public Long getMenuId() { return menuId; }
    public Long getRestaurantId() { return restaurantId; }
    public String getName() { return name; }
    public String getPrice() { return price; }
    public boolean isSignature() { return isSignature != null && isSignature == 1; }
}
