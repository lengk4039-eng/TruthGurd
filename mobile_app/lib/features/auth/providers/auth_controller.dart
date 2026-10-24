import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/policy.dart';
import '../../../core/providers/repository_providers.dart';

/// Holds the signed-in user (or null when signed out). Screens call the
/// methods below and handle their own submit/loading/error UI locally —
/// this only tracks session state so [AppRouter]'s redirect logic can gate
/// authenticated routes.
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  Future<void> login({required String email, required String password}) async {
    final user = await ref.read(authRepositoryProvider).login(email: email, password: password);
    state = user;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final user = await ref.read(authRepositoryProvider).register(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
        );
    state = user;
  }

  Future<Policy> linkExistingPolicy({required String policyNumber, required String dateOfBirth}) {
    return ref.read(authRepositoryProvider).linkExistingPolicy(policyNumber: policyNumber, dateOfBirth: dateOfBirth);
  }

  /// Called once from the splash screen: restores a previously-signed-in
  /// session (if any) before the router decides where to send the user.
  Future<void> restoreSession() async {
    final user = await ref.read(authRepositoryProvider).restoreSession();
    if (user != null) state = user;
  }

  void updateProfile({required String fullName, required String email, required String phone}) {
    final current = state;
    if (current == null) return;
    state = AppUser(
      id: current.id,
      fullName: fullName,
      email: email,
      phone: phone,
      kycVerified: current.kycVerified,
      memberSince: current.memberSince,
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}

final authStateProvider = NotifierProvider<AuthController, AppUser?>(AuthController.new);
