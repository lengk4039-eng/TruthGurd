package com.trustguard.insurance.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record UpdateUserRequest(
        @NotBlank String fullName,
        @NotBlank @Email String email,
        @NotBlank String phone
) {
}
