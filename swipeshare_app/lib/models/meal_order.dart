import 'package:flutter/material.dart';

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String? docId;
  final String sellerId;
  final String buyerId;
  final String location;
  final TimeOfDay?
  time; //will be set by the users, if not set just display as TBD
  final DateTime transactionDate;

  MealOrder({
    this.docId,
    required this.sellerId,
    required this.buyerId,
    required this.location,
    this.time,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'location': location,
      'time': time,
      'transactionDate': transactionDate
          .toIso8601String(), //better to have as string or no?
    };
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.toIso8601String()}';
  }
}
