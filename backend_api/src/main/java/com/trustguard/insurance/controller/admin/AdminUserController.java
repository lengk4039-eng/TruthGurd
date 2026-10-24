package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@Tag(name = "Admin · Users")
public class AdminUserController {

    private final UserService userService;

    @GetMapping
    public List<UserResponse> list() {
        return userService.adminList();
    }
}
