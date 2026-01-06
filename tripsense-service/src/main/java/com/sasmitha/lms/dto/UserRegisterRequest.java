package com.sasmitha.lms.dto;

import lombok.*;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserRegisterRequest {
    private String role;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
}
