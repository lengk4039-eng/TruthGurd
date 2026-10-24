package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.ClaimEligibilityResponse;
import com.trustguard.insurance.dto.ClaimResponse;
import com.trustguard.insurance.dto.CreateClaimRequest;
import com.trustguard.insurance.dto.admin.UpdateClaimStatusRequest;
import com.trustguard.insurance.entity.Claim;
import com.trustguard.insurance.entity.ClaimStatus;
import com.trustguard.insurance.entity.ClaimType;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.NotificationType;
import com.trustguard.insurance.entity.Payment;
import com.trustguard.insurance.entity.PaymentStatus;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.ClaimRepository;
import com.trustguard.insurance.repository.PaymentRepository;
import com.trustguard.insurance.repository.PolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ClaimService {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH);

    private final ClaimRepository claimRepository;
    private final PolicyRepository policyRepository;
    private final PaymentRepository paymentRepository;
    private final NotificationService notificationService;

    public List<ClaimResponse> getMyClaims(User user) {
        return claimRepository.findByUserOrderBySubmittedAtDesc(user).stream()
                .map(ClaimResponse::from)
                .toList();
    }

    public ClaimResponse getById(User user, UUID id) {
        Claim claim = claimRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Claim not found."));
        if (claim.getUser() == null || !claim.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Claim not found.");
        }
        return ClaimResponse.from(claim);
    }

    public List<ClaimResponse> getForPolicy(User user, UUID policyId) {
        Policy policy = requireOwnedPolicy(user, policyId);
        return claimRepository.findByPolicyOrderBySubmittedAtDesc(policy).stream()
                .map(ClaimResponse::from)
                .toList();
    }

    public ClaimEligibilityResponse eligibility(User user, UUID policyId) {
        return evaluate(requireOwnedPolicy(user, policyId));
    }

    @Transactional
    public ClaimResponse submit(User user, CreateClaimRequest request) {
        Policy policy = requireOwnedPolicy(user, request.policyId());
        InsurancePackage pkg = policy.getInsurancePackage();
        LocalDate today = LocalDate.now();
        LocalDate waitingEndsAt = policy.getStartDate().plusDays(pkg.getWaitingPeriodDays());
        boolean withinWaiting = today.isBefore(waitingEndsAt);

        ClaimEligibilityResponse eligibility = evaluate(policy);
        if (!eligibility.eligible()) {
            throw new BadRequestException(eligibility.message());
        }
        if (withinWaiting && request.type() != ClaimType.ACCIDENT) {
            throw new BadRequestException(
                    "Your policy is in its waiting period until " + DATE.format(waitingEndsAt)
                            + ". Only accident claims can be filed before then. Other claim types unlock on that date.");
        }
        if (request.incidentDate().isAfter(today)) {
            throw new BadRequestException("Incident date cannot be in the future.");
        }
        if (request.incidentDate().isBefore(policy.getStartDate())) {
            throw new BadRequestException(
                    "The incident date is before this policy's cover start date ("
                            + DATE.format(policy.getStartDate()) + ").");
        }
        LocalDate earliestDate = today.minusDays(pkg.getClaimWindowDays());
        if (request.incidentDate().isBefore(earliestDate)) {
            throw new BadRequestException(
                    "Claims must be filed within " + pkg.getClaimWindowDays()
                            + " days of the incident. The latest date to file for this incident was "
                            + DATE.format(earliestDate.plusDays(pkg.getClaimWindowDays())) + ".");
        }

        String year = String.valueOf(Year.now().getValue());
        long seq = claimRepository.countByClaimNumberStartingWith("CLM-" + year + "-") + 1;
        String claimNumber = "CLM-" + year + "-" + String.format("%04d", seq);

        Claim claim = Claim.builder()
                .claimNumber(claimNumber)
                .user(user)
                .policy(policy)
                .type(request.type())
                .status(ClaimStatus.SUBMITTED)
                .description(request.description().trim())
                .amount(request.amount())
                .incidentDate(request.incidentDate())
                .photoUrl(request.photoUrl())
                .build();
        claim = claimRepository.save(claim);

        String body = "We received claim " + claimNumber + " for " + pkg.getName()
                + ". Next: our claims team reviews it within 2-3 business days and notifies you here. "
                + "If we need documents, the request will appear in this claim's timeline.";
        notificationService.notify(user, NotificationType.POLICY, "Claim submitted", body);

        return ClaimResponse.from(claim);
    }

    public List<ClaimResponse> adminList() {
        return claimRepository.findAllByOrderBySubmittedAtDesc().stream()
                .map(ClaimResponse::from)
                .toList();
    }

    @Transactional
    public ClaimResponse adminUpdateStatus(UUID id, UpdateClaimStatusRequest request) {
        Claim claim = claimRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Claim not found."));

        boolean hasNotes = request.reviewNotes() != null && !request.reviewNotes().isBlank();
        if (request.status() == ClaimStatus.REJECTED && !hasNotes) {
            throw new BadRequestException(
                    "Add a review note explaining the decision so the customer knows why the claim was rejected.");
        }

        claim.setStatus(request.status());
        if (request.reviewNotes() != null) {
            claim.setReviewNotes(request.reviewNotes().trim());
        }
        Instant now = Instant.now();
        claim.setReviewedAt(now);
        claim.setUpdatedAt(now);
        claim = claimRepository.save(claim);

        String statusLabel = switch (request.status()) {
            case SUBMITTED -> "Submitted";
            case UNDER_REVIEW -> "Under review";
            case APPROVED -> "Approved";
            case REJECTED -> "Rejected";
        };
        String nextStep = switch (request.status()) {
            case SUBMITTED -> "Next: we will begin the review shortly.";
            case UNDER_REVIEW ->
                    "Next: our claims team is reviewing the file. Most reviews finish within 2-3 business days; we will ask here if any documents are missing.";
            case APPROVED ->
                    "Next: our payments team will confirm your payout details and transfer the approved amount within 5 business days.";
            case REJECTED ->
                    "Next: read the decision note below. If you disagree, you can appeal within 30 days by contacting TrustGuard support and quoting this claim number.";
        };

        String body = "Your claim " + claim.getClaimNumber() + " is now " + statusLabel + "."
                + (hasNotes ? " Decision note: " + request.reviewNotes().trim() : "")
                + " " + nextStep;
        notificationService.notify(claim.getUser(), NotificationType.POLICY,
                "Claim update: " + claim.getClaimNumber(), body);

        return ClaimResponse.from(claim);
    }

    private Policy requireOwnedPolicy(User user, UUID policyId) {
        Policy policy = policyRepository.findById(policyId)
                .orElseThrow(() -> new ResourceNotFoundException("Policy not found."));
        if (policy.getUser() == null || !policy.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Policy not found.");
        }
        return policy;
    }

    private ClaimEligibilityResponse evaluate(Policy policy) {
        InsurancePackage pkg = policy.getInsurancePackage();
        UUID policyId = policy.getId();
        int waitingDays = pkg.getWaitingPeriodDays();
        int windowDays = pkg.getClaimWindowDays();
        LocalDate waitingEndsAt = policy.getStartDate().plusDays(waitingDays);
        boolean withinWaiting = LocalDate.now().isBefore(waitingEndsAt);

        if (policy.getStatus() != PolicyStatus.ACTIVE) {
            return new ClaimEligibilityResponse(
                    policyId.toString(), false, "POLICY_INACTIVE",
                    "Policy is not active",
                    "This policy is " + policy.getStatus().name().toLowerCase()
                            + ". Only active policies can receive new claims. Contact support if you believe this is wrong.",
                    withinWaiting, waitingEndsAt, null, null, null, waitingDays, windowDays);
        }

        LocalDate today = LocalDate.now();
        List<Payment> payments = paymentRepository.findByPolicyOrderByDueDateDesc(policy);
        Payment overdue = payments.stream()
                .filter(payment -> payment.getStatus() != PaymentStatus.PAID)
                .filter(payment -> payment.getStatus() == PaymentStatus.OVERDUE
                        || payment.getDueDate().isBefore(today))
                .max(Comparator.comparing(Payment::getDueDate))
                .orElse(null);
        if (overdue != null) {
            return new ClaimEligibilityResponse(
                    policyId.toString(), false, "PAYMENT_OVERDUE",
                    "Claim filing paused",
                    "An installment of $" + overdue.getAmount().stripTrailingZeros().toPlainString()
                            + " was due on " + DATE.format(overdue.getDueDate())
                            + " and is still unpaid. Your cover is suspended and new claims are blocked until this invoice is paid.",
                    withinWaiting, waitingEndsAt,
                    overdue.getId().toString(), overdue.getAmount(), overdue.getDueDate(),
                    waitingDays, windowDays);
        }

        boolean hasPaid = (policy.getAmountPaid() != null && policy.getAmountPaid().signum() > 0)
                || payments.stream().anyMatch(payment -> payment.getStatus() == PaymentStatus.PAID);
        if (!hasPaid) {
            return new ClaimEligibilityResponse(
                    policyId.toString(), false, "PREMIUM_UNPAID",
                    "First premium required",
                    "We haven't received a premium payment for this policy yet. Claim protection begins after your first installment is paid — open the policy to settle the first invoice.",
                    withinWaiting, waitingEndsAt, null, null, null, waitingDays, windowDays);
        }

        if (withinWaiting) {
            return new ClaimEligibilityResponse(
                    policyId.toString(), true, "WAITING_PERIOD",
                    "Waiting period active",
                    "Cover started on " + DATE.format(policy.getStartDate()) + ". The "
                            + waitingDays + "-day waiting period ends on " + DATE.format(waitingEndsAt)
                            + ". Accident claims can be filed now; other claim types can be filed from that date.",
                    true, waitingEndsAt, null, null, null, waitingDays, windowDays);
        }

        return new ClaimEligibilityResponse(
                policyId.toString(), true, "OK",
                "Claim protection active",
                "Your policy is active and premiums are up to date. File the claim within "
                        + windowDays + " days of the incident and attach the documents listed below.",
                false, waitingEndsAt, null, null, null, waitingDays, windowDays);
    }
}
