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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ElementCollection
    @CollectionTable(
            name = "preference_categories",
            joinColumns = @JoinColumn(name = "preference_id")
    )
    @Column(name = "category")
    private List<String> categories;

    @ElementCollection
    @CollectionTable(
            name = "preference_locations",
            joinColumns = @JoinColumn(name = "preference_id")
    )
    @Column(name = "location")
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
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
