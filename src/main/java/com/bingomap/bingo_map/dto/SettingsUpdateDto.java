package com.bingomap.bingo_map.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SettingsUpdateDto {
    private boolean signupEnabled;
    private boolean maintenanceMode;
    private String maintenanceMessage;
}