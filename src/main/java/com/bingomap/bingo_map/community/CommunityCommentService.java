package com.bingomap.bingo_map.community;

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
        return toDto(repository.save(comment));
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
