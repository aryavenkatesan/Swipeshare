import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentOption {
  final String name;
  final IconData icon;

  const PaymentOption(this.name, this.icon);

  static const List<PaymentOption> allPaymentOptions = [
    PaymentOption('Cash', Icons.attach_money),
    PaymentOption('Venmo', Icons.payment),
    PaymentOption('Zelle', Icons.account_balance),
    PaymentOption('Apple Pay', Icons.apple),
    PaymentOption('PayPal', Icons.paypal),
    PaymentOption('CashApp', Icons.money),
  ];

  static IconData? getIcon(String paymentType) {
    try {
      return allPaymentOptions
          .firstWhere((option) => option.name == paymentType)
          .icon;
    } catch (e) {
      return null;
    }
  }

  static List<String> get allPaymentTypeNames =>
      allPaymentOptions.map((option) => option.name).toList();
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String> paymentTypes;
  final double stars;
  final int transactionsCompleted;
  final String referralEmail;
  final List<String> blockedUsers;
  final bool isEmailVerified;
  final String? verificationCode;
  final DateTime? verificationCodeExpires;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.paymentTypes,
    required this.stars,
    required this.transactionsCompleted,
    required this.referralEmail,
    required this.blockedUsers,
    required this.isEmailVerified,
    this.verificationCode,
    this.verificationCodeExpires,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      paymentTypes: List<String>.from(data['payment_types'] ?? []),
      stars: (data['stars'] ?? 5).toDouble(),
      transactionsCompleted: data['transactions_completed'] ?? 0,
      referralEmail: data['referral_email'] ?? '',
      blockedUsers: List<String>.from(data['blocked_users'] ?? []),
      isEmailVerified: data['isEmailVerified'] ?? false,
      verificationCode: data['verificationCode'] as String?,
      verificationCodeExpires: data['verificationCodeExpires'] != null
          ? (data['verificationCodeExpires'] as Timestamp).toDate()
          : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception('User document (id: ${doc.id}) does not exist or has no data');
    }
    return UserModel.fromMap(doc.id, docData);
  }
}
