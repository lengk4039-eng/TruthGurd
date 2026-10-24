package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.PayRequest;
import com.trustguard.insurance.dto.PaymentResponse;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.PaymentService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payments")
public class PaymentController {

    private final PaymentService paymentService;

    @GetMapping("/me")
    public List<PaymentResponse> myPayments(@AuthenticationPrincipal AppUserDetails principal) {
        return paymentService.getMyPayments(principal.getUser());
    }

    @GetMapping("/{id}")
    public PaymentResponse getById(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return paymentService.getById(principal.getUser(), id);
    }

    @PostMapping("/{id}/pay")
    public PaymentResponse pay(
            @AuthenticationPrincipal AppUserDetails principal,
            @PathVariable UUID id,
            @Valid @RequestBody PayRequest request
    ) {
        return paymentService.payNow(principal.getUser(), id, request.method());
    }
}
