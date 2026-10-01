package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.notification.NotificationService;
import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CommunityCommentService {

    private final CommunityCommentRepository repository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public CommunityCommentService(CommunityCommentRepository repository,
                                   UserRepository userRepository,
                                   NotificationService notificationService) {
        this.repository = repository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    /** 요청 글이면 관리자 댓글을 먼저 보여줍니다. */
    public List<CommentResponseDto> getComments(Long postId, boolean adminFirst) {
        List<CommentResponseDto> list = repository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        if (adminFirst) {
            list.sort(Comparator.comparing((CommentResponseDto comment) -> !comment.isAuthorAdmin()));
        }
        return list;
    }

    /** 댓글 작성자 ID는 컨트롤러가 로그인 세션에서 결정합니다. */
    @Transactional
    public CommentResponseDto create(Long postId, Long userId, String content) {
        CommunityComment comment = new CommunityComment(postId, userId, content);
        CommunityComment saved = repository.save(comment);

        // 본인 글에 본인이 댓글을 단 경우에는 알림을 만들지 않습니다.
        notificationService.onCommentCreated(postId, userId);
        return toDto(saved);
    }

    @Transactional
    public void delete(Long commentId, Long loginUserId, boolean admin) {
        CommunityComment comment = repository.findById(commentId)
                .orElseThrow(() -> new EntityNotFoundException("댓글을 찾을 수 없습니다. id=" + commentId));
        // [09/30 유해성] 댓글 작성자 본인 또는 관리자만
        CommunityPostService.checkCanModify(comment.getUserId(), loginUserId, admin, "댓글");
        repository.delete(comment);
    }

    private CommentResponseDto toDto(CommunityComment c) {
        CommentResponseDto dto = new CommentResponseDto(c);
        User author = c.getUserId() == null ? null : userRepository.findById(c.getUserId()).orElse(null);
        dto.setAuthorName(author != null ? CommunityPostService.displayName(author)
                : c.getUserId() == null ? "알 수 없음" : "회원" + c.getUserId());
        // [10/01 유해성] 관리자 댓글 배지
        dto.setAuthorAdmin(author != null && "ADMIN".equals(author.getRole()));
        return dto;
    }
}
