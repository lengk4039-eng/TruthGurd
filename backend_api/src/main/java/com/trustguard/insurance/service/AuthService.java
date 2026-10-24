package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.dto.auth.AuthResponse;
import com.trustguard.insurance.dto.auth.LinkPolicyRequest;
import com.trustguard.insurance.dto.auth.LoginRequest;
import com.trustguard.insurance.dto.auth.RefreshRequest;
import com.trustguard.insurance.dto.auth.RegisterRequest;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PolicyRepository;
import com.trustguard.insurance.repository.UserRepository;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PolicyRepository policyRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final NotificationService notificationService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new BadRequestException("An account with this email already exists.");
        }
        User user = User.builder()
                .fullName(request.fullName())
                .email(request.email().toLowerCase())
                .phone(request.phone())
                .passwordHash(passwordEncoder.encode(request.password()))
                .role(Role.CUSTOMER)
                .build();
        user = userRepository.save(user);
        notificationService.notify(user, com.trustguard.insurance.entity.NotificationType.SYSTEM,
                "Welcome to TrustGuard!", "Your account is ready. Browse our plans to get covered in minutes.");
        return buildAuthResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email().toLowerCase(), request.password()));
        User user = userRepository.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResourceNotFoundException("No account found for " + request.email()));
        return buildAuthResponse(user);
    }

    public AuthResponse refresh(RefreshRequest request) {
        String token = request.refreshToken();
        if (!jwtService.isTokenValid(token) || !jwtService.isRefreshToken(token)) {
            throw new BadRequestException("Refresh token is invalid or expired.");
        }
        UUID userId = UUID.fromString(jwtService.extractUserId(token));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
        return buildAuthResponse(user);
    }

    @Transactional
    public PolicyResponse linkExistingPolicy(User currentUser, LinkPolicyRequest request) {
        Policy policy = policyRepository.findByPolicyNumberIgnoreCase(request.policyNumber().trim())
                .orElseThrow(() -> new BadRequestException(
                        "We couldn't find a policy with that number and date of birth. Double-check with your agent and try again."));

        boolean dobMatches = policy.getDateOfBirthOnRecord() != null
                && policy.getDateOfBirthOnRecord().equals(request.dateOfBirth());
        boolean alreadyLinkedToMe = policy.getUser() != null && policy.getUser().getId().equals(currentUser.getId());

        if (!alreadyLinkedToMe && (!dobMatches || (policy.getUser() != null))) {
            throw new BadRequestException(
                    "We couldn't find a policy with that number and date of birth. Double-check with your agent and try again.");
        }

        if (!alreadyLinkedToMe) {
            policy.setUser(currentUser);
            if (policy.getStatus() == PolicyStatus.PENDING) {
                policy.setStatus(PolicyStatus.ACTIVE);
            }
            policy = policyRepository.save(policy);
            notificationService.notify(currentUser, com.trustguard.insurance.entity.NotificationType.POLICY,
                    "Policy linked", policy.getInsurancePackage().getName() + " is now in My Policies.");
        }
        return PolicyResponse.from(policy);
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        return new AuthResponse(accessToken, refreshToken, UserResponse.from(user));
    }
}
