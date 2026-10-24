package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.Notification;
import com.trustguard.insurance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUserOrderByCreatedAtDesc(User user);
}
