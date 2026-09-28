package com.bingomap.bingo_map.report;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** POST /api/reports 요청 바디 */
public class BinReportRequestDto {

    @NotNull(message = "위도를 입력해주세요.")
    @DecimalMin(value = "-90", message = "위도 값이 올바르지 않습니다.")
    @DecimalMax(value = "90", message = "위도 값이 올바르지 않습니다.")
    private Double latitude;

    @NotNull(message = "경도를 입력해주세요.")
    @DecimalMin(value = "-180", message = "경도 값이 올바르지 않습니다.")
    @DecimalMax(value = "180", message = "경도 값이 올바르지 않습니다.")
    private Double longitude;

    @Size(max = 200, message = "장소명은 200자 이내로 입력해주세요.")
    private String name;

    private String category; // general / recycle / can, 미입력 시 general

    @Size(max = 300, message = "주소는 300자 이내로 입력해주세요.")
    private String address;

    @Size(max = 500, message = "설명은 500자 이내로 입력해주세요.")
    private String description;

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}