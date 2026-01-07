package com.sasmitha.lms.service;

import com.sasmitha.lms.dto.PreferenceRequest;
import com.sasmitha.lms.dto.PreferenceResponse;
import com.sasmitha.lms.dto.UserPreferenceAIResponse;
import com.sasmitha.lms.model.Preference;
import com.sasmitha.lms.model.User;
import com.sasmitha.lms.repository.AdminRepository;
import com.sasmitha.lms.repository.PreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class PreferenceServiceImpl {
    private final PreferenceRepository preferenceRepository;
    private final AdminRepository adminRepository;
    private final AIServiceImpl aiService;

    public PreferenceResponse create(PreferenceRequest preferenceRequest) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getPrincipal() == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unauthenticated");
        }

        String email = auth.getPrincipal().toString();
        User user = adminRepository.findByEmail(email).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        Preference preference = new Preference();
        preference.setCategories(preferenceRequest.getCategories());
        preference.setLocations(preferenceRequest.getLocations());
        preference.setStartDate(preferenceRequest.getStartDate());
        preference.setEndDate(preferenceRequest.getEndDate());
        preference.setMaxDistanceKm(preferenceRequest.getMaxDistanceKm());
        preference.setMaxBudget(preferenceRequest.getMaxBudget());
        preference.setUser(user);

        preferenceRepository.save(preference);

        PreferenceResponse preferenceResponse = new PreferenceResponse();
        preferenceResponse.setId(preference.getId());
        preferenceResponse.setCategories(preferenceRequest.getCategories());
        preferenceResponse.setLocations(preferenceRequest.getLocations());
        preferenceResponse.setStartDate(preferenceRequest.getStartDate());
        preferenceResponse.setEndDate(preferenceRequest.getEndDate());
        preferenceResponse.setMaxDistanceKm(preferenceRequest.getMaxDistanceKm());
        preferenceResponse.setMaxBudget(preferenceRequest.getMaxBudget());
        preferenceResponse.setUserId(user.getId());
        return preferenceResponse;
    }

    public UserPreferenceAIResponse getByUserId(Long userId) {
        List<Preference> preferences = preferenceRepository.findByUserId(userId);

        if (preferences.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Preference not found");
        }

        Map<String, Object> recommendations = aiService.getRecommendations(preferences);

        List<PreferenceResponse> preferenceResponses = preferences.stream().map(pref -> {
            PreferenceResponse resp = new PreferenceResponse();
            resp.setId(pref.getId());
            resp.setCategories(pref.getCategories());
            resp.setLocations(pref.getLocations());
            resp.setStartDate(pref.getStartDate());
            resp.setEndDate(pref.getEndDate());
            resp.setMaxDistanceKm(pref.getMaxDistanceKm());
            resp.setMaxBudget(pref.getMaxBudget());
            resp.setCreateAt(pref.getCreateAt());
            resp.setUpdateAt(pref.getUpdateAt());
            return resp;
        }).toList();

        UserPreferenceAIResponse userPreferenceAIResponse = new UserPreferenceAIResponse();
        userPreferenceAIResponse.setPreferences(preferenceResponses);
        userPreferenceAIResponse.setAiRecommendations(recommendations);

        return userPreferenceAIResponse;
    }
}
