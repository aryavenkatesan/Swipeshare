import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/core/network/api_client.dart';
import 'package:swipeshare_app/models/meal_order.dart';

class OrderService {
  final Dio _apiClient;

  OrderService({Dio? dio}) : _apiClient = dio ?? apiClient;

  /// Create a new order
  Future<MealOrder> postOrder(
    String sellerId,
    String diningHall,
    DateTime transactionDate,
  ) async {
    MealOrderCreate newOrder = MealOrderCreate(
      sellerId: sellerId,
      diningHall: diningHall,
      transactionDate: transactionDate,
    );

    final response = await _apiClient.post('/orders', data: newOrder.toMap());
    return MealOrder.fromJson(response.data);
  }

  /// Create an order by consuming a listing
  Future<MealOrder> makeTransaction(String listingId, DateTime datetime) async {
    final response = await _apiClient.post(
      '/orders/consume-listing/$listingId',
      data: {'transaction_datetime': datetime.toIso8601String()},
    );
    return MealOrder.fromJson(response.data);
  }

  /// Get all orders for the current user with optional filters
  Future<List<MealOrder>> fetchOrders({Map<String, dynamic>? filters}) async {
    debugPrint("OrderService fetchOrders called with filters: $filters");
    final response = await _apiClient.get('/orders', queryParameters: filters);
    List<dynamic> data = response.data as List<dynamic>;
    debugPrint("OrderService fetchOrders returned data: $data");
    try {
      return data.map((json) => MealOrder.fromJson(json)).toList();
    } on Exception catch (e) {
      debugPrint("Error parsing orders: $e");
      rethrow;
    }
  }

  /// Get a specific order by ID
  Future<MealOrder> getOrderById(String orderId) async {
    final response = await _apiClient.get('/orders/$orderId');
    return MealOrder.fromJson(response.data);
  }

  /// Delete an order by ID
  Future<MealOrder> deleteOrder(String orderId) async {
    final response = await _apiClient.delete('/orders/$orderId');
    return MealOrder.fromJson(response.data);
  }

  // Convenience methods for common filtering scenarios

  /// Get orders filtered by multiple criteria
  Future<List<MealOrder>> getFilteredOrders({
    String? diningHall,
    DateTime? transactionDateTime,
    String? sellerId,
  }) async {
    final filters = <String, dynamic>{};

    if (diningHall != null) filters['dining_hall'] = diningHall;
    if (transactionDateTime != null) {
      filters['transaction_datetime'] = transactionDateTime.toIso8601String();
    }
    if (sellerId != null) filters['seller_id'] = sellerId;

    return fetchOrders(filters: filters.isNotEmpty ? filters : null);
  }

  /// Get orders filtered by dining hall
  Future<List<MealOrder>> getOrdersByDiningHall(String diningHall) async {
    return getFilteredOrders(diningHall: diningHall);
  }

  /// Get orders filtered by seller ID
  Future<List<MealOrder>> getOrdersBySeller(String sellerId) async {
    return getFilteredOrders(sellerId: sellerId);
  }
}
