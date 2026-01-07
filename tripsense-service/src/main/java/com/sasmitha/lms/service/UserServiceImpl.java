package com.sasmitha.lms.service;

import com.sasmitha.lms.dto.RegisterResponse;
import com.sasmitha.lms.dto.UserRegisterRequest;
import com.sasmitha.lms.model.Role;
import com.sasmitha.lms.model.User;
import com.sasmitha.lms.repository.AdminRepository;
import com.sasmitha.lms.repository.RoleRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl {
    private final AdminRepository adminRepository;
    private final RoleRepository roleRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    public RegisterResponse create(UserRegisterRequest userRegisterRequest) {
        if (adminRepository.findByEmail(userRegisterRequest.getEmail()).isPresent()) {
            throw new RuntimeException(userRegisterRequest.getEmail() + " is already registered");
        }

        Role roleFromDB = roleRepository.findByName("USER")
                .orElseThrow(() -> new RuntimeException(userRegisterRequest.getRole() + " Role not found"));

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
}

