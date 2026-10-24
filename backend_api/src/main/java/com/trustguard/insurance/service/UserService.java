package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.UpdateUserRequest;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final AvatarStorageService avatarStorageService;

    @Transactional
    public UserResponse updateMe(User user, UpdateUserRequest request) {
        if (!request.email().equalsIgnoreCase(user.getEmail()) && userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new BadRequestException("An account with this email already exists.");
        }
        user.setFullName(request.fullName().trim());
        user.setEmail(request.email().trim().toLowerCase(Locale.ROOT));
        user.setPhone(request.phone().trim());
        user.setNationalIdNumber(request.nationalIdNumber().trim().toUpperCase(Locale.ROOT));
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public UserResponse uploadAvatar(User user, MultipartFile file) {
        String previous = user.getAvatarUrl();
        user.setAvatarUrl(avatarStorageService.store(user.getId(), file));
        User saved = userRepository.save(user);
        avatarStorageService.delete(previous);
        return UserResponse.from(saved);
    }

    public List<UserResponse> adminList() {
        return userRepository.findAll().stream().map(UserResponse::from).toList();
    }
}
