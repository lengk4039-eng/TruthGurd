import '../../core/errors/app_exception.dart';
import '../../core/models/app_notification.dart';
import '../../core/models/claim.dart';
import '../../core/models/claim_eligibility.dart';
import '../../core/models/policy.dart';
import '../mock_data.dart';

abstract class ClaimsRepository {
  Future<List<Claim>> getMyClaims();
  Future<Claim> getClaimById(String id);
  Future<List<Claim>> getClaimsForPolicy(String policyId);
  Future<ClaimEligibility> getEligibility(String policyId);
  Future<Claim> submitClaim({
    required String policyId,
    required ClaimType type,
    required String description,
    required double amount,
    required DateTime incidentDate,
  });
}

class MockClaimsRepository implements ClaimsRepository {
  @override
  Future<List<Claim>> getMyClaims() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sorted = [...MockData.claims]
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return sorted;
  }

  @override
  Future<Claim> getClaimById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.claimById(id);
  }

  @override
  Future<List<Claim>> getClaimsForPolicy(String policyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.claims.where((c) => c.policyId == policyId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  @override
  Future<ClaimEligibility> getEligibility(String policyId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final policy = MockData.policyById(policyId);
    final waitingEndsAt = policy.startDate.add(
      Duration(days: policy.package.waitingPeriodDays),
    );
    final withinWaiting = DateTime.now().isBefore(waitingEndsAt);
    if (policy.status != PolicyStatus.active) {
      return ClaimEligibility(
        policyId: policyId,
        eligible: false,
        code: 'POLICY_INACTIVE',
        title: 'Policy is not active',
        message: 'Only active policies can receive new claims.',
        withinWaitingPeriod: withinWaiting,
        waitingPeriodEndsAt: waitingEndsAt,
        waitingPeriodDays: policy.package.waitingPeriodDays,
        claimWindowDays: policy.package.claimWindowDays,
      );
    }
    if (policy.amountPaid <= 0) {
      return ClaimEligibility(
        policyId: policyId,
        eligible: false,
        code: 'PREMIUM_UNPAID',
        title: 'First premium required',
        message:
            'Claim protection begins after your first installment is paid.',
        withinWaitingPeriod: withinWaiting,
        waitingPeriodEndsAt: waitingEndsAt,
        waitingPeriodDays: policy.package.waitingPeriodDays,
        claimWindowDays: policy.package.claimWindowDays,
      );
    }
    return ClaimEligibility(
      policyId: policyId,
      eligible: true,
      code: withinWaiting ? 'WAITING_PERIOD' : 'OK',
      title: withinWaiting
          ? 'Waiting period active'
          : 'Claim protection active',
      message: withinWaiting
          ? 'Accident claims can be filed now. Other claim types unlock when the waiting period ends.'
          : 'Your policy is active and premiums are up to date.',
      withinWaitingPeriod: withinWaiting,
      waitingPeriodEndsAt: waitingEndsAt,
      waitingPeriodDays: policy.package.waitingPeriodDays,
      claimWindowDays: policy.package.claimWindowDays,
    );
  }

  @override
  Future<Claim> submitClaim({
    required String policyId,
    required ClaimType type,
    required String description,
    required double amount,
    required DateTime incidentDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final policy = MockData.policyById(policyId);
    if (policy.status.name == 'expired' || policy.status.name == 'cancelled') {
      throw const AppException('You can only file claims on active policies.');
    }
    final now = DateTime.now();
    final claim = Claim(
      id: 'clm_${MockData.claims.length + 1}_${now.millisecondsSinceEpoch}',
      claimNumber:
          'CLM-${now.year}-${(1000 + MockData.claims.length).toString().padLeft(4, '0')}',
      policyId: policyId,
      policyName: policy.package.name,
      type: type,
      status: ClaimStatus.submitted,
      description: description.trim(),
      amount: amount,
      incidentDate: incidentDate,
      submittedAt: now,
    );
    MockData.claims.insert(0, claim);
    MockData.notifications.insert(
      0,
      AppNotification(
        id: 'n_claim_${claim.id}',
        type: NotificationType.policy,
        title: 'Claim submitted',
        body:
            'We received claim ${claim.claimNumber} for ${policy.package.name}. Status: Submitted.',
        createdAt: now,
      ),
    );
    return claim;
  }
}
