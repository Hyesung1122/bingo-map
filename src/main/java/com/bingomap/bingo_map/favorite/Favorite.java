package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.BaseEntity;
import com.bingomap.bingo_map.entity.TargetType;
import com.bingomap.bingo_map.user.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "FAVORITES", uniqueConstraints = @UniqueConstraint(
        name = "UQ_FAVORITES_TARGET",
        columnNames = {"USER_ID", "TARGET_TYPE", "TARGET_ID"}
))
@Getter
@Setter
@NoArgsConstructor
public class Favorite extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "favorites_seq_gen")
    @SequenceGenerator(name = "favorites_seq_gen", sequenceName = "FAVORITES_SEQ", allocationSize = 1)
    @Column(name = "ID")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "USER_ID", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "TARGET_TYPE", nullable = false, length = 20)
    private TargetType targetType;

    @Column(name = "TARGET_ID", nullable = false, length = 100)
    private String targetId;

    @Column(name = "TARGET_NAME", length = 200)
    private String targetName;

    public Favorite(User user, TargetType targetType, String targetId, String targetName) {
        this.user = user;
        this.targetType = targetType;
        this.targetId = targetId;
        this.targetName = targetName;
    }
}
