package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PolicyRepository extends JpaRepository<Policy, UUID> {
    List<Policy> findByUserOrderByCreatedAtDesc(User user);
    Optional<Policy> findByPolicyNumberIgnoreCase(String policyNumber);
    boolean existsByPolicyNumberIgnoreCase(String policyNumber);
    long countByStatus(PolicyStatus status);
}
