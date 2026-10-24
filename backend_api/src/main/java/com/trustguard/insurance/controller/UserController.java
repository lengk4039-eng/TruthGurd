package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.UpdateUserRequest;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.security.AppUserDetails;
import com.trustguard.insurance.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/users/me")
@RequiredArgsConstructor
@Tag(name = "Users")
public class UserController {

    private final UserService userService;

    @GetMapping
    public UserResponse me(@AuthenticationPrincipal AppUserDetails principal) {
        return UserResponse.from(principal.getUser());
    }

    @PutMapping
    public UserResponse updateMe(@AuthenticationPrincipal AppUserDetails principal, @Valid @RequestBody UpdateUserRequest request) {
        return userService.updateMe(principal.getUser(), request);
    }

    @PostMapping(value = "/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public UserResponse uploadAvatar(@AuthenticationPrincipal AppUserDetails principal, @RequestPart("file") MultipartFile file) {
        return userService.uploadAvatar(principal.getUser(), file);
    }
}
