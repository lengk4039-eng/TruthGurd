package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.PurchaseRequest;
import com.trustguard.insurance.dto.admin.CreateOfflinePolicyRequest;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.PaymentMethod;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicySource;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PolicyRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PolicyServiceTest {

    @Mock private PolicyRepository policyRepository;
    @Mock private PackageService packageService;
    @Mock private PaymentService paymentService;
    @Mock private NotificationService notificationService;
    @Mock private QuotationService quotationService;

    @InjectMocks
    private PolicyService policyService;

    private User customer(UUID id) {
        return User.builder().id(id).fullName("Customer").email("c@example.com").phone("x").passwordHash("h").role(Role.CUSTOMER).build();
    }

    private User admin(UUID id) {
        return User.builder().id(id).fullName("Admin").email("a@example.com").phone("x").passwordHash("h").role(Role.ADMIN).build();
    }

    @Test
    void purchaseComputesTotalPremiumFromMonthlyPriceDurationAndAddOns() {
        User user = customer(UUID.randomUUID());
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("Health Shield Basic").monthlyPrice(BigDecimal.valueOf(45)).build();
        when(packageService.findEntity(any())).thenReturn(pkg);
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> {
            Policy policy = inv.getArgument(0);
            policy.setId(UUID.randomUUID());
            return policy;
        });

        var request = new PurchaseRequest(pkg.getId().toString(), 6, PaymentMethod.CARD, BigDecimal.valueOf(27), null, null);
        PolicyResponse response = policyService.purchase(user, request);

        // 45 * 6 + 27 addOn = 297
        assertThat(response.totalPremium()).isEqualByComparingTo("297");
        assertThat(response.status()).isEqualTo(PolicyStatus.ACTIVE);
        assertThat(response.source()).isEqualTo(PolicySource.APP_PURCHASE);
        verify(paymentService).createInitialInvoice(any(Policy.class), eq(PaymentMethod.CARD));
    }

    @Test
    void purchaseWithNoAddOnsChargesJustTheBasePrice() {
        User user = customer(UUID.randomUUID());
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("TravelEase").monthlyPrice(BigDecimal.valueOf(15)).build();
        when(packageService.findEntity(any())).thenReturn(pkg);
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> {
            Policy policy = inv.getArgument(0);
            policy.setId(UUID.randomUUID());
            return policy;
        });

        var request = new PurchaseRequest(pkg.getId().toString(), 1, PaymentMethod.CARD, null, null, null);
        PolicyResponse response = policyService.purchase(user, request);

        assertThat(response.totalPremium()).isEqualByComparingTo("15");
    }

    @Test
    void ownerCanReadTheirOwnPolicy() {
        User owner = customer(UUID.randomUUID());
        Policy policy = policyOwnedBy(owner);
        when(policyRepository.findById(policy.getId())).thenReturn(Optional.of(policy));

        assertThat(policyService.getById(owner, policy.getId()).id()).isEqualTo(policy.getId().toString());
    }

    @Test
    void nonOwnerNonAdminCannotReadSomeoneElsesPolicy() {
        User owner = customer(UUID.randomUUID());
        User stranger = customer(UUID.randomUUID());
        Policy policy = policyOwnedBy(owner);
        when(policyRepository.findById(policy.getId())).thenReturn(Optional.of(policy));

        assertThatThrownBy(() -> policyService.getById(stranger, policy.getId())).isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void adminCanReadAnyonesPolicy() {
        User owner = customer(UUID.randomUUID());
        User adminUser = admin(UUID.randomUUID());
        Policy policy = policyOwnedBy(owner);
        when(policyRepository.findById(policy.getId())).thenReturn(Optional.of(policy));

        assertThat(policyService.getById(adminUser, policy.getId()).id()).isEqualTo(policy.getId().toString());
    }

    @Test
    void adminCannotRegisterAnOfflinePolicyWithADuplicateNumber() {
        when(policyRepository.existsByPolicyNumberIgnoreCase("TG-OFFLINE-1234")).thenReturn(true);

        var request = new CreateOfflinePolicyRequest(
                "TG-OFFLINE-1234", UUID.randomUUID().toString(), LocalDate.of(1990, 1, 1),
                LocalDate.now(), LocalDate.now().plusYears(1), BigDecimal.valueOf(500), BigDecimal.ZERO);

        assertThatThrownBy(() -> policyService.adminCreateOfflinePolicy(request)).isInstanceOf(BadRequestException.class);
        verify(policyRepository, never()).save(any());
        verify(packageService, never()).findEntity(any());
    }

    @Test
    void adminRegisteringAnOfflinePolicyStartsItPendingAndUnowned() {
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("HomeSafe Owners").build();
        when(policyRepository.existsByPolicyNumberIgnoreCase("tg-offline-5555")).thenReturn(false);
        when(packageService.findEntity(pkg.getId())).thenReturn(pkg);
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> {
            Policy policy = inv.getArgument(0);
            policy.setId(UUID.randomUUID());
            return policy;
        });

        var request = new CreateOfflinePolicyRequest(
                "tg-offline-5555", pkg.getId().toString(), LocalDate.of(1990, 1, 1),
                LocalDate.now(), LocalDate.now().plusYears(1), BigDecimal.valueOf(660), BigDecimal.valueOf(220));

        PolicyResponse response = policyService.adminCreateOfflinePolicy(request);

        assertThat(response.status()).isEqualTo(PolicyStatus.PENDING);
        assertThat(response.source()).isEqualTo(PolicySource.LINKED_EXISTING);
        assertThat(response.policyNumber()).isEqualTo("TG-OFFLINE-5555");
        verify(policyRepository, times(1)).save(any(Policy.class));
    }

    private Policy policyOwnedBy(User owner) {
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("Health Shield Basic").build();
        return Policy.builder()
                .id(UUID.randomUUID())
                .policyNumber("POL-2026-0001")
                .user(owner)
                .insurancePackage(pkg)
                .status(PolicyStatus.ACTIVE)
                .source(PolicySource.APP_PURCHASE)
                .totalPremium(BigDecimal.valueOf(100))
                .amountPaid(BigDecimal.valueOf(100))
                .build();
    }
}
