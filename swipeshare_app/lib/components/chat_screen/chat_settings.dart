import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/user_service.dart';

enum SettingsItems { itemOne, itemTwo, itemThree }

class ChatSettingsMenu extends StatelessWidget {
  final String currentUserId;
  final String currentUserEmail;
  final String receiverUserId;
  final String receiverUserName;
  final ChatService chatService;
  final MealOrder orderData;

  const ChatSettingsMenu({
    super.key,
    required this.currentUserId,
    required this.currentUserEmail,
    required this.receiverUserId,
    required this.receiverUserName,
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

  void _showReportDialog(BuildContext context) {
    final TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason for reporting this user:'),
              const SizedBox(height: 16),
              TextField(
                controller: reportController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (reportController.text.isNotEmpty) {
                  chatService.reportUser(
                    currentUserId,
                    currentUserEmail,
                    receiverUserId,
                    receiverUserName,
                    reportController.text,
                  );
                  if (await Haptics.canVibrate()) {
                    Haptics.vibrate(HapticsType.heavy);
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Thank you for reporting, we will review your message and take action as soon as possible.',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                }
              },
              child: const Text(
                'Report',
                style: TextStyle(color: Color.fromARGB(177, 96, 125, 139)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: const Text('Are you sure you want to block this User?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (await Haptics.canVibrate()) {
                  Haptics.vibrate(HapticsType.heavy);
                }
                UserService().blockUser(orderData);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Block',
                style: TextStyle(color: Color.fromARGB(177, 96, 125, 139)),
              ),
            ),
            TextButton(
              onPressed: () {
                debugPrint("Closing the Thingy");
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to Delete the Chat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (await Haptics.canVibrate()) {
                  Haptics.vibrate(HapticsType.heavy);
                }
                chatService.deleteChat(orderData);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('The chat has been deleted.')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(177, 96, 125, 139)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
