import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/auth.dart';
import 'package:swipeshare_app/providers/util/async_provider.dart';
import 'package:swipeshare_app/services/user_service.dart';

class UserProvider extends AsyncProvider {
  final UserService _userService;
  User? _currentUser;

  UserProvider({UserService? userService})
    : _userService = userService ?? UserService();

  User? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    _currentUser = await _userService.getCurrentUser();
    debugPrint("UserProvider initialized with user: ${_currentUser?.email}");
  }

  @override
  Future<void> reset() async {
    _currentUser = null;
  }
}
