class UserModel {
  final String uid;
  final String email;
  final String name;
  final List<String> paymentTypes;
  final double stars;
  final int transactionsCompleted;
  final String referralEmail;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.paymentTypes,
    required this.stars,
    required this.transactionsCompleted,
    required this.referralEmail,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      paymentTypes: List<String>.from(data['payment_types'] ?? []),
      stars: (data['stars'] ?? 5).toDouble(),
      transactionsCompleted: data['transactions_completed'] ?? 0,
      referralEmail: data['refferal_email'] ?? '',
    );
  }
}
