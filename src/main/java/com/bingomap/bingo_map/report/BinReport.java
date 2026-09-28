package com.bingomap.bingo_map.report;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * bin_reports 테이블과 매핑되는 Entity (팀 공용 스키마 네이밍)
 * - 실제 DDL: DB/bin_reports.sql (ddl-auto: none 이라 직접 실행 필요)
 * - status: PENDING(보류=검수대기, 기본값) / APPROVED(승인) / REJECTED(반려)
 */
@Entity
@Table(name = "bin_reports")
@Getter
@Setter
@NoArgsConstructor
public class BinReport {

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_bin_report")
    @SequenceGenerator(name = "seq_bin_report", sequenceName = "bin_reports_seq", allocationSize = 1)
    @Column(name = "id")
    private Long reportId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;

    @Column(name = "name", length = 200)
    private String name;

    // general(일반) / recycle(재활용) / can(캔·병)
    @Column(name = "category", length = 20)
    private String category;

    @Column(name = "address", length = 300)
    private String address;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "status", length = 20, nullable = false)
    private String status = STATUS_PENDING;

    @Column(name = "reject_reason", length = 300)
    private String rejectReason;

    @Column(name = "reviewed_by")
    private Long reviewedBy;

    @Column(name = "reviewed_at")
    private LocalDateTime reviewedAt;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = STATUS_PENDING;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public BinReport(Long userId, Double latitude, Double longitude, String name,
                     String category, String address, String description) {
        this.userId = userId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.name = name;
        this.category = category;
        this.address = address;
        this.description = description;
        this.status = STATUS_PENDING;
    }

    /** 관리자가 검수 처리(승인/반려/보류로 되돌리기)한다. */
    public void review(String newStatus, String rejectReason, Long reviewerId) {
        this.status = newStatus;
        this.rejectReason = STATUS_REJECTED.equals(newStatus) ? rejectReason : null;
        this.reviewedBy = STATUS_PENDING.equals(newStatus) ? null : reviewerId;
        this.reviewedAt = STATUS_PENDING.equals(newStatus) ? null : LocalDateTime.now();
    }
}