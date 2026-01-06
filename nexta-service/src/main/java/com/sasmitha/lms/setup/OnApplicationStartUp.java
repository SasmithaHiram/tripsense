package com.sasmitha.lms.setup;

import com.sasmitha.lms.model.Role;
import com.sasmitha.lms.model.User;
import com.sasmitha.lms.repository.AuthRepository;
import com.sasmitha.lms.repository.RoleRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class OnApplicationStartUp {
    private final RoleRepository roleRepository;
    private final AuthRepository authRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;

    @EventListener
    @Transactional
    public void onApplicationStartUp(ContextRefreshedEvent contextRefreshedEvent) {
        if (roleRepository.findByName("SYSTEM_ADMIN").isPresent()) {
            log.info("Admin has been found");
        } else {
            Role role = new Role();
            role.setName("SYSTEM_ADMIN");
            roleRepository.save(role);
            User user = new User();
            user.setRole(role);
            user.setFirstName("Sasmitha Hiram");
            user.setLastName("Mendis");
            user.setEmail("sasmithahiram2003@gmail.com");
            user.setPassword(bCryptPasswordEncoder.encode("123"));
            authRepository.save(user);
        }
    }
}
