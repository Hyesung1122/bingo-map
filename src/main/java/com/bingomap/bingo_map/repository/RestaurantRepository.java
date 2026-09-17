package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
}
