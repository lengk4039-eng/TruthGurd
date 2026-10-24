class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final bool kycVerified;
  final DateTime memberSince;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.kycVerified = false,
    required this.memberSince,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      kycVerified: json['kycVerified'] as bool? ?? false,
      memberSince: DateTime.parse(json['memberSince'] as String),
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
