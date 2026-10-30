/// Proof that a policy number + date of birth matched an unclaimed policy.
/// Minted before an account exists and spent on the register request.
class PolicyVerification {
  const PolicyVerification({
    required this.verificationToken,
    required this.policyNumber,
    required this.packageName,
  });

  final String verificationToken;
  final String policyNumber;
  final String packageName;

  factory PolicyVerification.fromJson(Map<String, dynamic> json) =>
      PolicyVerification(
        verificationToken: json['verificationToken'] as String,
        policyNumber: json['policyNumber'] as String,
        packageName: json['packageName'] as String,
      );
}
