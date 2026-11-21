class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.initials,
    required this.email,
    required this.phone,
    required this.city,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String initials;
  final String email;
  final String phone;
  final String city;

  String get fullName => '$firstName $lastName';
}
