package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.UpdateUserRequest;
import com.trustguard.insurance.dto.UserResponse;
import com.trustguard.insurance.dto.admin.AdminCreateUserRequest;
import com.trustguard.insurance.dto.admin.AdminUpdateUserRequest;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.ClaimRepository;
import com.trustguard.insurance.repository.NotificationRepository;
import com.trustguard.insurance.repository.PolicyRepository;
import com.trustguard.insurance.repository.QuotationRepository;
import com.trustguard.insurance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final AvatarStorageService avatarStorageService;
    private final PolicyRepository policyRepository;
    private final QuotationRepository quotationRepository;
    private final ClaimRepository claimRepository;
    private final NotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;

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

    @Transactional
    public UserResponse adminCreate(AdminCreateUserRequest request) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new BadRequestException("An account with this email already exists.");
        }
        User user = User.builder()
                .fullName(request.fullName().trim())
                .email(email)
                .phone(request.phone().trim())
                .passwordHash(passwordEncoder.encode(request.password()))
                .role(request.role())
                .kycVerified(request.kycVerified())
                .build();
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public UserResponse adminUpdate(UUID id, UUID actingUserId, AdminUpdateUserRequest request) {
        User user = findUser(id);
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        userRepository.findByEmailIgnoreCase(email).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new BadRequestException("An account with this email already exists.");
            }
        });
        if (user.getId().equals(actingUserId) && request.role() != Role.ADMIN) {
            throw new BadRequestException("You cannot remove your own administrator role.");
        }
        user.setFullName(request.fullName().trim());
        user.setEmail(email);
        user.setPhone(request.phone().trim());
        user.setRole(request.role());
        user.setKycVerified(request.kycVerified());
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public void adminDelete(UUID id, UUID actingUserId) {
        if (id.equals(actingUserId)) {
            throw new BadRequestException("You cannot delete the account you are signed in with.");
        }
        User user = findUser(id);
        long records = policyRepository.countByUser(user)
                + quotationRepository.countByUser(user)
                + claimRepository.countByUser(user);
        if (records > 0) {
            throw new BadRequestException(
                    "This account has policies, quotations or claims on file and cannot be deleted. Keep the record for audit.");
        }
        notificationRepository.deleteByUser(user);
        userRepository.delete(user);
    }

    private User findUser(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
    }
}
