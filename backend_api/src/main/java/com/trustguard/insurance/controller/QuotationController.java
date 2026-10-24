package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.AcceptQuotationRequest;
import com.trustguard.insurance.dto.CreateQuotationRequest;
import com.trustguard.insurance.dto.QuotationResponse;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.QuotationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/quotations")
@RequiredArgsConstructor
@Tag(name = "Quotations")
public class QuotationController {

    private final QuotationService quotationService;

    @GetMapping("/me")
    public List<QuotationResponse> myQuotations(@AuthenticationPrincipal AppUserDetails principal) {
        return quotationService.getMyQuotations(principal.getUser());
    }

    @GetMapping("/{id}")
    public QuotationResponse getById(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return quotationService.getById(principal.getUser(), id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public QuotationResponse request(@AuthenticationPrincipal AppUserDetails principal,
                                     @Valid @RequestBody CreateQuotationRequest request) {
        return quotationService.request(principal.getUser(), request);
    }

    @PostMapping("/{id}/decline")
    public QuotationResponse decline(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return quotationService.decline(principal.getUser(), id);
    }

    @PostMapping("/{id}/accept")
    public QuotationResponse accept(@AuthenticationPrincipal AppUserDetails principal,
                                    @PathVariable UUID id,
                                    @Valid @RequestBody AcceptQuotationRequest request) {
        return quotationService.markAccepted(principal.getUser(), id, UUID.fromString(request.policyId()));
    }
}
