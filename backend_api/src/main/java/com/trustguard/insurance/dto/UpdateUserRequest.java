package com.trustguard.insurance.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record UpdateUserRequest(
        @NotBlank String fullName,
        @NotBlank @Email String email,
        @NotBlank String phone,
        @NotBlank
        @Pattern(regexp = "^[A-Za-z0-9-]{6,20}$", message = "Enter a valid national ID number.")
        String nationalIdNumber
) {
}
