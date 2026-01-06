package com.sasmitha.lms.dto;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class PreferenceRequest {
    private List<String> categories;
    private List<String> locations;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer maxDistanceKm;
    private Double maxBudget;
}
