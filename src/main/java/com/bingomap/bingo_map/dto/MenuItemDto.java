package com.bingomap.bingo_map.dto;

import com.bingomap.bingo_map.entity.RestaurantMenuItem;

public class MenuItemDto {
    private String name;
    private String price;
    private boolean signature;

    public MenuItemDto(RestaurantMenuItem item) {
        this.name = item.getName();
        this.price = item.getPrice();
        this.signature = item.isSignature();
    }

    public String getName() { return name; }
    public String getPrice() { return price; }
    public boolean isSignature() { return signature; }
}
