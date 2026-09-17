package com.bingomap.bingo_map.dto;

import lombok.Getter;

@Getter
public class SettingsResponseDto {
    private final boolean signupEnabled;
    private final boolean maintenanceMode;
    private final String maintenanceMessage;

    public SettingsResponseDto(boolean signupEnabled, boolean maintenanceMode, String maintenanceMessage) {
        this.signupEnabled = signupEnabled;
        this.maintenanceMode = maintenanceMode;
        this.maintenanceMessage = maintenanceMessage;
    }
}