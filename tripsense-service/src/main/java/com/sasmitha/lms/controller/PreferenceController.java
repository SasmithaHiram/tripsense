package com.sasmitha.lms.controller;

import com.sasmitha.lms.dto.PreferenceRequest;
import com.sasmitha.lms.dto.PreferenceResponse;
import com.sasmitha.lms.dto.UserPreferenceAIResponse;
import com.sasmitha.lms.service.PreferenceServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/preferences")
@RequiredArgsConstructor
@CrossOrigin
public class PreferenceController {
    private final PreferenceServiceImpl preferenceService;

    @PostMapping
    public ResponseEntity<PreferenceResponse> create(@RequestBody PreferenceRequest preferenceRequest) {
        return ResponseEntity.ok(preferenceService.create(preferenceRequest));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<UserPreferenceAIResponse> getByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(preferenceService.getByUserId(userId));
    }
}
