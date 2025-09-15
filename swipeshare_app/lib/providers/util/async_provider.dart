import 'package:flutter/foundation.dart';

/// Abstract base class for providers that handle asynchronous operations with
/// loading states, error handling, and initialization management.
///
/// This class provides a common pattern for providers that need to:
/// - Fetch data asynchronously with proper loading/error states
/// - Initialize once and prevent duplicate initialization
/// - Execute operations with consistent error handling
/// - Reset state when needed (e.g., user logout)
///
/// Subclasses must implement the [initialize] and [reset] methods to define their
/// specific initialization logic.
abstract class AsyncProvider extends ChangeNotifier {
  bool _hasInitialized = false;
  bool _isLoading = false;
  String? _error;

  /// Whether this provider has completed its initialization process.
  bool get hasInitialized => _hasInitialized;

  /// Whether this provider is currently executing an async operation.
  bool get isLoading => _isLoading;

  /// The error message from the last failed operation, if any.
  String? get error => _error;

  /// Protected setter for initialization state. Only for use by subclasses.
  @protected
  set hasInitialized(bool value) {
    _hasInitialized = value;
  }

  /// Protected setter for loading state. Automatically notifies listeners.
  @protected
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Protected setter for error state. Only for use by subclasses.
  @protected
  set error(String? value) {
    _error = value;
  }

  /// Abstract method that subclasses must implement to define their
  /// specific initialization logic.
  ///
  /// This method should contain the actual data fetching or setup logic
  /// for the provider. It will be called by [ensureInitialized] with
  /// proper loading and error state management.
  @protected
  Future<void> initialize();

  /// Ensures the provider is initialized exactly once.
  ///
  /// This method provides idempotent initialization - it's safe to call
  /// multiple times. If already initialized, returns immediately.
  /// Otherwise, sets loading state, calls [initialize], and manages
  /// error handling automatically.
  ///
  /// This is the primary method external code should use for initialization.
  Future<void> ensureInitialized() async {
    if (_hasInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await initialize();
      _hasInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Executes an async operation with automatic loading and error state management.
  ///
  /// This method wraps any async operation with:
  /// - Loading state management (sets isLoading to true during execution)
  /// - Error handling (captures exceptions and sets error state)
  /// - Automatic listener notification
  ///
  /// Use this for operations that should show loading indicators and handle
  /// errors consistently across the provider.
  ///
  /// Example:
  /// ```dart
  /// Future<User> updateProfile(String name) async {
  ///   return executeOperation(() async {
  ///     final user = await userService.updateProfile(name);
  ///     _currentUser = user;
  ///     return user;
  ///   });
  /// }
  /// ```
  @protected
  Future<T> executeOperation<T>(Future<T> Function() operation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Abstract method that subclasses must implement to define their
  /// specific reset logic.
  ///
  /// This method should clear any provider-specific data (e.g., user data,
  /// cached lists, etc.). The base AsyncProvider will handle resetting
  /// the common state fields (hasInitialized, isLoading, error).
  @protected
  Future<void> reset();

  /// Resets the provider to its initial state.
  ///
  /// This method clears all state (initialization status, loading state,
  /// and errors) and calls the subclass's [reset] method to clear any
  /// provider-specific data.
  ///
  /// Typically called when a user logs out or when the provider needs
  /// to be completely reinitialized.
  ///
  /// The method is idempotent - if the provider is already in a clean state,
  /// it returns early without doing anything.
  Future<void> ensureReset() async {
    if (!_hasInitialized && !_isLoading && _error == null) return;
    _hasInitialized = false;
    _isLoading = false;
    _error = null;
    await reset();
    notifyListeners();
  }
}
