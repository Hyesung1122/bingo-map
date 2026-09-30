package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    public List<CommentResponseDto> getComments(Long postId) {
        return repository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    // [09/30 유해성] 작성자 id 를 컨트롤러에서 결정해서 받음 (로그인 사용자 우선)
    @Transactional
    public CommentResponseDto create(Long postId, Long userId, String content) {
        CommunityComment comment = new CommunityComment(postId, userId, content);
        return toDto(repository.save(comment));
    }

    @Transactional
    public void delete(Long commentId) {
        CommunityComment comment = repository.findById(commentId)
                .orElseThrow(() -> new EntityNotFoundException("댓글을 찾을 수 없습니다. id=" + commentId));
        repository.delete(comment);
    }

    private CommentResponseDto toDto(CommunityComment c) {
        CommentResponseDto dto = new CommentResponseDto(c);
        dto.setAuthorName(c.getUserId() == null ? "알 수 없음"
                : userRepository.findById(c.getUserId())
                        .map(CommunityPostService::displayName)
                        .orElse("회원" + c.getUserId()));
        return dto;
    }
}
