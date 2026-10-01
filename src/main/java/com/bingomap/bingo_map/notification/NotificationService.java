package com.bingomap.bingo_map.notification;

import com.bingomap.bingo_map.entity.TargetType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.Collection;
import java.util.List;
import java.util.Objects;

/**
 * 알림 만들기 + 내 알림 관리.
 * on~ 메서드는 다른 기능(공지/댓글/리뷰/제보)에서 한 줄로 호출한다.
 * 모든 on~ 메서드는 별도 트랜잭션에서 실행하고 예외를 밖으로 던지지 않는다.
 * -> 알림 테이블이 없거나 오류가 나도 공지/댓글/리뷰/제보 자체는 정상 처리된다. (콘솔에 경고만 남음)
 */
@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final NotificationRepository repository;
    private final TransactionTemplate isolatedTx;

    public NotificationService(NotificationRepository repository, PlatformTransactionManager txManager) {
        this.repository = repository;
        this.isolatedTx = new TransactionTemplate(txManager);
        this.isolatedTx.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
    }

    // ================= 다른 기능에서 호출하는 부분 =================

    /** 새 공지: 작성한 관리자(authorId)를 뺀 전체 회원에게 */
    public void onNoticeCreated(Long authorId, String title) {
        run("공지", () -> {
            List<Long> targets = repository.findAllUserIds().stream()
                    .filter(id -> !Objects.equals(id, authorId))
                    .toList();
            save(targets, Notification.TYPE_NOTICE, "새 공지사항: " + shorten(title, 80), "/notices");
        });
    }

    /** 댓글: 내 글에 다른 사람이 댓글을 달면 글쓴이에게 */
    public void onCommentCreated(Long postId, Long commenterId) {
        run("댓글", () -> {
            Long authorId = repository.findPostAuthorId(postId).orElse(null);
            if (authorId == null || authorId.equals(commenterId)) return;

            String who = repository.findNickname(commenterId)
                    .filter(nick -> !nick.isBlank()).orElse("누군가");
            String title = repository.findPostTitle(postId).orElse("내");
            save(List.of(authorId), Notification.TYPE_COMMENT,
                    who + "님이 '" + shorten(title, 30) + "' 글에 댓글을 남겼어요.",
                    "/community/" + postId);
        });
    }

    /** 리뷰: 그 대상(맛집/쓰레기통)을 즐겨찾기한 회원에게 (작성자 본인 제외) */
    public void onReviewCreated(String targetType, String targetId, Long writerId, Long reviewId) {
        run("리뷰", () -> {
            TargetType type = TargetType.valueOf(String.valueOf(targetType).trim().toUpperCase());
            List<Long> targets = repository.findFavoriteUserIds(type, targetId).stream()
                    .filter(id -> !Objects.equals(id, writerId))
                    .toList();
            if (targets.isEmpty()) return;

            String name = "쓰레기통";
            if (type == TargetType.RESTAURANT) {
                name = repository.findRestaurantName(Long.valueOf(targetId.trim()))
                        .filter(n -> !n.isBlank()).orElse("맛집");
            }
            save(targets, Notification.TYPE_REVIEW,
                    "즐겨찾기한 '" + shorten(name, 30) + "'에 새 리뷰가 등록되었어요.",
                    "/reviews/" + reviewId);
        });
    }

    /** 제보 접수 직후 (보류 상태로 검수 대기) */
    public void onReportSubmitted(Long reporterId, String reportName) {
        run("제보 접수", () -> save(List.of(reporterId), Notification.TYPE_REPORT,
                label(reportName) + " 제보가 접수되었어요. 보류 상태로 검수를 기다리고 있어요.",
                "/mypage?tab=reports"));
    }

    /** 관리자가 상태를 바꿨을 때: 승인 / 반려(사유 포함) / 보류. 상태가 그대로면 알림 없음 */
    public void onReportReviewed(Long reporterId, String reportName, String previousStatus,
                                 String newStatus, String rejectReason) {
        if (Objects.equals(previousStatus, newStatus)) return;
        run("제보 처리", () -> {
            String message;
            if ("APPROVED".equals(newStatus)) {
                message = label(reportName) + " 제보가 승인되었어요.";
            } else if ("REJECTED".equals(newStatus)) {
                message = label(reportName) + " 제보가 반려되었어요. 사유: " + shorten(rejectReason, 150);
            } else {
                message = label(reportName) + " 제보가 보류 상태로 변경되었어요.";
            }
            save(List.of(reporterId), Notification.TYPE_REPORT, message, "/mypage?tab=reports");
        });
    }

    // ================= 내 알림 관리 (NotificationController가 사용) =================

    @Transactional
    public boolean markRead(Long userId, Long id) {
        return repository.findByIdAndUserId(id, userId).map(n -> {
            n.markRead();
            return true;
        }).orElse(false);
    }

    @Transactional
    public void markAllRead(Long userId) {
        repository.markAllRead(userId);
    }

    @Transactional
    public boolean delete(Long userId, Long id) {
        return repository.findByIdAndUserId(id, userId).map(n -> {
            repository.delete(n);
            return true;
        }).orElse(false);
    }

    // ================= 내부 도구 =================

    private void run(String name, Runnable job) {
        try {
            isolatedTx.executeWithoutResult(status -> job.run());
        } catch (Exception e) {
            log.warn("알림 생성 실패 ({}): {}", name, e.getMessage());
        }
    }

    private void save(Collection<Long> userIds, String type, String message, String linkUrl) {
        List<Long> targets = userIds.stream().filter(Objects::nonNull).distinct().toList();
        if (targets.isEmpty()) return;
        String text = shorten(message, 300);
        String link = shorten(linkUrl, 300);
        repository.saveAll(targets.stream().map(id -> new Notification(id, type, text, link)).toList());
    }

    private String label(String reportName) {
        return (reportName == null || reportName.isBlank()) ? "쓰레기통" : "'" + shorten(reportName, 30) + "'";
    }

    private static String shorten(String text, int max) {
        if (text == null) return "";
        String t = text.strip();
        return t.length() <= max ? t : t.substring(0, max - 1) + "…";
    }
}