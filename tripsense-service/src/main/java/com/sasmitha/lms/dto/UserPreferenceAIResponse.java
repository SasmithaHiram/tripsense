package com.sasmitha.lms.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Setter
@Getter
public class UserPreferenceAIResponse {
    private List<PreferenceResponse> preferences;
    private Map<String,Object> aiRecommendations;
}
