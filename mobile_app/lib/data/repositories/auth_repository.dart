import 'dart:typed_data';

import '../../core/errors/app_exception.dart';
import '../../core/models/app_user.dart';
import '../../core/models/policy.dart';
import '../../core/models/policy_verification.dart';
import '../../core/utils/minimum_age.dart';
import '../mock_data.dart';

abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String password,
    bool hasExistingPolicy = false,
    String? policyVerificationToken,
  });

  /// Confirms a policy number + date of birth belong to a policy nobody has
  /// claimed, before any account exists. The returned token must be spent on
  /// [register] for the verification to mean anything.
  Future<PolicyVerification> verifyPolicy({
    required String policyNumber,
    required String dateOfBirth,
  });

  /// Verifies an offline/agent-sold policy by number + date of birth and
  /// attaches it to the signed-in account so it shows up in My Policies.
  Future<Policy> linkExistingPolicy({
    required String policyNumber,
    required String dateOfBirth,
  });

  /// Fetches the profile for a previously-stored session token, or `null`
  /// if there isn't one — used to restore login state on app start.
  Future<AppUser?> restoreSession();

  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String nationalIdNumber,
  });

  Future<AppUser> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  });

  Future<void> logout();
}

/// In-memory stand-in for the real `/api/v1/auth/*` endpoints. Any
/// non-empty credentials "succeed" so the flow is demoable end to end;
/// only [linkExistingPolicy] validates against fixed demo data, since that
/// screen's whole point is showing a failed vs. successful match.
class MockAuthRepository implements AuthRepository {
  static const _mockVerificationToken = 'mock-policy-verification';

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AppException('Enter your email and password to continue.');
    }
    return MockData.currentUser;
  }

  @override
  Future<PolicyVerification> verifyPolicy({
    required String policyNumber,
    required String dateOfBirth,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final matches =
        policyNumber.trim().toUpperCase() ==
            MockData.demoUnclaimedPolicyNumber &&
        dateOfBirth.trim() == MockData.demoUnclaimedDob;
    if (!matches) {
      throw const AppException(
        "We couldn't find a policy with that number and date of birth. Double-check with your agent and try again.",
      );
    }
    return const PolicyVerification(
      verificationToken: _mockVerificationToken,
      policyNumber: MockData.demoUnclaimedPolicyNumber,
      packageName: 'HomeSafe Renters',
    );
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String password,
    bool hasExistingPolicy = false,
    String? policyVerificationToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.length < 6) {
      throw const AppException(
        'Please fill every field — passwords need at least 6 characters.',
      );
    }
    if (!meetsMinimumAge(dateOfBirth)) {
      throw const AppException(
        'You must be at least 18 years old to create an account.',
      );
    }
    if (hasExistingPolicy &&
        policyVerificationToken != _mockVerificationToken) {
      throw const AppException(
        'Verify your policy number before creating an account.',
      );
    }
    return MockData.currentUser;
  }

  @override
  Future<Policy> linkExistingPolicy({
    required String policyNumber,
    required String dateOfBirth,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final normalizedNumber = policyNumber.trim().toUpperCase();
    final matches =
        normalizedNumber == MockData.demoUnclaimedPolicyNumber &&
        dateOfBirth.trim() == MockData.demoUnclaimedDob;
    if (!matches) {
      throw const AppException(
        "We couldn't find a policy with that number and date of birth. Double-check with your agent and try again.",
      );
    }
    final already = MockData.policies.where(
      (p) => p.policyNumber == normalizedNumber,
    );
    if (already.isNotEmpty) return already.first;

    final linked = Policy(
      id: 'pol_linked_${MockData.policies.length + 1}',
      policyNumber: normalizedNumber,
      package: MockData.packageById('pkg_home_owners'),
      status: PolicyStatus.active,
      source: PolicySource.linkedExisting,
      startDate: DateTime.now().subtract(const Duration(days: 180)),
      endDate: DateTime.now().add(const Duration(days: 185)),
      totalPremium: 55 * 12,
      amountPaid: 55 * 6,
      nextPaymentDate: DateTime.now().add(const Duration(days: 8)),
      nextPaymentAmount: 55,
    );
    MockData.policies.add(linked);
    return linked;
  }

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String nationalIdNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AppUser(
      id: MockData.currentUser.id,
      fullName: fullName,
      email: email,
      phone: phone,
      avatarUrl: MockData.currentUser.avatarUrl,
      nationalIdNumber: nationalIdNumber,
      kycVerified: MockData.currentUser.kycVerified,
      memberSince: MockData.currentUser.memberSince,
    );
  }

  @override
  Future<AppUser> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
