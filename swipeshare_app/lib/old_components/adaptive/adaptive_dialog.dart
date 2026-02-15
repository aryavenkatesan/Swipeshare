import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Utility class for platform-adaptive dialogs.
/// Uses CupertinoAlertDialog on iOS/macOS, AlertDialog on Android.
class AdaptiveDialog {
  /// Returns true if the current platform should use Cupertino-style dialogs
  static bool get useCupertino => Platform.isIOS || Platform.isMacOS;

  /// Shows a confirmation dialog with customizable buttons.
  /// Returns true if confirmed, false if cancelled, null if dismissed.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool isDestructive = false,
  }) async {
    if (useCupertino) {
      return _showCupertinoConfirmation(
        context: context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      );
    } else {
      return _showMaterialConfirmation(
        context: context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      );
    }
  }

  /// Shows a dialog with a text input field.
  /// Returns the entered text if submitted, null if cancelled.
  static Future<String?> showTextInput({
    required BuildContext context,
    required String title,
    String? description,
    String? hintText,
    String submitText = 'Submit',
    String cancelText = 'Cancel',
    int maxLines = 3,
    int? maxLength,
    bool isDestructive = false,
  }) async {
    if (useCupertino) {
      return _showCupertinoTextInput(
        context: context,
        title: title,
        description: description,
        hintText: hintText,
        submitText: submitText,
        cancelText: cancelText,
        maxLines: maxLines,
        maxLength: maxLength,
        isDestructive: isDestructive,
      );
    } else {
      return _showMaterialTextInput(
        context: context,
        title: title,
        description: description,
        hintText: hintText,
        submitText: submitText,
        cancelText: cancelText,
        maxLines: maxLines,
        maxLength: maxLength,
        isDestructive: isDestructive,
      );
    }
  }

  // ============ Cupertino Implementations ============

  static Future<bool?> _showCupertinoConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required bool isDestructive,
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<String?> _showCupertinoTextInput({
    required BuildContext context,
    required String title,
    String? description,
    String? hintText,
    required String submitText,
    required String cancelText,
    required int maxLines,
    int? maxLength,
    required bool isDestructive,
  }) {
    final controller = TextEditingController();

    return showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(description),
            ],
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              placeholder: hintText,
              maxLines: maxLines,
              maxLength: maxLength,
              padding: const EdgeInsets.all(12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(context).pop(text.isEmpty ? null : text);
            },
            child: Text(submitText),
          ),
        ],
      ),
    );
  }

  // ============ Material Implementations ============

  static Future<bool?> _showMaterialConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive
                    ? Colors.red
                    : const Color.fromARGB(177, 96, 125, 139),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> _showMaterialTextInput({
    required BuildContext context,
    required String title,
    String? description,
    String? hintText,
    required String submitText,
    required String cancelText,
    required int maxLines,
    int? maxLength,
    required bool isDestructive,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null) Text(description),
            if (description != null) const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
              maxLines: maxLines,
              maxLength: maxLength,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(context).pop(text.isEmpty ? null : text);
            },
            child: Text(
              submitText,
              style: TextStyle(
                color: isDestructive
                    ? Colors.red
                    : const Color.fromARGB(177, 96, 125, 139),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
