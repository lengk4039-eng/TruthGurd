package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.auth.AuthResponse;
import com.trustguard.insurance.dto.auth.LinkPolicyRequest;
import com.trustguard.insurance.dto.auth.LoginRequest;
import com.trustguard.insurance.dto.auth.RefreshRequest;
import com.trustguard.insurance.dto.auth.RegisterRequest;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.repository.PolicyRepository;
import com.trustguard.insurance.repository.UserRepository;
import com.trustguard.insurance.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private PolicyRepository policyRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private AuthenticationManager authenticationManager;
    @Mock private NotificationService notificationService;

    private AuthService authService;

    private static final String SECRET = "test-secret-key-at-least-32-bytes-long-for-hs256";

    @BeforeEach
    void setUp() {
        JwtService jwtService = new JwtService(SECRET, 900_000L, 2_592_000_000L);
        authService = new AuthService(userRepository, policyRepository, passwordEncoder, authenticationManager, jwtService, notificationService);
    }

    private User buildUser(UUID id) {
        return User.builder()
                .id(id)
                .fullName("Jordan Lee")
                .email("jordan.lee@email.com")
                .phone("+1 555-0142")
                .passwordHash("encoded-hash")
                .role(Role.CUSTOMER)
                .kycVerified(true)
                .createdAt(Instant.now())
                .build();
    }

    @Test
    void registerSavesUserWithEncodedPasswordAndReturnsTokens() {
        var request = new RegisterRequest("Jordan Lee", "jordan.lee@email.com", "+1 555-0142", "Password123");
        UUID id = UUID.randomUUID();
        when(userRepository.existsByEmailIgnoreCase(request.email())).thenReturn(false);
        when(passwordEncoder.encode(request.password())).thenReturn("encoded-hash");
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            User u = inv.getArgument(0);
            u.setId(id);
            u.setCreatedAt(Instant.now());
            return u;
        });

        AuthResponse response = authService.register(request);

        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.refreshToken()).isNotBlank();
        assertThat(response.user().email()).isEqualTo("jordan.lee@email.com");
        assertThat(response.user().role()).isEqualTo(Role.CUSTOMER);
        verify(notificationService).notify(any(User.class), any(), anyString(), anyString());
    }

    @Test
    void registerThrowsWhenEmailAlreadyExists() {
        var request = new RegisterRequest("Jordan Lee", "jordan.lee@email.com", "+1 555-0142", "Password123");
        when(userRepository.existsByEmailIgnoreCase(request.email())).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("already exists");
        verify(userRepository, never()).save(any());
    }

    @Test
    void loginAuthenticatesAndReturnsTokens() {
        var request = new LoginRequest("jordan.lee@email.com", "Password123");
        User user = buildUser(UUID.randomUUID());
        when(authenticationManager.authenticate(any())).thenReturn(mock(Authentication.class));
        when(userRepository.findByEmailIgnoreCase(request.email())).thenReturn(Optional.of(user));

        AuthResponse response = authService.login(request);

        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.user().email()).isEqualTo(user.getEmail());
    }

    @Test
    void loginPropagatesBadCredentials() {
        var request = new LoginRequest("jordan.lee@email.com", "wrong-password");
        when(authenticationManager.authenticate(any())).thenThrow(new BadCredentialsException("Bad credentials"));

        assertThatThrownBy(() -> authService.login(request)).isInstanceOf(BadCredentialsException.class);
    }

    @Test
    void refreshRejectsAnAccessTokenUsedAsARefreshToken() {
        User user = buildUser(UUID.randomUUID());
        // An access token has type=access, so isRefreshToken() is false and refresh() should reject it.
        JwtService jwtService = new JwtService(SECRET, 900_000L, 2_592_000_000L);
        String accessToken = jwtService.generateAccessToken(user);

        assertThatThrownBy(() -> authService.refresh(new RefreshRequest(accessToken)))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void linkExistingPolicyWithMatchingDetailsLinksAndActivatesThePolicy() {
        User user = buildUser(UUID.randomUUID());
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("HomeSafe Owners").build();
        Policy unclaimed = Policy.builder()
                .id(UUID.randomUUID())
                .policyNumber("TG-OFFLINE-7734")
                .insurancePackage(pkg)
                .status(PolicyStatus.PENDING)
                .dateOfBirthOnRecord(LocalDate.of(1990, 5, 12))
                .totalPremium(BigDecimal.valueOf(660))
                .amountPaid(BigDecimal.valueOf(330))
                .build();
        when(policyRepository.findByPolicyNumberIgnoreCase("TG-OFFLINE-7734")).thenReturn(Optional.of(unclaimed));
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> inv.getArgument(0));

        var result = authService.linkExistingPolicy(user, new LinkPolicyRequest("TG-OFFLINE-7734", LocalDate.of(1990, 5, 12)));

        assertThat(result.status()).isEqualTo(PolicyStatus.ACTIVE);
        verify(notificationService).notify(any(User.class), any(), anyString(), anyString());
    }

    @Test
    void linkExistingPolicyWithWrongDateOfBirthIsRejected() {
        User user = buildUser(UUID.randomUUID());
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("HomeSafe Owners").build();
        Policy unclaimed = Policy.builder()
                .id(UUID.randomUUID())
                .policyNumber("TG-OFFLINE-7734")
                .insurancePackage(pkg)
                .status(PolicyStatus.PENDING)
                .dateOfBirthOnRecord(LocalDate.of(1990, 5, 12))
                .build();
        when(policyRepository.findByPolicyNumberIgnoreCase("TG-OFFLINE-7734")).thenReturn(Optional.of(unclaimed));

        assertThatThrownBy(() -> authService.linkExistingPolicy(user, new LinkPolicyRequest("TG-OFFLINE-7734", LocalDate.of(1999, 1, 1))))
                .isInstanceOf(BadRequestException.class);
        verify(policyRepository, never()).save(any());
    }

    @Test
    void linkExistingPolicyAlreadyOwnedBySomeoneElseIsRejected() {
        User me = buildUser(UUID.randomUUID());
        User someoneElse = buildUser(UUID.randomUUID());
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("HomeSafe Owners").build();
        Policy alreadyClaimed = Policy.builder()
                .id(UUID.randomUUID())
                .policyNumber("TG-OFFLINE-7734")
                .insurancePackage(pkg)
                .status(PolicyStatus.ACTIVE)
                .user(someoneElse)
                .dateOfBirthOnRecord(LocalDate.of(1990, 5, 12))
                .build();
        when(policyRepository.findByPolicyNumberIgnoreCase("TG-OFFLINE-7734")).thenReturn(Optional.of(alreadyClaimed));

        assertThatThrownBy(() -> authService.linkExistingPolicy(me, new LinkPolicyRequest("TG-OFFLINE-7734", LocalDate.of(1990, 5, 12))))
                .isInstanceOf(BadRequestException.class);
    }
}
