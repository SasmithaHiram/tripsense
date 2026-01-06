package com.sasmitha.lms.service;

import com.sasmitha.lms.dto.PreferenceRequest;
import com.sasmitha.lms.model.Preference;
import com.sasmitha.lms.model.User;
import com.sasmitha.lms.repository.AdminRepository;
import com.sasmitha.lms.repository.PreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class PreferenceServiceImpl {
    private final PreferenceRepository preferenceRepository;
    private final AdminRepository adminRepository;

    public Preference save(PreferenceRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getPrincipal() == null) {
            throw new RuntimeException("Unauthenticated");
        }

        String email = auth.getPrincipal().toString();
        User user = adminRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));

        Preference preference = new Preference();
        preference.setCategories(request.getCategories());
        preference.setLocations(request.getLocations());
        preference.setStartDate(request.getStartDate());
        preference.setEndDate(request.getEndDate());
        preference.setMaxDistanceKm(request.getMaxDistanceKm());
        preference.setMaxBudget(request.getMaxBudget());
        preference.setUser(user);

        return preferenceRepository.save(preference);
    }
}

