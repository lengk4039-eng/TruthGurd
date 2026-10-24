package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.UpdateUserRequest;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public UserResponse updateMe(User user, UpdateUserRequest request) {
        if (!request.email().equalsIgnoreCase(user.getEmail()) && userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new BadRequestException("An account with this email already exists.");
        }
        user.setFullName(request.fullName());
        user.setEmail(request.email().toLowerCase());
        user.setPhone(request.phone());
        return UserResponse.from(userRepository.save(user));
    }

    public List<UserResponse> adminList() {
        return userRepository.findAll().stream().map(UserResponse::from).toList();
    }
}
