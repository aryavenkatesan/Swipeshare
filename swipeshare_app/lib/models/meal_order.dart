class MealOrder {
  //its called meal order instead of order because order is a keyword in firestore
  final String sellerId;
  final String sellerName;
  final bool sellerVisibility;
  final double sellerStars;
  final String buyerId;
  final String buyerName;
  final bool buyerVisibility;
  final double buyerStars;
  final String diningHall;
  final String?
  displayTime; //TimeOfDay.toString() use the static methods in time_formatter.dart to convert
  final bool sellerHasNotifs;
  final bool buyerHasNotifs;
  final DateTime transactionDate;
  final bool isChatDeleted;

  MealOrder({
    required this.sellerId,
    required this.sellerName,
    required this.sellerVisibility,
    required this.sellerStars,
    required this.buyerId,
    required this.buyerName,
    required this.buyerVisibility,
    required this.buyerStars,
    required this.diningHall,
    this.displayTime,
    required this.sellerHasNotifs,
    required this.buyerHasNotifs,
    required this.transactionDate,
    required this.isChatDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerVisibility': sellerVisibility,
      'sellerStars': sellerStars,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerVisibility': buyerVisibility,
      'buyerStars': buyerStars,
      'diningHall': diningHall,
      'displayTime': displayTime,
      'sellerHasNotifs': sellerHasNotifs,
      'buyerHasNotifs': buyerHasNotifs,
      'transactionDate': transactionDate
          .toIso8601String(), //better to have as string or no?
      'isChatDeleted': isChatDeleted,
    };
  }

  factory MealOrder.fromMap(Map<String, dynamic> map) {
    return MealOrder(
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerVisibility: map['sellerVisibility'] ?? true,
      sellerStars: map['sellerStars'].toDouble() ?? 5.0,
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerVisibility: map['buyerVisibility'] ?? true,
      buyerStars: (map['buyerStars'] as num?)?.toDouble() ?? 5.0,
      diningHall: map['diningHall'] ?? '',
      displayTime: map['displayTime'],
      sellerHasNotifs: map['sellerHasNotifs'] ?? false,
      buyerHasNotifs: map['buyerHasNotifs'] ?? false,
      transactionDate: DateTime.parse(map['transactionDate']),
      isChatDeleted: map['isChatDeleted'] ?? false,
    );
  }

  getRoomName() {
    //something unique between the two people and their specific interaction, it will never be repeated
    return '${sellerId}_${buyerId}_${transactionDate.toIso8601String()}';
  }
}
