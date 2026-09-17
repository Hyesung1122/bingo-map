package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.SystemSetting;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, Long> {
}