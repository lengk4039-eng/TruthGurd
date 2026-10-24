package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.PurchaseRequest;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.PolicyService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/policies")
@RequiredArgsConstructor
@Tag(name = "Policies")
public class PolicyController {

    private final PolicyService policyService;

    @GetMapping("/me")
    public List<PolicyResponse> myPolicies(@AuthenticationPrincipal AppUserDetails principal) {
        return policyService.getMyPolicies(principal.getUser());
    }

    @GetMapping("/{id}")
    public PolicyResponse getById(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return policyService.getById(principal.getUser(), id);
    }

    @PostMapping("/purchase")
    @ResponseStatus(HttpStatus.CREATED)
    public PolicyResponse purchase(@AuthenticationPrincipal AppUserDetails principal, @Valid @RequestBody PurchaseRequest request) {
        return policyService.purchase(principal.getUser(), request);
    }
}
