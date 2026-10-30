package com.trustguard.insurance.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record RegisterRequest(
        @NotBlank(message = "Full name is required") String fullName,
        @NotBlank @Email(message = "A valid email is required") String email,
        @NotBlank(message = "Phone number is required") String phone,
        @NotNull(message = "Date of birth is required") LocalDate dateOfBirth,
        @NotBlank @Size(min = 6, message = "Password must be at least 6 characters") String password,
        boolean hasExistingPolicy,
        String policyVerificationToken
) {
}
