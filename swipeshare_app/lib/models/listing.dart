import 'package:flutter/material.dart';

enum PaymentType {
  venmo,
  cashapp,
  paypal,
  cash,
} // Update after customer survey

class Listing {
  final String sellerId;
  final String diningHall;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final DateTime transactionDate;
  // sellerRating?!?
  //final List<PaymentType> paymentTypes;

  Listing({
    required this.sellerId,
    required this.diningHall,
    required this.timeStart,
    required this.timeEnd,
    required this.transactionDate,
    //required this.paymentTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'diningHall': diningHall,
      'timeStart': Listing.toMinutes(timeStart),
      'timeEnd': Listing.toMinutes(timeEnd),
      'transactionDate': transactionDate
          .toIso8601String(), //better to have as string or no?
      //'paymentType': paymentTypes.map((pt) => pt.name).toList(),
    };
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
