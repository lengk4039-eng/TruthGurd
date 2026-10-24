package com.trustguard.insurance.service;

import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.Payment;
import com.trustguard.insurance.entity.PaymentMethod;
import com.trustguard.insurance.entity.PaymentStatus;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PaymentRepository;
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
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PaymentServiceTest {

    @Mock private PaymentRepository paymentRepository;
    @Mock private PolicyRepository policyRepository;
    @Mock private PaymentGateway paymentGateway;
    @Mock private NotificationService notificationService;

    @InjectMocks
    private PaymentService paymentService;

    private User customer(UUID id) {
        return User.builder().id(id).fullName("Customer").email("c@example.com").phone("x").passwordHash("h").role(Role.CUSTOMER).build();
    }

    private Payment pendingPaymentFor(User owner) {
        InsurancePackage pkg = InsurancePackage.builder().id(UUID.randomUUID()).name("Health Shield Basic").build();
        Policy policy = Policy.builder().id(UUID.randomUUID()).user(owner).insurancePackage(pkg).amountPaid(BigDecimal.ZERO).build();
        return Payment.builder()
                .id(UUID.randomUUID())
                .policy(policy)
                .invoiceNumber("INV-1")
                .amount(BigDecimal.valueOf(89))
                .dueDate(LocalDate.now())
                .status(PaymentStatus.PENDING)
                .build();
    }

    @Test
    void payNowChargesTheGatewayMarksPaidAndCreditsThePolicy() {
        User owner = customer(UUID.randomUUID());
        Payment payment = pendingPaymentFor(owner);
        when(paymentRepository.findById(payment.getId())).thenReturn(Optional.of(payment));
        when(paymentGateway.charge(eq(payment.getAmount()), eq(PaymentMethod.CARD)))
                .thenReturn(new PaymentGateway.GatewayResult(true, "TXN-1", "ok"));
        when(paymentRepository.save(any(Payment.class))).thenAnswer(inv -> inv.getArgument(0));
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> inv.getArgument(0));

        var response = paymentService.payNow(owner, payment.getId(), PaymentMethod.CARD);

        assertThat(response.status()).isEqualTo(PaymentStatus.PAID);
        assertThat(payment.getPolicy().getAmountPaid()).isEqualByComparingTo("89");
        verify(notificationService).notify(eq(owner), any(), any(), any());
    }

    @Test
    void payNowOnAnAlreadyPaidInvoiceIsRejected() {
        User owner = customer(UUID.randomUUID());
        Payment payment = pendingPaymentFor(owner);
        payment.setStatus(PaymentStatus.PAID);
        when(paymentRepository.findById(payment.getId())).thenReturn(Optional.of(payment));

        assertThatThrownBy(() -> paymentService.payNow(owner, payment.getId(), PaymentMethod.CARD))
                .isInstanceOf(BadRequestException.class);
        verify(paymentGateway, never()).charge(any(), any());
    }

    @Test
    void payNowWhenTheGatewayDeclinesMarksFailedAndThrows() {
        User owner = customer(UUID.randomUUID());
        Payment payment = pendingPaymentFor(owner);
        when(paymentRepository.findById(payment.getId())).thenReturn(Optional.of(payment));
        when(paymentGateway.charge(any(), any())).thenReturn(new PaymentGateway.GatewayResult(false, null, "declined"));
        when(paymentRepository.save(any(Payment.class))).thenAnswer(inv -> inv.getArgument(0));

        assertThatThrownBy(() -> paymentService.payNow(owner, payment.getId(), PaymentMethod.CARD))
                .isInstanceOf(BadRequestException.class);
        assertThat(payment.getStatus()).isEqualTo(PaymentStatus.FAILED);
        verify(policyRepository, never()).save(any());
    }

    @Test
    void payNowRejectsSomeoneElsesPayment() {
        User owner = customer(UUID.randomUUID());
        User stranger = customer(UUID.randomUUID());
        Payment payment = pendingPaymentFor(owner);
        when(paymentRepository.findById(payment.getId())).thenReturn(Optional.of(payment));

        assertThatThrownBy(() -> paymentService.payNow(stranger, payment.getId(), PaymentMethod.CARD))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void adminMarkPaidCreditsThePolicyRegardlessOfOwner() {
        User owner = customer(UUID.randomUUID());
        Payment payment = pendingPaymentFor(owner);
        when(paymentRepository.findById(payment.getId())).thenReturn(Optional.of(payment));
        when(paymentRepository.save(any(Payment.class))).thenAnswer(inv -> inv.getArgument(0));
        when(policyRepository.save(any(Policy.class))).thenAnswer(inv -> inv.getArgument(0));

        var response = paymentService.adminMarkPaid(payment.getId(), PaymentMethod.BANK_TRANSFER);

        assertThat(response.status()).isEqualTo(PaymentStatus.PAID);
        assertThat(response.method()).isEqualTo(PaymentMethod.BANK_TRANSFER);
        assertThat(payment.getPolicy().getAmountPaid()).isEqualByComparingTo("89");
    }
}
