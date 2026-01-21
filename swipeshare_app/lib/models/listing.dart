import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ListingStatus { active, claimed, expired, cancelled }

class Listing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String diningHall;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final DateTime transactionDate;
  final double sellerRating;
  final List<String> paymentTypes;
  final double? price;
  final ListingStatus status;

  Listing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.diningHall,
    required this.timeStart,
    required this.timeEnd,
    required this.transactionDate,
    required this.sellerRating,
    required this.paymentTypes,
    this.price,
    required this.status,
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
      'price': price,
      'status': status.name,
    };
  }

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception(
        'Listing document (id: ${doc.id}) does not exist or has no data',
      );
    }
    return Listing.fromMap(doc.id, docData);
  }

  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    return Listing(
      id: id,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      diningHall: map['diningHall'] ?? '',
      timeStart: Listing.minutesToTOD(map['timeStart']),
      timeEnd: Listing.minutesToTOD(map['timeEnd']),
      transactionDate: map['transactionDate'] is Timestamp
          ? map['transactionDate'].toDate()
          : null,
      sellerRating: map['sellerRating'].toDouble(),
      paymentTypes: [for (var item in map['paymentTypes']) item as String],
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      status: map['status'] != null
          ? ListingStatus.values.byName(map['status'])
          : ListingStatus.expired,
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

  /// Computed datetime combining transactionDate and timeStart
  DateTime get datetime => DateTime(
    transactionDate.year,
    transactionDate.month,
    transactionDate.day,
    timeStart.hour,
    timeStart.minute,
  );

  /// Comparator to sort Listings by soonest transaction date
  static int bySoonest(Listing a, Listing b) {
    final now = DateTime.now();

    final aIsFuture = a.datetime.isAfter(now);
    final bIsFuture = b.datetime.isAfter(now);

    // Both future: soonest first
    if (aIsFuture && bIsFuture) {
      return a.datetime.compareTo(b.datetime);
    }

    // Both past: most recent first
    if (!aIsFuture && !bIsFuture) {
      return b.datetime.compareTo(a.datetime);
    }

    // One future, one past: future comes first
    return aIsFuture ? -1 : 1;
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
