package com.sasmitha.lms.service;

import com.sasmitha.lms.model.Preference;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AIServiceImpl {
    private final RestTemplate restTemplate;
    public static final String AI_URL = "http://localhost:3000/api/recomendations";

    public Map<String, Object> getRecommendations(List<Preference> preferences) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("categories", preferences.get(0).getCategories());
        payload.put("locations",  preferences.get(0).getLocations());
        payload.put("startDate", preferences.get(0).getStartDate());
        payload.put("endDate", preferences.get(0).getEndDate());
        payload.put("maxDistanceKm", preferences.get(0).getMaxDistanceKm());
        payload.put("maxBudget", preferences.get(0).getMaxBudget());

        return restTemplate.postForObject(AI_URL,  payload, Map.class);
    }
}
