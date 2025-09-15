import 'package:dio/dio.dart';
import 'package:swipeshare_app/core/network/api_client.dart';
import 'package:swipeshare_app/models/meal_order.dart';

class OrderService {
  final Dio _apiClient;

  OrderService({Dio? dio}) : _apiClient = dio ?? apiClient;

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

    try {
      final response = await _apiClient.post('/orders', data: newOrder.toMap());
      return MealOrder.fromJson(response.data);
    } catch (e, s) {
      // Handle the error and stack trace
      print('Error: $e');
      print('Stack: $s');
      rethrow;
    }
  }

  Future<List<MealOrder>> fetchOrders() async {
    try {
      final response = await _apiClient.get('/orders');
      List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MealOrder.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<MealOrder> makeTransaction(String listingId, DateTime datetime) async {
    try {
      final response = await _apiClient.post('/orders/consume-listing/$listingId', data: {
        'transaction_datetime': datetime.toIso8601String(),
      });
      return MealOrder.fromJson(response.data);
    } catch (e) {
      print('Error making transaction: $e');
      rethrow;
    }
  }
}
