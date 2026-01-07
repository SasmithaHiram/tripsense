package com.sasmitha.lms.controller;

import com.sasmitha.lms.dto.RegisterResponse;
import com.sasmitha.lms.dto.UserRegisterRequest;
import com.sasmitha.lms.service.UserServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin
public class UserController {
    private final UserServiceImpl userServiceImpl;

    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> create(@RequestBody UserRegisterRequest userRegisterRequest) {
        RegisterResponse user = userServiceImpl.create(userRegisterRequest);

        if (user == null) {
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<>(user, HttpStatus.CREATED);
        }
    }
}


