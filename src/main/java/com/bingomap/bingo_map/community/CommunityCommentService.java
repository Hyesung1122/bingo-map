package com.bingomap.bingo_map.community;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CommunityCommentService {

    private final CommunityCommentRepository repository;

    public CommunityCommentService(CommunityCommentRepository repository) {
        this.repository = repository;
    }

    public List<CommentResponseDto> getComments(Long postId) {
        return repository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(CommentResponseDto::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public CommentResponseDto create(Long postId, CommentRequestDto request) {
        CommunityComment comment = new CommunityComment(postId, request.getUserId(), request.getContent());
        return new CommentResponseDto(repository.save(comment));
    }

    @Transactional
    public void delete(Long commentId) {
        CommunityComment comment = repository.findById(commentId)
                .orElseThrow(() -> new EntityNotFoundException("댓글을 찾을 수 없습니다. id=" + commentId));
        repository.delete(comment);
    }
}
