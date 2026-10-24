package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.ClaimResponse;
import com.trustguard.insurance.dto.admin.UpdateClaimStatusRequest;
import com.trustguard.insurance.service.ClaimService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/claims")
@RequiredArgsConstructor
@Tag(name = "Admin · Claims")
public class AdminClaimController {

    private final ClaimService claimService;

    @GetMapping
    public List<ClaimResponse> list() {
        return claimService.adminList();
    }

    @PostMapping("/{id}/status")
    public ClaimResponse updateStatus(@PathVariable UUID id,
                                      @Valid @RequestBody UpdateClaimStatusRequest request) {
        return claimService.adminUpdateStatus(id, request);
    }
}
