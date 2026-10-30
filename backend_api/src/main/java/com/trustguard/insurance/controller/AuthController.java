package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.auth.AuthResponse;
import com.trustguard.insurance.dto.auth.LinkPolicyRequest;
import com.trustguard.insurance.dto.auth.LoginRequest;
import com.trustguard.insurance.dto.auth.RefreshRequest;
import com.trustguard.insurance.dto.auth.RegisterRequest;
import com.trustguard.insurance.dto.auth.VerifyPolicyRequest;
import com.trustguard.insurance.dto.auth.VerifyPolicyResponse;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.AuthService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Auth")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request);
    }

    @PostMapping("/verify-policy")
    public VerifyPolicyResponse verifyPolicy(@Valid @RequestBody VerifyPolicyRequest request) {
        return authService.verifyPolicy(request);
    }

    @PostMapping("/link-existing-policy")
    public PolicyResponse linkExistingPolicy(
            @AuthenticationPrincipal AppUserDetails principal,
            @Valid @RequestBody LinkPolicyRequest request
    ) {
        return authService.linkExistingPolicy(principal.getUser(), request);
    }
}
