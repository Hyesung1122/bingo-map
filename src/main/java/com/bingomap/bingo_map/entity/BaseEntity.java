package com.bingomap.bingo_map.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * [공통 BaseEntity]
 * - 작업 사양서(4-2장 공통 규칙 1번) 기준: "모든 Entity는 BaseEntity를 extends 할 것"
 * - 이걸 상속하면 createdAt/updatedAt이 자동으로 채워짐 (직접 SQL에서 값을 안 넣어도 됨)
 *
 * ★ 주의 (팀원들에게 공유 필요) ★
 * 사양서 5장 "0단계"에 따르면 BaseEntity/TargetType/USERS/@EnableJpaAuditing은
 * 원래 팀장(곽동곤)님이 먼저 만들어 main에 올리기로 되어 있는 "공통 뼈대"입니다.
 * 그런데 0단계가 아직 merge되지 않아서, 맛집 기능을 더 진행하기 위해 임시로 만들어뒀어요.
 * 팀장님의 공식 BaseEntity가 main에 올라오면, 이 파일은 지우고 그쪽 걸로 갈아타야
 * 나중에 클래스가 두 개라 충돌 나는 일이 없습니다.
 */
@Getter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {

    @CreatedDate
    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;
}
