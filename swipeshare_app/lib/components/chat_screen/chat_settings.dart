import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

enum SettingsItems { itemOne, itemTwo, itemThree }

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
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SettingsItems>>[
        PopupMenuItem<SettingsItems>(
          value: SettingsItems.itemOne,
          child: const Text('Report This User'),
          onTap: () {
            // Delay is needed to prevent context issues with popup menu
            Future.delayed(Duration.zero, () => _showReportDialog(context));
          },
        ),
        PopupMenuItem<SettingsItems>(
          value: SettingsItems.itemTwo,
          child: const Text('Block This User'),
          onTap: () {
            Future.delayed(Duration.zero, () => _showBlockDialog(context));
          },
        ),
        PopupMenuItem<SettingsItems>(
          value: SettingsItems.itemThree,
          child: const Text('Delete Chat'),
          onTap: () {
            Future.delayed(Duration.zero, () => _showDeleteDialog(context));
          },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(SnackbarMessages.reportSubmitted)),
      );
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
      Navigator.of(context).pop();
    }
  }

  void _showDeleteDialog(BuildContext context) async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Delete Chat',
      content: 'Are you sure you want to Delete the Chat?',
      confirmText: 'Delete',
      cancelText: 'Close',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await safeVibrate(HapticsType.heavy);
      chatService.deleteChat(orderData);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(SnackbarMessages.chatDeleted)));
      }
    }
  }
}
