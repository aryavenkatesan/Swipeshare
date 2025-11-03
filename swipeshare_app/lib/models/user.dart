class UserModel {
  final String email;
  final String name;
  final List<String> paymentTypes;
  final double stars;
  final int transactionsCompleted;
  final String referralEmail;
  final List<String> blockedUsers;

  UserModel({
    required this.email,
    required this.name,
    required this.paymentTypes,
    required this.stars,
    required this.transactionsCompleted,
    required this.referralEmail,
    required this.blockedUsers,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      paymentTypes: List<String>.from(data['payment_types'] ?? []),
      stars: (data['stars'] ?? 5).toDouble(),
      transactionsCompleted: data['transactions_completed'] ?? 0,
      referralEmail: data['refferal_email'] ?? '',
      blockedUsers: List<String>.from(data['blocked_users'] ?? []),
    );
  }
}
