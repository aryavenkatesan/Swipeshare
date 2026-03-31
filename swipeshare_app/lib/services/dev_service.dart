import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';

enum SeedEmail {
  nick('naasanov@unc.edu', 'Nick'),
  nickAlt('naasanov+a@unc.edu', 'n'),
  vidur('vmshah2@unc.edu', 'Vidur'),
  arya('aryav@unc.edu', 'Arya'),
  testUser1('testuser1@unc.edu', 'Test User 1'),
  testUser2('testuser2@unc.edu', 'Test User 2'),
  testUser3('testuser3@unc.edu', 'Test User 3');

  const SeedEmail(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum _DevAction {
  createListing,
  createOrder,
  clearData,
  completeOldOrders;

  String get value => name;
}

class DevService {
  DevService._();
  static final instance = DevService._();

  final _devSeed = FirebaseFunctions.instance.httpsCallable('devSeed');

  int get _nowMinutes {
    final now = TimeOfDay.now();
    return now.hour * 60 + now.minute;
  }

  Future<String> createListing({
    required SeedEmail sellerEmail,
    Map<String, dynamic>? overrides,
  }) async {
    try {
      final result = await _devSeed.call({
        'action': _DevAction.createListing.value,
        'sellerEmail': sellerEmail.value,
        'nowMinutes': _nowMinutes,
        if (overrides != null) 'overrides': overrides,
      });
      return Map<String, dynamic>.from(result.data as Map)['listingId']
          as String;
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint(
        '[DevService] createListing failed: ${e.code} — ${e.message}\ndetails: ${e.details}\n$s',
      );
      rethrow;
    } catch (e, s) {
      debugPrint('[DevService] createListing unexpected error: $e\n$s');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeOldOrders() async {
    try {
      final result = await _devSeed.call({
        'action': _DevAction.completeOldOrders.value,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint(
        '[DevService] completeOldOrders failed: ${e.code} — ${e.message}\ndetails: ${e.details}\n$s',
      );
      rethrow;
    } catch (e, s) {
      debugPrint('[DevService] completeOldOrders unexpected error: $e\n$s');
      rethrow;
    }
  }

  Future<void> clearData() async {
    try {
      await _devSeed.call({'action': _DevAction.clearData.value});
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint(
        '[DevService] clearData failed: ${e.code} — ${e.message}\ndetails: ${e.details}\n$s',
      );
      rethrow;
    } catch (e, s) {
      debugPrint('[DevService] clearData unexpected error: $e\n$s');
      rethrow;
    }
  }

  Future<({String orderId, MealOrder order})> createOrder({
    required SeedEmail sellerEmail,
    required SeedEmail buyerEmail,
    Map<String, dynamic>? overrides,
  }) async {
    try {
      final result = await _devSeed.call({
        'action': _DevAction.createOrder.value,
        'sellerEmail': sellerEmail.value,
        'buyerEmail': buyerEmail.value,
        'nowMinutes': _nowMinutes,
        if (overrides != null) 'listingOverrides': overrides,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (
        orderId: data['orderId'] as String,
        order: MealOrder.fromMap(
          Map<String, dynamic>.from(data['order'] as Map),
        ),
      );
    } on FirebaseFunctionsException catch (e, s) {
      debugPrint(
        '[DevService] createOrder failed: ${e.code} — ${e.message}\ndetails: ${e.details}\n$s',
      );
      rethrow;
    } catch (e, s) {
      debugPrint('[DevService] createOrder unexpected error: $e\n$s');
      rethrow;
    }
  }
}
