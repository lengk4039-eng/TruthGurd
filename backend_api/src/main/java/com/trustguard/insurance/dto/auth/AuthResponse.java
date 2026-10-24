package com.trustguard.insurance.dto.auth;

import com.trustguard.insurance.dto.UserResponse;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        UserResponse user
) {
}
