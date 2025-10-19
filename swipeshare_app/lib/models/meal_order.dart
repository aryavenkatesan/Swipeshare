import 'package:flutter/material.dart';

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String diningHall;
  final TimeOfDay? time;
  final DateTime transactionDate;

  MealOrder({
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.diningHall,
    this.time,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'diningHall': diningHall,
      'time': time,
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
      time: map['time'] != null
          ? TimeOfDay(hour: map['time']['hour'], minute: map['time']['minute'])
          : null,
      transactionDate: DateTime.parse(map['transactionDate']),
    );
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.toIso8601String()}';
  }
}
