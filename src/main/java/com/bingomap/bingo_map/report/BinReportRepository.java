package com.bingomap.bingo_map.report;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BinReportRepository extends JpaRepository<BinReport, Long> {

    List<BinReport> findByUserIdOrderByCreatedAtDesc(Long userId);

    // 관리자 목록: 최신순 (보류/승인/반려 우선순위 정렬은 서비스 계층에서 처리)
    List<BinReport> findAllByOrderByCreatedAtDesc();

    long countByStatus(String status);

    // 마이페이지 통계: 내가 제출한 제보 수
    long countByUserId(Long userId);

    // 지도 표시용: 특정 상태(승인 등)의 제보를 최신순으로
    List<BinReport> findByStatusOrderByCreatedAtDesc(String status);
}