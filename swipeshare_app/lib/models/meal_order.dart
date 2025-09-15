import 'package:flutter/material.dart';

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String? id;
  final String sellerId;
  final String buyerId;
  final String diningHall;
  final TimeOfDay?
  time; //will be set by the users, if not set just display as TBD
  final DateTime transactionDate;

  MealOrder({
    this.id,
    required this.sellerId,
    required this.buyerId,
    required this.diningHall,
    this.time,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'doc_id': id,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      'dining_hall': diningHall,
      'transaction_datetime': time != null
          ? DateTime(
              transactionDate.year,
              transactionDate.month,
              transactionDate.day,
              time!.hour,
              time!.minute,
            ).toIso8601String()
          : null,
    };
  }

  MealOrder.fromJson(Map<String, dynamic> json)
    : id = json['doc_id'],
      sellerId = json['seller_id'],
      buyerId = json['buyer_id'],
      diningHall = json['dining_hall'],
      time = json['transaction_datetime'] != null
          ? TimeOfDay(
              hour: DateTime.parse(json['transaction_datetime']).hour,
              minute: DateTime.parse(json['transaction_datetime']).minute,
            )
          : null,
      transactionDate = json['transaction_datetime'] != null
          ? DateTime.parse(json['transaction_datetime'])
          : DateTime.now();

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.toIso8601String()}';
  }
}

class MealOrderCreate {
  final String sellerId;
  final String diningHall;
  final DateTime transactionDate;

  MealOrderCreate({
    required this.sellerId,
    required this.diningHall,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'seller_id': sellerId,
      'dining_hall': diningHall,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
