package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.QuotationResponse;
import com.trustguard.insurance.dto.admin.RejectQuotationRequest;
import com.trustguard.insurance.dto.admin.RespondQuotationRequest;
import com.trustguard.insurance.service.QuotationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/quotations")
@RequiredArgsConstructor
@Tag(name = "Admin · Quotations")
public class AdminQuotationController {

    private final QuotationService quotationService;

    @GetMapping
    public List<QuotationResponse> list() {
        return quotationService.adminList();
    }

    @PostMapping("/{id}/respond")
    public QuotationResponse respond(@PathVariable UUID id, @Valid @RequestBody RespondQuotationRequest request) {
        return quotationService.adminRespond(id, request);
    }

    @PostMapping("/{id}/reject")
    public QuotationResponse reject(@PathVariable UUID id, @RequestBody(required = false) RejectQuotationRequest request) {
        return quotationService.adminReject(id, request == null ? new RejectQuotationRequest(null) : request);
    }
}
