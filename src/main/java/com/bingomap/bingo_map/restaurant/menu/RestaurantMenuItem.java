package com.bingomap.bingo_map.restaurant.menu;

import jakarta.persistence.*;

@Entity
@Table(name = "restaurant_menu")
public class RestaurantMenuItem {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "menu_seq")
    @SequenceGenerator(
            name = "menu_seq",
            sequenceName = "SEQ_RESTAURANT_MENU",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long menuId;

    @Column(name = "restaurant_id", nullable = false)
    private Long restaurantId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "price", length = 50)
    private String price;

    @Column(name = "is_signature")
    private Integer isSignature;

    protected RestaurantMenuItem() {
    }

    public Long getMenuId() {
        return menuId;
    }

    public Long getRestaurantId() {
        return restaurantId;
    }

    public String getName() {
        return name;
    }

    public String getPrice() {
        return price;
    }

    public boolean isSignature() {
        return isSignature != null && isSignature == 1;
    }
}