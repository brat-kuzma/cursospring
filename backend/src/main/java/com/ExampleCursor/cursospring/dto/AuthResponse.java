package com.ExampleCursor.cursospring.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {

    private String username;
    private boolean authenticated;
}
