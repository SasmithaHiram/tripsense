package com.sasmitha.lms.dto;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class PreferenceResponse {
    private Long id;
    private List<String> categories;
    private List<String> locations;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer maxDistanceKm;
    private Double maxBudget;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
}

