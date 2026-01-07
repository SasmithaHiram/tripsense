package com.sasmitha.lms.dto;

import lombok.*;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class UserDetailResponse {
    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
}
