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
      'seller_id': sellerId,
      'dining_hall': diningHall,
      'time_start': Listing.toMinutes(timeStart),
      'time_end': Listing.toMinutes(timeEnd),
      'transaction_date': transactionDate
          .toIso8601String(), //better to have as string or no?
      //'payment_types': paymentTypes.map((pt) => pt.name).toList(),
    };
  }

  Listing.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      sellerId = json['seller_id'],
      diningHall = json['dining_hall'],
      timeStart = Listing.minutesToTOD(json['time_start']),
      timeEnd = Listing.minutesToTOD(json['time_end']),
      transactionDate = DateTime.parse(json['transaction_date']);

  static int toMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  static TimeOfDay minutesToTOD(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }
}

class ListingCreate {
  final String diningHall;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final DateTime transactionDate;

  ListingCreate({
    required this.diningHall,
    required this.timeStart,
    required this.timeEnd,
    required this.transactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'dining_hall': diningHall,
      'time_start': Listing.toMinutes(timeStart),
      'time_end': Listing.toMinutes(timeEnd),
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
