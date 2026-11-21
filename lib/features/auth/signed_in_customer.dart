class SignedInCustomer {
  const SignedInCustomer({
    required this.accessToken,
    required this.username,
    required this.fullName,
    required this.expiresAt,
    this.customerId,
  });

  final String accessToken;
  final String username;
  final String fullName;
  final DateTime expiresAt;
  final int? customerId;
}
