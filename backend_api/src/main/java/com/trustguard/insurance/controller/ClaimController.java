package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.ClaimEligibilityResponse;
import com.trustguard.insurance.dto.ClaimResponse;
import com.trustguard.insurance.dto.CreateClaimRequest;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.ClaimService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/claims")
@RequiredArgsConstructor
@Tag(name = "Claims")
public class ClaimController {

    private final ClaimService claimService;

    @GetMapping("/me")
    public List<ClaimResponse> myClaims(@AuthenticationPrincipal AppUserDetails principal) {
        return claimService.getMyClaims(principal.getUser());
    }

    @GetMapping("/{id}")
    public ClaimResponse getById(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return claimService.getById(principal.getUser(), id);
    }

    @GetMapping("/policy/{policyId}")
    public List<ClaimResponse> getForPolicy(@AuthenticationPrincipal AppUserDetails principal,
                                            @PathVariable UUID policyId) {
        return claimService.getForPolicy(principal.getUser(), policyId);
    }

    @GetMapping("/eligibility/{policyId}")
    public ClaimEligibilityResponse eligibility(@AuthenticationPrincipal AppUserDetails principal,
                                                @PathVariable UUID policyId) {
        return claimService.eligibility(principal.getUser(), policyId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ClaimResponse submit(@AuthenticationPrincipal AppUserDetails principal,
                                @Valid @RequestBody CreateClaimRequest request) {
        return claimService.submit(principal.getUser(), request);
    }
}
