package com.bingomap.bingo_map.report;

import java.time.format.DateTimeFormatter;

/**
 * 제보 응답 DTO.
 * 본인 제보 목록(/api/reports/mine)과 관리자 목록(/api/admin/reports)에서 공용으로 사용.
 * reporterName/reporterNickname은 관리자 목록에서만 채워지고, 본인 목록에서는 null.
 */
public class BinReportResponseDto {

    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");

    private Long reportId;
    private Double latitude;
    private Double longitude;
    private String name;
    private String category;
    private String address;
    private String description;
    private String status;
    private String rejectReason;
    private String createdAt;
    private String reporterName;
    private String reporterNickname;

    public BinReportResponseDto(BinReport r) {
        this.reportId = r.getReportId();
        this.latitude = r.getLatitude();
        this.longitude = r.getLongitude();
        this.name = r.getName();
        this.category = r.getCategory();
        this.address = r.getAddress();
        this.description = r.getDescription();
        this.status = r.getStatus();
        this.rejectReason = r.getRejectReason();
        this.createdAt = r.getCreatedAt() != null ? r.getCreatedAt().format(FORMAT) : "-";
    }

    public void setReporter(String name, String nickname) {
        this.reporterName = name;
        this.reporterNickname = nickname;
    }

    public Long getReportId() { return reportId; }
    public Double getLatitude() { return latitude; }
    public Double getLongitude() { return longitude; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public String getAddress() { return address; }
    public String getDescription() { return description; }
    public String getStatus() { return status; }
    public String getRejectReason() { return rejectReason; }
    public String getCreatedAt() { return createdAt; }
    public String getReporterName() { return reporterName; }
    public String getReporterNickname() { return reporterNickname; }
}