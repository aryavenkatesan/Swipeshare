import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

enum SettingsItems { report, block, cancelOrder }

class ChatSettingsMenu extends StatelessWidget {
  final ChatService chatService;
  final MealOrder orderData;

  const ChatSettingsMenu({
    super.key,
    required this.chatService,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SettingsItems>(
      onSelected: (value) {
        switch (value) {
          case SettingsItems.report:
            _showReportDialog(context);
          case SettingsItems.block:
            _showBlockDialog(context);
          case SettingsItems.cancelOrder:
            _showCancelOrderDialog(context);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SettingsItems>>[
        const PopupMenuItem<SettingsItems>(
          value: SettingsItems.report,
          child: Text('Report This User'),
        ),
        const PopupMenuItem<SettingsItems>(
          value: SettingsItems.block,
          child: Text('Block This User'),
        ),
        const PopupMenuItem<SettingsItems>(
          value: SettingsItems.cancelOrder,
          child: Text('Cancel Order'),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) async {
    final reportText = await AdaptiveDialog.showTextInput(
      context: context,
      title: 'Report User',
      description: 'Please provide a reason for reporting this user:',
      hintText: 'Enter reason...',
      submitText: 'Report',
      cancelText: 'Close',
      maxLines: 3,
      maxLength: 200,
    );

    if (reportText != null && context.mounted) {
      chatService.reportUser(reportText);
      await safeVibrate(HapticsType.success);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SnackbarMessages.reportSubmitted)),
        );
      }
    }
  }

  void _showBlockDialog(BuildContext context) async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Block User',
      content: 'Are you sure you want to block this User?',
      confirmText: 'Block',
      cancelText: 'Close',
    );

    if (confirmed == true && context.mounted) {
      await safeVibrate(HapticsType.heavy);
      UserService.instance.blockUser(orderData);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _showCancelOrderDialog(BuildContext context) async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Cancel Order',
      content: 'Are you sure you want to cancel this order?',
      confirmText: 'Cancel Order',
      cancelText: 'Close',
    );

    if (confirmed == true && context.mounted) {
      await safeVibrate(HapticsType.heavy);
      await OrderService.instance.cancelOrder(
        orderData.getRoomName(),
        orderData.currentUserRole,
      );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
