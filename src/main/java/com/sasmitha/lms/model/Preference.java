package com.sasmitha.lms.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "preferences")
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Preference {
    @Id
    private Long id;

    private String category;

    private String value;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}
