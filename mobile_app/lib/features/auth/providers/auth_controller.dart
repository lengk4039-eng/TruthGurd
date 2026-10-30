import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/policy.dart';
import '../../../core/models/policy_verification.dart';
import '../../../core/providers/repository_providers.dart';

/// Holds the signed-in user (or null when signed out). Screens call the
/// methods below and handle their own submit/loading/error UI locally —
/// this only tracks session state so [AppRouter]'s redirect logic can gate
/// authenticated routes.
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<void> login({required String email, required String password}) async {
    final user = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    state = user;
  }

  /// Pre-account check of a policy number + date of birth. Deliberately does
  /// not touch [state]: nobody is signed in yet.
  Future<PolicyVerification> verifyPolicy({
    required String policyNumber,
    required String dateOfBirth,
  }) {
    return ref
        .read(authRepositoryProvider)
        .verifyPolicy(policyNumber: policyNumber, dateOfBirth: dateOfBirth);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required String password,
    bool hasExistingPolicy = false,
    String? policyVerificationToken,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .register(
          fullName: fullName,
          email: email,
          phone: phone,
          dateOfBirth: dateOfBirth,
          password: password,
          hasExistingPolicy: hasExistingPolicy,
          policyVerificationToken: policyVerificationToken,
        );
    state = user;
  }

  Future<Policy> linkExistingPolicy({
    required String policyNumber,
    required String dateOfBirth,
  }) {
    return ref
        .read(authRepositoryProvider)
        .linkExistingPolicy(
          policyNumber: policyNumber,
          dateOfBirth: dateOfBirth,
        );
  }

  /// Called once from the splash screen: restores a previously-signed-in
  /// session (if any) before the router decides where to send the user.
  Future<void> restoreSession() async {
    final user = await ref.read(authRepositoryProvider).restoreSession();
    if (user != null) state = user;
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String nationalIdNumber,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .updateProfile(
          fullName: fullName,
          email: email,
          phone: phone,
          nationalIdNumber: nationalIdNumber,
        );
    state = user;
  }

  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .uploadAvatar(bytes: bytes, filename: filename);
    state = user;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}

final authStateProvider = NotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

/// The account-only screen a guest was aiming at when a sign-in prompt
/// interrupted them, so login/signup can drop them back there instead of
/// dumping them on Home.
class PendingAuthRoute extends Notifier<String?> {
  @override
  String? build() => null;

  void save(String route) => state = route;

  String? take() {
    final route = state;
    state = null;
    return route;
  }
}

final pendingAuthRouteProvider = NotifierProvider<PendingAuthRoute, String?>(
  PendingAuthRoute.new,
);
