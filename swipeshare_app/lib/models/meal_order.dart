import 'package:flutter/material.dart';

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String diningHall;
  final String?
  displayTime; //TimeOfDay.toString() use the static methods in time_formatter.dart to convert
  final DateTime transactionDate;

  MealOrder({
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.diningHall,
    this.displayTime,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'diningHall': diningHall,
      'displayTime': displayTime,
      'transactionDate': transactionDate
          .toIso8601String(), //better to have as string or no?
    };
  }

  factory MealOrder.fromMap(Map<String, dynamic> map) {
    return MealOrder(
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      diningHall: map['diningHall'] ?? '',
      displayTime: map['displayTime'] ?? "",
      transactionDate: DateTime.parse(map['transactionDate']),
    );
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.toIso8601String()}';
  }
}
