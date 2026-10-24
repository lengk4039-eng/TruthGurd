import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../models/claim.dart';
import '../models/claim_eligibility.dart';
import '../models/insurance_category.dart';
import '../models/insurance_package.dart';
import '../models/payment.dart';
import '../models/policy.dart';
import '../models/quotation.dart';
import 'repository_providers.dart';

// Read-only data providers backed by the repositories. After a mutation
// (purchase, pay-now, link-policy) screens call `ref.invalidate(...)` on
// whichever of these it affects so the rest of the app refetches.

final myPoliciesProvider = FutureProvider<List<Policy>>((ref) {
  return ref.watch(policiesRepositoryProvider).getMyPolicies();
});

final policyDetailProvider = FutureProvider.family<Policy, String>((ref, id) {
  return ref.watch(policiesRepositoryProvider).getPolicyById(id);
});

final featuredPackagesProvider = FutureProvider<List<InsurancePackage>>((ref) {
  return ref.watch(packagesRepositoryProvider).getFeatured();
});

final packagesListProvider = FutureProvider.family<List<InsurancePackage>, InsuranceCategoryType?>((ref, category) {
  return ref.watch(packagesRepositoryProvider).getPackages(category: category);
});

final packageDetailProvider = FutureProvider.family<InsurancePackage, String>((ref, id) {
  return ref.watch(packagesRepositoryProvider).getPackageById(id);
});

final myPaymentsProvider = FutureProvider<List<Payment>>((ref) {
  return ref.watch(paymentsRepositoryProvider).getMyPayments();
});

final paymentsForPolicyProvider = FutureProvider.family<List<Payment>, String>((ref, policyId) {
  return ref.watch(paymentsRepositoryProvider).getPaymentsForPolicy(policyId);
});

final paymentDetailProvider = FutureProvider.family<Payment, String>((ref, id) {
  return ref.watch(paymentsRepositoryProvider).getPaymentById(id);
});

final myNotificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});

final myQuotationsProvider = FutureProvider<List<Quotation>>((ref) {
  return ref.watch(quotationsRepositoryProvider).getMyQuotations();
});

final quotationDetailProvider = FutureProvider.family<Quotation, String>((ref, id) {
  return ref.watch(quotationsRepositoryProvider).getQuotationById(id);
});

final myClaimsProvider = FutureProvider<List<Claim>>((ref) {
  return ref.watch(claimsRepositoryProvider).getMyClaims();
});

final claimDetailProvider = FutureProvider.family<Claim, String>((ref, id) {
  return ref.watch(claimsRepositoryProvider).getClaimById(id);
});

final claimsForPolicyProvider = FutureProvider.family<List<Claim>, String>((ref, policyId) {
  return ref.watch(claimsRepositoryProvider).getClaimsForPolicy(policyId);
});

final claimEligibilityProvider = FutureProvider.family<ClaimEligibility, String>((ref, policyId) {
  return ref.watch(claimsRepositoryProvider).getEligibility(policyId);
});

/// Invalidates every provider whose data changes after a purchase or payment.
void invalidateAfterMutation(WidgetRef ref) {
  ref.invalidate(myPoliciesProvider);
  ref.invalidate(myPaymentsProvider);
  ref.invalidate(myNotificationsProvider);
  ref.invalidate(myQuotationsProvider);
  ref.invalidate(myClaimsProvider);
}
