package com.bingomap.bingo_map.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * system_settings 테이블과 매핑되는 Entity.
 * 앱 전체에 딱 하나만 존재하는 설정 행(id = 1)을 다룬다.
 * - 실제 DDL: BinGoMap_ORACLE_query_태건.txt (테이블명 system_settings)
 */
@Entity
@Table(name = "system_settings")
@Getter
@Setter
@NoArgsConstructor
public class SystemSetting {

    @Id
    @Column(name = "id")
    private Long settingId;

    @Column(name = "signup_enabled", length = 1)
    private String signupEnabled; // 'Y' / 'N'

    @Column(name = "maintenance_mode", length = 1)
    private String maintenanceMode; // 'Y' / 'N'

    @Column(name = "maintenance_message", length = 500)
    private String maintenanceMessage;

    public boolean isSignupEnabled() {
        return "Y".equals(signupEnabled);
    }

    public boolean isMaintenanceMode() {
        return "Y".equals(maintenanceMode);
    }
}