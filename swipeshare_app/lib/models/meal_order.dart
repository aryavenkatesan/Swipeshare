import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';

class MealOrder extends MealOrderCreate {
  // its called meal order instead of order because order is a keyword in firestore
  final String id;

  MealOrder({
    required this.id,
    required super.sellerId,
    required super.buyerId,
    required super.diningHall,
    required super.date,
    super.time,
  });

  factory MealOrder.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }
    final date = (doc['date'] as Timestamp).toDate();
    return MealOrder(
      id: doc.id,
      sellerId: doc['sellerId'],
      buyerId: doc['buyerId'],
      diningHall: doc['diningHall'],
      time: doc['time'] != null ? Listing.minutesToTOD(doc['time']) : null,
      date: DateTime(date.year, date.month, date.day),
    );
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${date.toIso8601String()}';
  }
}

class MealOrderCreate {
  final String sellerId;
  final String buyerId;
  final String diningHall;
  final DateTime date;
  final TimeOfDay? time; // nullable to represent undecided time

  MealOrderCreate({
    required this.sellerId,
    required this.buyerId,
    required this.diningHall,
    required DateTime date,
    this.time,
  }) : date = DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'buyerId': buyerId,
      'diningHall': diningHall,
      'date': Timestamp.fromDate(date),
      'time': time != null ? Listing.toMinutes(time!) : null,
    };
  }
}
