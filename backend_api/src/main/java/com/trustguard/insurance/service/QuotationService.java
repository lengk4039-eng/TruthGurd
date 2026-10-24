package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.CreateQuotationRequest;
import com.trustguard.insurance.dto.QuotationResponse;
import com.trustguard.insurance.dto.admin.RejectQuotationRequest;
import com.trustguard.insurance.dto.admin.RespondQuotationRequest;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.entity.NotificationType;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.Quotation;
import com.trustguard.insurance.entity.QuotationStatus;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PolicyRepository;
import com.trustguard.insurance.repository.QuotationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class QuotationService {

    private final QuotationRepository quotationRepository;
    private final PackageService packageService;
    private final PolicyRepository policyRepository;
    private final NotificationService notificationService;

    public List<QuotationResponse> getMyQuotations(User user) {
        expireStaleQuotes(quotationRepository.findByUserOrderByCreatedAtDesc(user));
        return quotationRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(QuotationResponse::from)
                .toList();
    }

    public QuotationResponse getById(User user, UUID id) {
        return QuotationResponse.from(findOwned(user, id));
    }

    Quotation findOwned(User user, UUID id) {
        Quotation quotation = quotationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Quotation not found."));
        if (!quotation.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Quotation not found.");
        }
        expireIfNeeded(quotation);
        return quotation;
    }

    Quotation findEntity(UUID id) {
        Quotation quotation = quotationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Quotation not found."));
        expireIfNeeded(quotation);
        return quotation;
    }

    @Transactional
    public QuotationResponse request(User user, CreateQuotationRequest request) {
        InsurancePackage pkg = packageService.findEntity(UUID.fromString(request.packageId()));
        Quotation quotation = Quotation.builder()
                .user(user)
                .insurancePackage(pkg)
                .preferredPlanMonths(request.preferredPlanMonths())
                .notes(request.notes() == null ? "" : request.notes().trim())
                .status(QuotationStatus.PENDING)
                .build();
        quotation = quotationRepository.save(quotation);
        notificationService.notify(user, NotificationType.SYSTEM,
                "Quotation submitted",
                "We received your request for " + pkg.getName() + ". Our team will respond shortly.");
        return QuotationResponse.from(quotation);
    }

    @Transactional
    public QuotationResponse decline(User user, UUID id) {
        Quotation quotation = findOwned(user, id);
        if (quotation.getStatus() != QuotationStatus.PENDING && quotation.getStatus() != QuotationStatus.QUOTED) {
            throw new BadRequestException("This quotation can no longer be declined.");
        }
        quotation.setStatus(QuotationStatus.REJECTED);
        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    @Transactional
    public QuotationResponse markAccepted(User user, UUID quotationId, UUID policyId) {
        Quotation quotation = findOwned(user, quotationId);
        Policy policy = policyRepository.findById(policyId)
                .orElseThrow(() -> new ResourceNotFoundException("Policy not found."));
        if (policy.getUser() == null || !policy.getUser().getId().equals(user.getId())) {
            throw new BadRequestException("Policy does not belong to the current user.");
        }
        // Idempotent when purchase already linked this quotation
        if (quotation.getStatus() == QuotationStatus.ACCEPTED
                && quotation.getPolicy() != null
                && quotation.getPolicy().getId().equals(policyId)) {
            return QuotationResponse.from(quotation);
        }
        if (!quotation.canAccept()) {
            throw new BadRequestException("This quotation cannot be accepted. It may have expired.");
        }
        quotation.setStatus(QuotationStatus.ACCEPTED);
        quotation.setPolicy(policy);
        quotation = quotationRepository.save(quotation);
        notificationService.notify(user, NotificationType.POLICY,
                "Quote accepted",
                "Your " + quotation.getInsurancePackage().getName() + " quotation is now an active policy.");
        return QuotationResponse.from(quotation);
    }

    /** Used internally when purchase includes a quotationId. */
    @Transactional
    public void linkPolicyOnPurchase(User user, UUID quotationId, Policy policy) {
        Quotation quotation = findOwned(user, quotationId);
        if (!quotation.canAccept()) {
            throw new BadRequestException("This quotation cannot be accepted. It may have expired.");
        }
        quotation.setStatus(QuotationStatus.ACCEPTED);
        quotation.setPolicy(policy);
        quotationRepository.save(quotation);
        notificationService.notify(user, NotificationType.POLICY,
                "Quote accepted",
                "Your " + quotation.getInsurancePackage().getName() + " quotation is now an active policy.");
    }

    public List<QuotationResponse> adminList() {
        List<Quotation> all = quotationRepository.findAllByOrderByCreatedAtDesc();
        expireStaleQuotes(all);
        return quotationRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(QuotationResponse::from)
                .toList();
    }

    @Transactional
    public QuotationResponse adminRespond(UUID id, RespondQuotationRequest request) {
        Quotation quotation = findEntity(id);
        if (quotation.getStatus() != QuotationStatus.PENDING && quotation.getStatus() != QuotationStatus.QUOTED) {
            throw new BadRequestException("Only pending or quoted requests can receive a new price.");
        }
        LocalDate validUntil = request.validUntil() != null
                ? request.validUntil()
                : LocalDate.now().plusDays(14);
        quotation.setQuotedPremium(request.quotedPremium());
        quotation.setValidUntil(validUntil);
        quotation.setSalesNotes(request.salesNotes());
        quotation.setStatus(QuotationStatus.QUOTED);
        quotation = quotationRepository.save(quotation);
        notificationService.notify(quotation.getUser(), NotificationType.SYSTEM,
                "Your quote is ready",
                "Sales priced " + quotation.getInsurancePackage().getName()
                        + " at " + request.quotedPremium() + ". Valid until " + validUntil + ".");
        return QuotationResponse.from(quotation);
    }

    @Transactional
    public QuotationResponse adminReject(UUID id, RejectQuotationRequest request) {
        Quotation quotation = findEntity(id);
        if (quotation.getStatus() == QuotationStatus.ACCEPTED) {
            throw new BadRequestException("An accepted quotation cannot be rejected.");
        }
        quotation.setStatus(QuotationStatus.REJECTED);
        if (request != null && request.salesNotes() != null) {
            quotation.setSalesNotes(request.salesNotes());
        }
        quotation = quotationRepository.save(quotation);
        notificationService.notify(quotation.getUser(), NotificationType.SYSTEM,
                "Quotation update",
                "Your request for " + quotation.getInsurancePackage().getName() + " was declined.");
        return QuotationResponse.from(quotation);
    }

    private void expireStaleQuotes(List<Quotation> quotations) {
        for (Quotation q : quotations) {
            expireIfNeeded(q);
        }
    }

    private void expireIfNeeded(Quotation quotation) {
        if (quotation.getStatus() == QuotationStatus.QUOTED
                && quotation.getValidUntil() != null
                && quotation.getValidUntil().isBefore(LocalDate.now())) {
            quotation.setStatus(QuotationStatus.EXPIRED);
            quotationRepository.save(quotation);
        }
    }
}
