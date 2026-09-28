package com.bingomap.bingo_map.report;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** PUT /api/admin/reports/{id}/status 요청 바디 */
public class BinReportStatusUpdateDto {

    @NotBlank(message = "상태 값이 필요합니다.")
    @Pattern(regexp = "PENDING|APPROVED|REJECTED", message = "status는 PENDING/APPROVED/REJECTED 중 하나여야 합니다.")
    private String status;

    @Size(max = 300, message = "반려 사유는 300자 이내로 입력해주세요.")
    private String rejectReason;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }
}