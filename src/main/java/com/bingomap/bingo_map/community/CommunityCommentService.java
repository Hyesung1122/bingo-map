package com.bingomap.bingo_map.community;

<<<<<<< HEAD
import com.bingomap.bingo_map.notification.NotificationService;
=======
import com.bingomap.bingo_map.user.User;
>>>>>>> da3a865cb0c3fa0b69a321c1a7447bd1023c5bb2
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
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

    @Autowired
    private NotificationService notificationService;

    public CommunityCommentService(CommunityCommentRepository repository,
                                   UserRepository userRepository) {
        this.repository = repository;
        this.userRepository = userRepository;
    }

    /**
     * [10/01 유해성] adminFirst = true(요청 글)이면 관리자 답변을 맨 위로
     */
    public List<CommentResponseDto> getComments(Long postId, boolean adminFirst) {
        List<CommentResponseDto> list = repository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        if (adminFirst) {
            list.sort(Comparator.comparing((CommentResponseDto c) -> !c.isAuthorAdmin()));
        }
        return list;
    }

    // [09/30 유해성] 작성자 id 를 컨트롤러에서 결정해서 받음 (로그인 사용자 우선)
    @Transactional
    public CommentResponseDto create(Long postId, Long userId, String content) {
        CommunityComment comment = new CommunityComment(postId, userId, content);
        CommunityComment saved = repository.save(comment);

        // 내 글에 다른 사람이 댓글을 달면 글쓴이에게 알림 (본인 글에 본인 댓글이면 알림 없음)
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
<<<<<<< HEAD
        dto.setAuthorName(c.getUserId() == null ? "알 수 없음"
                : userRepository.findById(c.getUserId())
                .map(CommunityPostService::displayName)
                .orElse("회원" + c.getUserId()));
=======
        User author = c.getUserId() == null ? null : userRepository.findById(c.getUserId()).orElse(null);
        dto.setAuthorName(author != null ? CommunityPostService.displayName(author)
                : c.getUserId() == null ? "알 수 없음" : "회원" + c.getUserId());
        // [10/01 유해성] 관리자 댓글 배지
        dto.setAuthorAdmin(author != null && "ADMIN".equals(author.getRole()));
>>>>>>> da3a865cb0c3fa0b69a321c1a7447bd1023c5bb2
        return dto;
    }
}