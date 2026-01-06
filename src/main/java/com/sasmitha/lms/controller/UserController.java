package com.sasmitha.lms.controller;

import com.sasmitha.lms.dto.RegisterResponse;
import com.sasmitha.lms.dto.UserRegisterRequest;
import com.sasmitha.lms.service.UserServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin
public class UserController {
    private final UserServiceImpl userServiceImpl;

    public ResponseEntity<RegisterResponse> create(UserRegisterRequest userRegisterRequest) {
        userServiceImpl.create(userRegisterRequest);
    }
}
