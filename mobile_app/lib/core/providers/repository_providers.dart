import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/claims_repository.dart';
import '../../data/repositories/dio_auth_repository.dart';
import '../../data/repositories/dio_claims_repository.dart';
import '../../data/repositories/dio_notifications_repository.dart';
import '../../data/repositories/dio_packages_repository.dart';
import '../../data/repositories/dio_payments_repository.dart';
import '../../data/repositories/dio_policies_repository.dart';
import '../../data/repositories/dio_quotations_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/packages_repository.dart';
import '../../data/repositories/payments_repository.dart';
import '../../data/repositories/policies_repository.dart';
import '../../data/repositories/quotations_repository.dart';

/// Set to `true` to fall back to in-memory mock data (e.g. for widget tests,
/// or running the UI with no backend available) instead of the real
/// Spring Boot API at [ApiConfig.baseUrl].
const bool useMockData = false;

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => useMockData ? MockAuthRepository() : DioAuthRepository(),
);
final packagesRepositoryProvider = Provider<PackagesRepository>(
  (ref) => useMockData ? MockPackagesRepository() : DioPackagesRepository(),
);
final policiesRepositoryProvider = Provider<PoliciesRepository>(
  (ref) => useMockData ? MockPoliciesRepository() : DioPoliciesRepository(),
);
final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => useMockData ? MockPaymentsRepository() : DioPaymentsRepository(),
);
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => useMockData
      ? MockNotificationsRepository()
      : DioNotificationsRepository(),
);
final quotationsRepositoryProvider = Provider<QuotationsRepository>(
  (ref) => useMockData ? MockQuotationsRepository() : DioQuotationsRepository(),
);
final claimsRepositoryProvider = Provider<ClaimsRepository>(
  (ref) => useMockData ? MockClaimsRepository() : DioClaimsRepository(),
);
