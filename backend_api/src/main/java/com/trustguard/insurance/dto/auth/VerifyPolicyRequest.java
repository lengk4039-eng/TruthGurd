package com.trustguard.insurance.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record VerifyPolicyRequest(
        @NotBlank(message = "Policy number is required") String policyNumber,
        @NotNull(message = "Date of birth is required") LocalDate dateOfBirth
) {
}
