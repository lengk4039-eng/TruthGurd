package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.NotificationResponse;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.NotificationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/me")
    public List<NotificationResponse> myNotifications(@AuthenticationPrincipal AppUserDetails principal) {
        return notificationService.getMyNotifications(principal.getUser());
    }

    @PostMapping("/{id}/read")
    public NotificationResponse markAsRead(@AuthenticationPrincipal AppUserDetails principal, @PathVariable UUID id) {
        return notificationService.markAsRead(principal.getUser(), id);
    }
}
