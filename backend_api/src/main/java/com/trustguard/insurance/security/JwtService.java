package com.trustguard.insurance.security;

import com.trustguard.insurance.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.Map;
import java.util.UUID;

@Service
public class JwtService {

    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";
    public static final String TYPE_POLICY_VERIFICATION = "policy_verification";

    private final SecretKey key;
    private final long accessTokenExpirationMs;
    private final long refreshTokenExpirationMs;
    private final long policyVerificationExpirationMs;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-token-expiration-ms}") long accessTokenExpirationMs,
            @Value("${app.jwt.refresh-token-expiration-ms}") long refreshTokenExpirationMs,
            @Value("${app.jwt.policy-verification-expiration-ms:900000}") long policyVerificationExpirationMs
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpirationMs = accessTokenExpirationMs;
        this.refreshTokenExpirationMs = refreshTokenExpirationMs;
        this.policyVerificationExpirationMs = policyVerificationExpirationMs;
    }

    public String generateAccessToken(User user) {
        return buildSignedToken(
                user.getId().toString(),
                accessTokenExpirationMs,
                Map.of("role", user.getRole().name(), "type", TYPE_ACCESS));
    }

    public String generateRefreshToken(User user) {
        return buildSignedToken(user.getId().toString(), refreshTokenExpirationMs, Map.of("type", TYPE_REFRESH));
    }

    /**
     * Proves a policy number + date of birth matched while no account existed yet,
     * so registration can demand it without re-running the customer's lookup.
     */
    public String generatePolicyVerificationToken(UUID policyId) {
        return buildSignedToken(
                policyId.toString(),
                policyVerificationExpirationMs,
                Map.of("type", TYPE_POLICY_VERIFICATION, "policy_id", policyId.toString()));
    }

    private String buildSignedToken(String subject, long expirationMs, Map<String, Object> claims) {
        Instant now = Instant.now();
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusMillis(expirationMs)))
                .signWith(key)
                .compact();
    }

    public String extractUserId(String token) {
        return parseClaims(token).getSubject();
    }

    public boolean isRefreshToken(String token) {
        return TYPE_REFRESH.equals(parseClaims(token).get("type", String.class));
    }

    public boolean isPolicyVerificationToken(String token) {
        return TYPE_POLICY_VERIFICATION.equals(parseClaims(token).get("type", String.class));
    }

    public boolean isTokenValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private Claims parseClaims(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }
}
