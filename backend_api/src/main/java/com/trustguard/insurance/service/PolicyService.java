package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.PurchaseRequest;
import com.trustguard.insurance.dto.admin.CreateOfflinePolicyRequest;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicySource;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@Service
@RequiredArgsConstructor
public class PolicyService {

    private final PolicyRepository policyRepository;
    private final PackageService packageService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;
    private final QuotationService quotationService;

    public List<PolicyResponse> getMyPolicies(User user) {
        return policyRepository.findByUserOrderByCreatedAtDesc(user).stream().map(PolicyResponse::from).toList();
    }

    public PolicyResponse getById(User requester, UUID id) {
        return PolicyResponse.from(findOwnedOrAdmin(requester, id));
    }

    Policy findOwnedOrAdmin(User requester, UUID id) {
        Policy policy = policyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Policy not found."));
        boolean isOwner = policy.getUser() != null && policy.getUser().getId().equals(requester.getId());
        if (!isOwner && requester.getRole() != Role.ADMIN) {
            throw new ResourceNotFoundException("Policy not found.");
        }
        return policy;
    }

    @Transactional
    public PolicyResponse purchase(User user, PurchaseRequest request) {
        InsurancePackage pkg = packageService.findEntity(UUID.fromString(request.packageId()));
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = startDate.plusMonths(request.durationMonths());

        BigDecimal totalPremium;
        if (request.isFromQuotation()) {
            if (request.quotedPremium() == null || request.quotedPremium().signum() <= 0) {
                throw new BadRequestException("quotedPremium is required when purchasing from a quotation.");
            }
            totalPremium = request.quotedPremium();
        } else {
            totalPremium = pkg.getMonthlyPrice()
                    .multiply(BigDecimal.valueOf(request.durationMonths()))
                    .multiply(planDiscount(request.durationMonths()))
                    .add(request.addOnTotalOrZero())
                    .setScale(2, RoundingMode.HALF_UP);
        }

        Policy policy = Policy.builder()
                .policyNumber(generatePolicyNumber())
                .user(user)
                .insurancePackage(pkg)
                .status(PolicyStatus.ACTIVE)
                .source(PolicySource.APP_PURCHASE)
                .startDate(startDate)
                .endDate(endDate)
                .totalPremium(totalPremium)
                .amountPaid(BigDecimal.ZERO)
                .build();
        policy = policyRepository.save(policy);

        paymentService.createInitialInvoice(policy, request.paymentMethod());

        if (request.isFromQuotation()) {
            quotationService.linkPolicyOnPurchase(user, UUID.fromString(request.quotationId()), policy);
        } else {
            notificationService.notify(user, com.trustguard.insurance.entity.NotificationType.POLICY,
                    "You're covered!", "Your " + pkg.getName() + " policy is now active.");
        }

        return PolicyResponse.from(policy);
    }

    /** Must match the plan tiers offered in the app: 6 months 5% off, 12 months 15% off. */
    private static BigDecimal planDiscount(int durationMonths) {
        return switch (durationMonths) {
            case 6 -> new BigDecimal("0.95");
            case 12 -> new BigDecimal("0.85");
            default -> BigDecimal.ONE;
        };
    }

    public List<PolicyResponse> adminList() {
        return policyRepository.findAll().stream().map(PolicyResponse::from).toList();
    }

    @Transactional
    public PolicyResponse adminCreateOfflinePolicy(CreateOfflinePolicyRequest request) {
        if (policyRepository.existsByPolicyNumberIgnoreCase(request.policyNumber())) {
            throw new BadRequestException("A policy with this number already exists.");
        }
        InsurancePackage pkg = packageService.findEntity(UUID.fromString(request.packageId()));
        Policy policy = Policy.builder()
                .policyNumber(request.policyNumber().trim().toUpperCase())
                .user(null)
                .insurancePackage(pkg)
                .status(PolicyStatus.PENDING)
                .source(PolicySource.LINKED_EXISTING)
                .startDate(request.startDate())
                .endDate(request.endDate())
                .totalPremium(request.totalPremium())
                .amountPaid(request.amountPaid() == null ? BigDecimal.ZERO : request.amountPaid())
                .dateOfBirthOnRecord(request.dateOfBirth())
                .build();
        return PolicyResponse.from(policyRepository.save(policy));
    }

    private String generatePolicyNumber() {
        String year = String.valueOf(LocalDate.now().getYear());
        String suffix = DateTimeFormatter.ofPattern("MMddHHmmss").format(java.time.LocalDateTime.now())
                + ThreadLocalRandom.current().nextInt(10, 99);
        return "POL-" + year + "-" + suffix.substring(suffix.length() - 6);
    }
}
