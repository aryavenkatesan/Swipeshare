import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PaymentType {
  venmo,
  cashapp,
  paypal,
  cash,
} // Update after customer survey

class Listing {
  final String id;
  final String sellerId;
  final String diningHall;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final DateTime transactionDate;
  // sellerRating?!?
  //final List<PaymentType> paymentTypes;

  Listing({
    required this.id,
    required this.sellerId,
    required this.diningHall,
    required this.timeStart,
    required this.timeEnd,
    required this.transactionDate,
    //required this.paymentTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'diningHall': diningHall,
      'timeStart': Listing.toMinutes(timeStart),
      'timeEnd': Listing.toMinutes(timeEnd),
      'transactionDate': Timestamp.fromDate(
        DateTime(
          transactionDate.year,
          transactionDate.month,
          transactionDate.day,
        ),
      ),
      //'payment_types': paymentTypes.map((pt) => pt.name).toList(),
    };
  }

  factory Listing.fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }

    return Listing(
      id: doc.id,
      sellerId: doc['sellerId'],
      diningHall: doc['diningHall'],
      timeStart: Listing.minutesToTOD(doc['timeStart']),
      timeEnd: Listing.minutesToTOD(doc['timeEnd']),
      transactionDate: (doc['transactionDate'] as Timestamp).toDate(),
    );
  }

  static int toMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  static TimeOfDay minutesToTOD(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }
}
