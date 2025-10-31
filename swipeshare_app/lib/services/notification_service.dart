import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/firebase_options.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/order_service.dart';

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.updateBadgeCount();
}

class NotificationService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  // For some reason this doesn't work if not static even though its a singleton
  // Inlcuding the getter and setter to avoid mixing static and singleton patterns
  static String? _activeChatId;

  set activeChatId(String? chatId) {
    _activeChatId = chatId;
  }

  // ignore: unnecessary_getters_setters
  String? get activeChatId => _activeChatId;

  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Configures notification service for app to funciton properly
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    debugPrint("Initializing Notification Service");

    _navigatorKey = navigatorKey;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint("User declined notification permissions");
      return;
    }

    _refreshFcmToken(_auth.currentUser);

    _auth.authStateChanges().listen(_refreshFcmToken);

    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Opened app from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Opened app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("App opened from terminated state via notification");
      _handleNotificationTap(initialMessage);
    }
  }

  /// Removes the FCM token from Firestore
  Future<void> removeTokenFromFirestore() async {
    await _saveTokenToFirestore(null);
  }

  /// Refreshes the FCM token and saves it to Firestore
  Future<void> _refreshFcmToken(User? currentUser) async {
    if (currentUser == null) return;

    try {
      final token = await _messaging.getToken();
      debugPrint("Refreshed FCM Token: $token");
      await _saveTokenToFirestore(token);
    } catch (e) {
      await removeTokenFromFirestore();
      debugPrint("Error refreshing FCM token: $e");
    }
  }

  /// Saves the FCM token to Firestore under the user's document
  Future<void> _saveTokenToFirestore(String? token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint("Updated Firestore FCM token to $token");
  }

  /// Handles incoming messages when the app is in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message in the foreground!');

    Haptics.vibrate(HapticsType.medium);

    final messageOrderId = message.data['orderId'] as String?;
    debugPrint("Active chat: $activeChatId");
    if (messageOrderId != null && messageOrderId == activeChatId) {
      debugPrint(
        'User is already on chat page for this order, skipping snackbar',
      );
      ChatService().readNotificationsById(messageOrderId);
      return;
    }

    updateBadgeCount();

    // Show snackbar
    final context = _navigatorKey?.currentContext;
    if (context != null && message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.notification!.title ?? 'New notification',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _handleNotificationTap(message),
          ),
        ),
      );
    }
  }

  /// Handles notification taps to navigate to appropriate pages
  void _handleNotificationTap(RemoteMessage message) async {
    debugPrint('Notification caused app to open: ${message.messageId}');

    if (_navigatorKey?.currentState == null) {
      debugPrint('Navigator key is not set or has no current state');
      return;
    }

    if (message.data.isEmpty || !message.data.containsKey('type')) {
      debugPrint('Notification data is missing required fields: $message');
      return;
    }

    switch (message.data['type']) {
      case 'new_message':
      case 'new_order':
      case 'time_proposal_update':
        await _navigateToChatPage(message.data);
        break;
      default:
        debugPrint('Unknown notification type: ${message.data['type']}');
    }
  }

  /// Handles notification taps that navigate to chat page
  /// [data] - Map from the Firestore notification payload
  Future<void> _navigateToChatPage(Map<String, dynamic> data) async {
    final orderId = data['orderId'] as String?;

    if (orderId == null) {
      debugPrint('Malformed notification data: $data');
      return;
    }

    final orderData = await OrderService().getOrderById(orderId);
    if (orderData == null) {
      debugPrint('No order data found for orderId: $orderId');
      return;
    }

    _navigatorKey!.currentState!.push(
      MaterialPageRoute(builder: (context) => ChatPage(orderData: orderData)),
    );
  }

  /// Updates the app badge count based on order notification fields
  Future<void> updateBadgeCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (!await AppBadgePlus.isSupported()) {
        return;
      }
    } on Exception {
      return;
    }

    final buyerOrders = _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .where('buyerHasNotifs', isEqualTo: true);

    final sellerOrders = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .where('sellerHasNotifs', isEqualTo: true);

    final [buyerSnapshots, sellerSnapshots] = await Future.wait([
      buyerOrders.get(),
      sellerOrders.get(),
    ]);

    final totalUnread =
        buyerSnapshots.docs.length + sellerSnapshots.docs.length;

    AppBadgePlus.updateBadge(totalUnread);
  }
}
