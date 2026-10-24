package com.trustguard.insurance.dto.auth;

import jakarta.validation.constraints.NotBlank;

import java.time.LocalDate;

public record LinkPolicyRequest(
        @NotBlank(message = "Policy number is required") String policyNumber,
        LocalDate dateOfBirth
) {
}
