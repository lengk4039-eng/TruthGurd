package com.trustguard.insurance.security;

import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {

    private static final String SECRET = "test-secret-key-at-least-32-bytes-long-for-hs256";

    private JwtService jwtService;
    private User user;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(SECRET, 900_000L, 2_592_000_000L, 900_000L);
        user = User.builder()
                .id(UUID.randomUUID())
                .fullName("Test User")
                .email("test@example.com")
                .phone("+1 555-0000")
                .passwordHash("hashed")
                .role(Role.CUSTOMER)
                .createdAt(Instant.now())
                .build();
    }

    @Test
    void accessTokenIsValidAndCarriesTheUserId() {
        String token = jwtService.generateAccessToken(user);

        assertThat(jwtService.isTokenValid(token)).isTrue();
        assertThat(jwtService.extractUserId(token)).isEqualTo(user.getId().toString());
        assertThat(jwtService.isRefreshToken(token)).isFalse();
    }

    @Test
    void refreshTokenIsFlaggedAsARefreshToken() {
        String token = jwtService.generateRefreshToken(user);

        assertThat(jwtService.isTokenValid(token)).isTrue();
        assertThat(jwtService.isRefreshToken(token)).isTrue();
    }

    @Test
    void garbageTokenIsRejected() {
        assertThat(jwtService.isTokenValid("not-a-real-token")).isFalse();
    }

    @Test
    void tokenSignedWithADifferentSecretIsRejected() {
        JwtService otherService = new JwtService("a-completely-different-secret-key-32-bytes-plus", 900_000L, 2_592_000_000L, 900_000L);
        String token = otherService.generateAccessToken(user);

        assertThat(jwtService.isTokenValid(token)).isFalse();
    }
}
