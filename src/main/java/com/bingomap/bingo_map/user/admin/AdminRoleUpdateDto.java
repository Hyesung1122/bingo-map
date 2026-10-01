package com.bingomap.bingo_map.user.admin;

import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

/** PUT /api/admin/users/{id}/role 요청 바디 */
@Getter
@Setter
public class AdminRoleUpdateDto {

    @Pattern(regexp = "^(USER|MANAGER|ADMIN)$", message = "role은 USER, MANAGER 또는 ADMIN이어야 합니다.")
    private String role;
}
