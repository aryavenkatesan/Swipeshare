import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:swipeshare_app/core/network/api_client.dart';
import 'package:swipeshare_app/models/auth.dart';

class UserService {
  final Dio _apiClient;

  UserService({Dio? dio})
      : _apiClient = dio ?? apiClient;

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      rethrow;
    }
  }
}