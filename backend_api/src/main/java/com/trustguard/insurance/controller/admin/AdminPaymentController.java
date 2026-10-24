package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.PaymentResponse;
import com.trustguard.insurance.dto.admin.AdminMarkPaidRequest;
import com.trustguard.insurance.service.PaymentService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/payments")
@RequiredArgsConstructor
@Tag(name = "Admin · Payments")
public class AdminPaymentController {

    private final PaymentService paymentService;

    @GetMapping
    public List<PaymentResponse> list() {
        return paymentService.adminList();
    }

    @PostMapping("/{id}/mark-paid")
    public PaymentResponse markPaid(@PathVariable UUID id, @Valid @RequestBody AdminMarkPaidRequest request) {
        return paymentService.adminMarkPaid(id, request.method());
    }
}
