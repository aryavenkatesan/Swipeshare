import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum PaymentType {
  venmo,
  cashapp,
  paypal,
  cash,
} // Update after customer survey
//survey says.. enum is not it, just use List<String> lmao

class Listing {
  final String sellerId;
  final String sellerName;
  final String diningHall;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final DateTime transactionDate;
  final double sellerRating;
  final List<String> paymentTypes;

  Listing({
    required this.sellerId,
    required this.sellerName,
    required this.diningHall,
    required this.timeStart,
    required this.timeEnd,
    required this.transactionDate,
    required this.sellerRating,
    required this.paymentTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'diningHall': diningHall,
      'timeStart': Listing.toMinutes(timeStart),
      'timeEnd': Listing.toMinutes(timeEnd),
      'transactionDate': Timestamp.fromDate(transactionDate),
      'sellerRating': sellerRating,
      'paymentTypes': paymentTypes,
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      diningHall: map['diningHall'] ?? '',
      timeStart: Listing.minutesToTOD(map['timeStart']),
      timeEnd: Listing.minutesToTOD(map['timeEnd']),
      transactionDate: map['transactionDate'].toDate(),
      sellerRating: map['sellerRating'],
      paymentTypes: [for (var item in map['paymentTypes']) item as String],
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

  static DateTime? stringToDateTime(String dateString) {
    // 1. Guard against null or empty strings
    if (dateString.isEmpty) {
      return null;
    }

    // 2. Use a try-catch block to handle parsing errors
    try {
      return DateTime.parse(dateString);
    } on FormatException {
      // 3. If parsing fails, log the error and return null
      // Use debugPrint for better logging in Flutter's debug console
      debugPrint('Error: Invalid date format for string: "$dateString"');
      return null;
    }
  }
}
