package com.sasmitha.lms.service;

import com.sasmitha.lms.config.JWTUtil;
import com.sasmitha.lms.dto.LoginRequest;
import com.sasmitha.lms.dto.LoginResponse;
import com.sasmitha.lms.dto.RegisterResponse;
import com.sasmitha.lms.dto.UserRegisterRequest;
import com.sasmitha.lms.model.Role;
import com.sasmitha.lms.model.User;
import com.sasmitha.lms.repository.AdminRepository;
import com.sasmitha.lms.repository.RoleRepository;
import lombok.RequiredArgsConstructor;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl {
    private final AdminRepository adminRepository;
    private final RoleRepository roleRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;
    private final JWTUtil jwtUtil;

    public RegisterResponse create(UserRegisterRequest userRegisterRequest) {
        if (adminRepository.findByEmail(userRegisterRequest.getEmail()).isPresent()) {
            throw new RuntimeException(userRegisterRequest.getEmail() + " is already registered");
        }
        Role roleFromDB = roleRepository.findByName(userRegisterRequest.getRole())
                .orElseThrow(() -> new RuntimeException(userRegisterRequest.getRole() + "Role not found"));

        User user = new User();
        user.setRole(roleFromDB);
        user.setFirstName(userRegisterRequest.getFirstName());
        user.setLastName(userRegisterRequest.getLastName());
        user.setEmail(userRegisterRequest.getEmail());
        user.setPassword(bCryptPasswordEncoder.encode(userRegisterRequest.getPassword()));
        adminRepository.save(user);

        return new RegisterResponse(
                user.getEmail(),
                roleFromDB.getName()
        );
    }

    public LoginResponse loginUser(LoginRequest loginRequest) {
        User user = adminRepository.findByEmail(loginRequest.getEmail()).orElse(null);

        if (user == null) {
            return new LoginResponse("User not found", null);
        }

        if (!bCryptPasswordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            return new LoginResponse("Invalid password", null);
        }
        String token = jwtUtil.generateToken(loginRequest.getEmail(), user.getRole().getName());
        return new LoginResponse(user.getEmail(), token);
    }
}