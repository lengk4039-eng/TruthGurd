package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;

import java.time.Instant;

public record UserResponse(
        String id,
        String fullName,
        String email,
        String phone,
        Role role,
        boolean kycVerified,
        Instant memberSince
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId().toString(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getRole(),
                user.isKycVerified(),
                user.getCreatedAt()
        );
    }
}
