package com.bingomap.bingo_map.dto;

import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

/** PUT /api/admin/users/{id}/role 요청 바디 */
@Getter
@Setter
public class AdminRoleUpdateDto {

    @Pattern(regexp = "^(USER|ADMIN)$", message = "role은 USER 또는 ADMIN이어야 합니다.")
    private String role;
}