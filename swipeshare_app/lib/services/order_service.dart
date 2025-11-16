import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/listing_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

class OrderService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final ChatService _chatService = ChatService();
  final ListingService _listingService = ListingService();

  //POST ORDER
  Future<void> postOrder(Listing listing) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final user = await _userService.getUserData(currentUserId);

    if (user == null) {
      throw Exception(
        'User data not found for current user ID: $currentUserId',
      );
    }

    MealOrder newOrder = MealOrder(
      sellerId: listing.sellerId,
      buyerId: currentUserId,
      diningHall: listing.diningHall,
      transactionDate: listing.transactionDate,
      sellerName: listing.sellerName,
      buyerName: user.name,
      sellerStars: listing.sellerRating,
      buyerStars: user.stars,
      sellerHasNotifs: true,
      buyerHasNotifs: true,
    );

    try {
      await _fireStore.runTransaction((transaction) async {
        final orderRef = _fireStore
            .collection('orders')
            .doc(newOrder.getRoomName());

        // Check if listing still exists (prevents race conditions)
        final listingData = await _listingService.getListingById(
          listing.id,
          transaction: transaction,
        );
        if (listingData == null) {
          throw Exception('Listing no longer exists');
        }

        _listingService.deleteListing(listing.id, transaction: transaction);
        transaction.set(orderRef, newOrder.toMap());

        _chatService.newOrderSystemMessage(
          newOrder.getRoomName(),
          transaction: transaction,
        );
      });
    } catch (e, s) {
      debugPrint('Error: $e');
      debugPrint('Stack: $s');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getOrders(String userId) {
    return _fireStore
        .collection('orders')
        .where(
          Filter.or(
            Filter.and(
              Filter('sellerId', isEqualTo: userId),
              Filter('sellerVisibility', isEqualTo: true),
            ),
            Filter.and(
              Filter('buyerId', isEqualTo: userId),
              Filter('buyerVisibility', isEqualTo: true),
            ),
          ),
        )
        .snapshots();
  }

  Future<MealOrder?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _fireStore
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return MealOrder.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        debugPrint('No such order with id: $orderId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching order by id: $e');
      return null;
    }
  }

  Future<void> updateVisibility(MealOrder orderData, bool deletedChat) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    if (currentUserId == orderData.buyerId) {
      //set buyer visibility to false
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'buyerVisibility': false, 'buyerHasNotifs': false},
      );
    } else {
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'sellerVisibility': false, 'sellerHasNotifs': false},
      );
    }
    if (!deletedChat) {
      //send system message that the other person left
      final UserModel? currentUser = await _userService.getUserData(
        currentUserId,
      );
      final String message =
          "${currentUser?.name ?? 'User'} has closed the order and left the chat.\nClick the check button above to close the order :)";
      _chatService.systemMessage(message, orderData.getRoomName());
    } else {
      await _fireStore.collection('orders').doc(orderData.getRoomName()).update(
        {'isChatDeleted': true},
      );
    }
  }
}
