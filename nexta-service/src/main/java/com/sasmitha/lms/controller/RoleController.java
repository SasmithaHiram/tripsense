package com.sasmitha.lms.controller;

import com.sasmitha.lms.dto.RoleRequest;
import com.sasmitha.lms.service.RoleServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequestMapping("/roles")
@RequiredArgsConstructor
@CrossOrigin
public class RoleController {
    private final RoleServiceImpl roleServiceImpl;

    @PostMapping
    @PreAuthorize("hasAuthority('SYSTEM_ADMIN')")
    public ResponseEntity<RoleRequest> create(@RequestBody RoleRequest roleRequest) {
        RoleRequest role = roleServiceImpl.create(roleRequest);

        return (role == null)
            ? ResponseEntity.status(HttpStatus.NOT_FOUND).body(null)
                : ResponseEntity.status(HttpStatus.CREATED).body(role);
    }

    @GetMapping
    @PreAuthorize("hasAuthority('SYSTEM_ADMIN')")
    public ResponseEntity<Set<RoleRequest>> findAll() {
        Set<RoleRequest> roles = roleServiceImpl.findAll();

        if (roles.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        } else {
            return new ResponseEntity<>(roles, HttpStatus.OK);
        }
    }
}
