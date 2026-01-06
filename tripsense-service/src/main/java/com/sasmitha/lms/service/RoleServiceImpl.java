package com.sasmitha.lms.service;

import com.sasmitha.lms.dto.RoleRequest;
import com.sasmitha.lms.model.Role;
import com.sasmitha.lms.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl {
    private final RoleRepository roleRepository;

    public Set<RoleRequest> findAll() {
        List<Role> rolesFromDatabase = roleRepository.findAll();

        if (rolesFromDatabase.isEmpty()) {
            return Collections.emptySet();
        } else {
            return rolesFromDatabase.stream().map(role -> new RoleRequest(role.getId(), role.getName())).collect(Collectors.toSet());
        }
    }

    public RoleRequest create(RoleRequest roleRequest) {
        Role role = new Role();
        role.setName(roleRequest.getName());
        Role saved = roleRepository.save(role);
        return new RoleRequest(saved.getId(), saved.getName());
    }
}
