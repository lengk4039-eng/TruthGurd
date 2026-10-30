package com.trustguard.insurance.dto.admin;

import com.trustguard.insurance.entity.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AdminUpdateUserRequest(
        @NotBlank(message = "Full name is required") String fullName,
        @NotBlank @Email(message = "A valid email is required") String email,
        @NotBlank(message = "Phone number is required") String phone,
        @NotNull(message = "Role is required") Role role,
        boolean kycVerified
) {
}
