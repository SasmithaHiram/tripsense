package com.sasmitha.lms.service;

import com.sasmitha.lms.dto.PreferenceRequest;
import com.sasmitha.lms.dto.PreferenceResponse;
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

@Service
@RequiredArgsConstructor
@Transactional
public class PreferenceServiceImpl {
    private final PreferenceRepository preferenceRepository;
    private final AdminRepository adminRepository;

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
        return preferenceResponse;
    }
}
