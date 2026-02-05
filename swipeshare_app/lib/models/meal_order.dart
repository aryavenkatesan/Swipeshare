import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshare_app/utils/firestore_utils.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

enum OrderRole { buyer, seller }

enum OrderStatus { active, completed, cancelled }

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String sellerId;
  final String sellerName;
  final double sellerStars;
  final String buyerId;
  final String buyerName;
  final double buyerStars;
  final String diningHall;
  final String?
  displayTime; //TimeOfDay.toString() use the static methods in time_formatter.dart to convert
  final bool sellerHasNotifs;
  final bool buyerHasNotifs;
  final DateTime transactionDate;
  final Rating? ratingByBuyer;
  final Rating? ratingBySeller;
  final OrderStatus status;
  final double price;
  final OrderRole? cancelledBy;
  final bool cancellationAcknowledged;

  MealOrder({
    required this.sellerId,
    required this.sellerName,
    required this.sellerStars,
    required this.buyerId,
    required this.buyerName,
    required this.buyerStars,
    required this.diningHall,
    this.displayTime,
    required this.sellerHasNotifs,
    required this.buyerHasNotifs,
    required this.transactionDate,
    this.ratingByBuyer,
    this.ratingBySeller,
    required this.status,
    this.price = 0,
    this.cancelledBy,
    this.cancellationAcknowledged = false,
  });

  DateTime get datetime => DateTime(
    transactionDate.year,
    transactionDate.month,
    transactionDate.day,
    displayTime != null
        ? TimeFormatter.parseTimeOfDayString(displayTime!).hour
        : 12,
    displayTime != null
        ? TimeFormatter.parseTimeOfDayString(displayTime!).minute
        : 0,
  );

  OrderRole get currentUserRole {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('No user is currently signed in');
    }

    if (user.uid == sellerId) {
      return OrderRole.seller;
    } else if (user.uid == buyerId) {
      return OrderRole.buyer;
    } else {
      throw StateError('Current user is neither the buyer nor the seller');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerStars': sellerStars,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerStars': buyerStars,
      'diningHall': diningHall,
      'displayTime': displayTime,
      'sellerHasNotifs': sellerHasNotifs,
      'buyerHasNotifs': buyerHasNotifs,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'ratingByBuyer': ratingByBuyer?.toMap(),
      'ratingBySeller': ratingBySeller?.toMap(),
      'status': status.name,
      'price': price,
      'cancelledBy': cancelledBy?.name,
      'cancellationAcknowledged': cancellationAcknowledged,
    };
  }

  factory MealOrder.fromMap(Map<String, dynamic> map) {
    return MealOrder(
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerStars: map['sellerStars'].toDouble() ?? 5.0,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerStars: (map['buyerStars'] as num?)?.toDouble() ?? 5.0,
      diningHall: map['diningHall'] ?? '',
      displayTime: map['displayTime'],
      sellerHasNotifs: map['sellerHasNotifs'] ?? false,
      buyerHasNotifs: map['buyerHasNotifs'] ?? false,
      transactionDate: FirestoreUtils.parseTimestamp(map['transactionDate']),
      ratingByBuyer: map['ratingByBuyer'] != null
          ? Rating.fromMap(Map<String, dynamic>.from(map['ratingByBuyer']))
          : null,
      ratingBySeller: map['ratingBySeller'] != null
          ? Rating.fromMap(Map<String, dynamic>.from(map['ratingBySeller']))
          : null,
      status: map['status'] != null
          ? OrderStatus.values.byName(map['status'])
          : OrderStatus.cancelled,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      cancelledBy: map['cancelledBy'] != null
          ? OrderRole.values.byName(map['cancelledBy'])
          : null,
      cancellationAcknowledged: map['cancellationAcknowledged'] ?? false,
    );
  }

  factory MealOrder.fromFirestore(DocumentSnapshot doc) {
    final docData = doc.data() as Map<String, dynamic>?;
    if (!doc.exists || docData == null || docData.isEmpty) {
      throw Exception(
        'MealOrder document (id: ${doc.id}) does not exist or has no data',
      );
    }
    return MealOrder.fromMap(docData);
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.millisecondsSinceEpoch}';
  }

  /// Comparator to sort MealOrders by soonest transaction date
  static int bySoonest(MealOrder a, MealOrder b) {
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
}

class Rating {
  final int stars;
  final String? extraInfo;
  final DateTime timestamp;

  Rating({required this.stars, this.extraInfo, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'stars': stars,
      'extraInfo': extraInfo,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      stars: map['stars'] as int,
      extraInfo: map['extraInfo'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
