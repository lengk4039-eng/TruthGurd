package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.dto.auth.AuthResponse;
import com.trustguard.insurance.dto.auth.LinkPolicyRequest;
import com.trustguard.insurance.dto.auth.LoginRequest;
import com.trustguard.insurance.dto.auth.RefreshRequest;
import com.trustguard.insurance.dto.auth.RegisterRequest;
import com.trustguard.insurance.dto.auth.VerifyPolicyRequest;
import com.trustguard.insurance.dto.auth.VerifyPolicyResponse;
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

import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    public static final int MINIMUM_AGE_YEARS = 18;

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
        if (request.dateOfBirth().isAfter(LocalDate.now().minusYears(MINIMUM_AGE_YEARS))) {
            throw new BadRequestException("You must be at least 18 years old to create an account.");
        }
        Policy verifiedPolicy = request.hasExistingPolicy()
                ? resolveVerifiedPolicy(request.policyVerificationToken())
                : null;
        User user = User.builder()
                .fullName(request.fullName())
                .email(request.email().toLowerCase())
                .phone(request.phone())
                .dateOfBirth(request.dateOfBirth())
                .passwordHash(passwordEncoder.encode(request.password()))
                .role(Role.CUSTOMER)
                .build();
        user = userRepository.save(user);
        notificationService.notify(user, com.trustguard.insurance.entity.NotificationType.SYSTEM,
                "Welcome to TrustGuard!", "Your account is ready. Browse our plans to get covered in minutes.");
        if (verifiedPolicy != null) {
            attachPolicy(user, verifiedPolicy);
        }
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
                .orElseThrow(AuthService::policyNotFound);

        boolean alreadyLinkedToMe = policy.getUser() != null
                && policy.getUser().getId().equals(currentUser.getId());
        if (alreadyLinkedToMe) {
            return PolicyResponse.from(policy);
        }

        requireVerifiable(policy, request.dateOfBirth());
        return PolicyResponse.from(attachPolicy(currentUser, policy));
    }

    /**
     * Confirms a policy number + date of birth belong to a policy nobody has
     * claimed yet, and hands back the token registration must present.
     */
    @Transactional(readOnly = true)
    public VerifyPolicyResponse verifyPolicy(VerifyPolicyRequest request) {
        Policy policy = findUnclaimedMatchingPolicy(request.policyNumber(), request.dateOfBirth());
        return new VerifyPolicyResponse(
                jwtService.generatePolicyVerificationToken(policy.getId()),
                policy.getPolicyNumber(),
                policy.getInsurancePackage().getName());
    }

    private Policy findUnclaimedMatchingPolicy(String policyNumber, LocalDate dateOfBirth) {
        Policy policy = policyRepository.findByPolicyNumberIgnoreCase(policyNumber.trim())
                .orElseThrow(AuthService::policyNotFound);
        requireVerifiable(policy, dateOfBirth);
        return policy;
    }

    private void requireVerifiable(Policy policy, LocalDate dateOfBirth) {
        boolean dobMatches = policy.getDateOfBirthOnRecord() != null
                && policy.getDateOfBirthOnRecord().equals(dateOfBirth);
        if (!dobMatches || policy.getUser() != null) {
            throw policyNotFound();
        }
    }

    private Policy resolveVerifiedPolicy(String verificationToken) {
        if (verificationToken == null || verificationToken.isBlank()) {
            throw new BadRequestException("Verify your policy number before creating an account.");
        }
        if (!jwtService.isTokenValid(verificationToken)
                || !jwtService.isPolicyVerificationToken(verificationToken)) {
            throw new BadRequestException("Your policy verification expired. Please verify it again.");
        }
        UUID policyId = UUID.fromString(jwtService.extractUserId(verificationToken));
        Policy policy = policyRepository.findById(policyId)
                .orElseThrow(() -> new BadRequestException("Your policy verification expired. Please verify it again."));
        if (policy.getUser() != null) {
            throw new BadRequestException("That policy is already linked to another account.");
        }
        return policy;
    }

    private Policy attachPolicy(User owner, Policy policy) {
        policy.setUser(owner);
        if (policy.getStatus() == PolicyStatus.PENDING) {
            policy.setStatus(PolicyStatus.ACTIVE);
        }
        policy = policyRepository.save(policy);
        notificationService.notify(owner, com.trustguard.insurance.entity.NotificationType.POLICY,
                "Policy linked", policy.getInsurancePackage().getName() + " is now in My Policies.");
        return policy;
    }

    /** Deliberately vague: never confirm which half of the pair was wrong. */
    private static BadRequestException policyNotFound() {
        return new BadRequestException(
                "We couldn't find a policy with that number and date of birth. Double-check with your agent and try again.");
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        return new AuthResponse(accessToken, refreshToken, UserResponse.from(user));
    }
}
