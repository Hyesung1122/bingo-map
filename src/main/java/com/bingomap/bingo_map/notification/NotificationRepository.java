package com.bingomap.bingo_map.notification;

import com.bingomap.bingo_map.entity.TargetType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    // ===== 내 알림 =====
    Page<Notification> findByUserIdOrderByCreatedAtDescIdDesc(Long userId, Pageable pageable);

    long countByUserIdAndIsRead(Long userId, String isRead);

    Optional<Notification> findByIdAndUserId(Long id, Long userId);

    @Modifying(clearAutomatically = true)
    @Query("update Notification n set n.isRead = 'Y' where n.userId = :userId and n.isRead = 'N'")
    int markAllRead(@Param("userId") Long userId);

    // ===== 알림 대상/문구를 만들 때 필요한 조회 (다른 Repository를 수정하지 않으려고 여기에 둠) =====
    @Query("select u.userId from User u")
    List<Long> findAllUserIds();

    @Query("select u.nickname from User u where u.userId = :userId")
    Optional<String> findNickname(@Param("userId") Long userId);

    @Query("select p.userId from CommunityPost p where p.postId = :postId")
    Optional<Long> findPostAuthorId(@Param("postId") Long postId);

    @Query("select p.title from CommunityPost p where p.postId = :postId")
    Optional<String> findPostTitle(@Param("postId") Long postId);

    @Query("select f.user.userId from Favorite f where f.targetType = :targetType and f.targetId = :targetId")
    List<Long> findFavoriteUserIds(@Param("targetType") TargetType targetType,
                                   @Param("targetId") String targetId);

    @Query("select r.name from Restaurant r where r.restaurantId = :restaurantId")
    Optional<String> findRestaurantName(@Param("restaurantId") Long restaurantId);
}