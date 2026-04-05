import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserStatus { active, deleted, banned }

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
  final UserStatus status;
  final double moneySaved;
  final double moneyEarned;
  final NotifSettings notifSettings;
  final bool hasSeenAppFeedback;
  final bool hasRequestedStoreReview;

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
    this.status = UserStatus.active,
    this.moneySaved = 0,
    this.moneyEarned = 0,
    this.notifSettings = const NotifSettings(),
    this.hasSeenAppFeedback = false,
    this.hasRequestedStoreReview = false,
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
      status: data['status'] != null
          ? UserStatus.values.byName(data['status'])
          : UserStatus.active,
      moneySaved: (data['moneySaved'] ?? 0).toDouble(),
      moneyEarned: (data['moneyEarned'] ?? 0).toDouble(),
      notifSettings: data['notifSettings'] != null
          ? NotifSettings.fromMap(data['notifSettings'])
          : const NotifSettings(),
      hasSeenAppFeedback: data['hasSeenAppFeedback'] ?? false,
      hasRequestedStoreReview: data['hasRequestedStoreReview'] ?? false,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception(
        'User document (id: ${doc.id}) does not exist or has no data',
      );
    }
    return UserModel.fromMap(doc.id, docData);
  }
}

class NotifSettings {
  final bool newOrders;
  final bool newMessages;
  final bool orderConfirmations;

  const NotifSettings({
    this.newOrders = true,
    this.newMessages = true,
    this.orderConfirmations = true,
  });

  factory NotifSettings.fromMap(Map<String, dynamic> data) {
    return NotifSettings(
      newOrders: data['newOrders'] ?? true,
      newMessages: data['newMessages'] ?? true,
      orderConfirmations: data['orderConfirmations'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newOrders': newOrders,
      'newMessages': newMessages,
      'orderConfirmations': orderConfirmations,
    };
  }
}
