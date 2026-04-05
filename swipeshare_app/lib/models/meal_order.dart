import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshare_app/utils/firestore_utils.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

enum OrderRole { buyer, seller }

enum OrderStatus { active, completed, cancelled }

class OrderParticipant {
  final String id;
  final String name;
  final double stars;
  final bool hasNotifs;
  final bool markedComplete;
  final Rating? rating;

  const OrderParticipant({
    required this.id,
    required this.name,
    required this.stars,
    required this.hasNotifs,
    this.markedComplete = false,
    this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stars': stars,
      'hasNotifs': hasNotifs,
      'markedComplete': markedComplete,
      'rating': rating?.toMap(),
    };
  }

  factory OrderParticipant.fromMap(Map<String, dynamic> map) {
    return OrderParticipant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      stars: (map['stars'] as num?)?.toDouble() ?? 5.0,
      hasNotifs: map['hasNotifs'] ?? false,
      markedComplete: map['markedComplete'] ?? false,
      rating: map['rating'] != null
          ? Rating.fromMap(Map<String, dynamic>.from(map['rating']))
          : null,
    );
  }
}

class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final OrderParticipant seller;
  final OrderParticipant buyer;
  final String diningHall;
  final String?
  displayTime; //TimeOfDay.toString() use the static methods in time_formatter.dart to convert
  final DateTime transactionDate;
  final OrderStatus status;
  final double price;
  final OrderRole? cancelledBy;
  final bool cancellationAcknowledged;

  MealOrder({
    required this.seller,
    required this.buyer,
    required this.diningHall,
    this.displayTime,
    required this.transactionDate,
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

    if (user.uid == seller.id) {
      return OrderRole.seller;
    } else if (user.uid == buyer.id) {
      return OrderRole.buyer;
    } else {
      throw StateError('Current user is neither the buyer nor the seller');
    }
  }

  /// The current user's participant data within this order.
  OrderParticipant get me =>
      currentUserRole == OrderRole.seller ? seller : buyer;

  /// The other party's participant data within this order.
  OrderParticipant get them =>
      currentUserRole == OrderRole.seller ? buyer : seller;

  Map<String, dynamic> toMap() {
    return {
      'seller': seller.toMap(),
      'buyer': buyer.toMap(),
      'diningHall': diningHall,
      'displayTime': displayTime,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'status': status.name,
      'price': price,
      'cancelledBy': cancelledBy?.name,
      'cancellationAcknowledged': cancellationAcknowledged,
    };
  }

  factory MealOrder.fromMap(Map<String, dynamic> map) {
    return MealOrder(
      seller: OrderParticipant.fromMap(
        Map<String, dynamic>.from(map['seller']),
      ),
      buyer: OrderParticipant.fromMap(Map<String, dynamic>.from(map['buyer'])),
      diningHall: map['diningHall'] ?? '',
      displayTime: map['displayTime'],
      transactionDate: FirestoreUtils.parseTimestamp(map['transactionDate']),
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
    return '${seller.id}_${buyer.id}_${transactionDate.millisecondsSinceEpoch}';
  }

  /// Determines if this order is active or needs acknowledgment.
  /// Returns true for active orders and cancelled orders that:
  /// - Were cancelled by the other party
  /// - Haven't been acknowledged yet by the current user
  bool isActiveOrUnacknowledged() {
    if (status == OrderStatus.active) return true;
    if (status == OrderStatus.cancelled) {
      return cancelledBy != currentUserRole && !cancellationAcknowledged;
    }
    return false;
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
    final timestampValue = map['timestamp'];

    return Rating(
      stars: map['stars'] as int,
      extraInfo: map['extraInfo'] as String?,
      timestamp: timestampValue != null
          ? FirestoreUtils.parseTimestamp(timestampValue)
          : DateTime.now(),
    );
  }
}
