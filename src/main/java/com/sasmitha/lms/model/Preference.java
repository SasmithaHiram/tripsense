package com.sasmitha.lms.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "preferences")
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Preference {
    @Id
    private Long id;
    private List<String> categories;
    private List<String> locations;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer maxDistanceKm;
    private Double maxBudget;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;

    @PrePersist
    private void prePersist() {
        createAt = LocalDateTime.now();
        updateAt = LocalDateTime.now();
    }

    @PreUpdate
    private void preUpdate() {
        updateAt = LocalDateTime.now();
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}
