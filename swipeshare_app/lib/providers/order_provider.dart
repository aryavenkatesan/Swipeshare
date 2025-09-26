import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/providers/util/async_provider.dart';
import 'package:swipeshare_app/services/order_service.dart';

class OrderProvider extends AsyncProvider {
  final OrderService _orderService;
  List<MealOrder> _orders = [];

  OrderProvider({OrderService? orderService})
    : _orderService = orderService ?? OrderService();

  List<MealOrder> get orders => _orders;

  @override
  @protected
  Future<void> initialize() async {
    debugPrint("Initializing OrderProvider...");
    _orders = await _orderService.fetchOrders();
  }

  @override
  @protected
  Future<void> reset() async {
    _orders.clear();
  }

  Future<MealOrder> makeTransaction(String listingId, DateTime datetime) async {
    return executeOperation(() async {
      final order = await _orderService.makeTransaction(listingId, datetime);
      _orders.add(order);
      return order;
    });
  }

  Future<MealOrder> postOrder(
    String sellerId,
    String diningHall,
    DateTime transactionDate,
  ) async {
    return executeOperation(() async {
      final order = await _orderService.postOrder(
        sellerId,
        diningHall,
        transactionDate,
      );
      _orders.add(order);
      return order;
    });
  }
}
