package com.sasmitha.lms.controller;

import com.sasmitha.lms.dto.PreferenceRequest;
import com.sasmitha.lms.model.Preference;
import com.sasmitha.lms.service.PreferenceServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/preferences")
@RequiredArgsConstructor
@CrossOrigin
public class PreferenceController {
    private final PreferenceServiceImpl preferenceService;

    @PostMapping
    public ResponseEntity<Preference> create(@RequestBody PreferenceRequest preferenceRequest) {
        Preference saved = preferenceService.save(preferenceRequest);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }
}

