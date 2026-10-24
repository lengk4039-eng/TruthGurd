package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.Claim;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ClaimRepository extends JpaRepository<Claim, UUID> {
    List<Claim> findByUserOrderBySubmittedAtDesc(User user);
    List<Claim> findByPolicyOrderBySubmittedAtDesc(Policy policy);
    List<Claim> findAllByOrderBySubmittedAtDesc();
    long countByClaimNumberStartingWith(String prefix);
}
