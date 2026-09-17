package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.RestaurantMenuItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RestaurantMenuItemRepository extends JpaRepository<RestaurantMenuItem, Long> {
    List<RestaurantMenuItem> findByRestaurantIdOrderByMenuIdAsc(Long restaurantId);
}
