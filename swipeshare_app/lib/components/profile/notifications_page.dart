import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/user_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _userService = UserService.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = true;
  bool _orderReminders = true;
  bool _messages = false;
  bool _orderConfirmations = true;
  bool _orderCancellations = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        _orderReminders = user.notifSettings.newOrders;
        _messages = user.notifSettings.newMessages;
        _orderConfirmations = user.notifSettings.orderConfirmations;
        _orderCancellations = user.notifSettings.orderCancellations;
        _isLoading = false;
      });
    }
  }

  void _savePreferences() {
    _userService.updateNotificationPreferences(
      _uid,
      NotifSettings(
        newOrders: _orderReminders,
        newMessages: _messages,
        orderConfirmations: _orderConfirmations,
        orderCancellations: _orderCancellations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text("Notifications", style: textTheme.displayLarge),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                children: [
                  _NotificationTile(
                    title: "New Orders",
                    description: "Be notified when a user claims your listing.",
                    value: _orderReminders,
                    activeColor: colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _orderReminders = val);
                      _savePreferences();
                    },
                  ),
                  _NotificationTile(
                    title: "Messages",
                    description: "Be notified of any messages from your inbox.",
                    value: _messages,
                    activeColor: colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _messages = val);
                      _savePreferences();
                    },
                  ),
                  _NotificationTile(
                    title: "Order Confirmations",
                    description:
                        "Be notified when your counterpart marks an order as complete.",
                    value: _orderConfirmations,
                    activeColor: colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _orderConfirmations = val);
                      _savePreferences();
                    },
                  ),
                  _NotificationTile(
                    title: "Order Cancellations",
                    description:
                        "Be notified when the other party cancels an order.",
                    value: _orderCancellations,
                    activeColor: colorScheme.primary,
                    onChanged: (val) {
                      setState(() => _orderCancellations = val);
                      _savePreferences();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _NotificationTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
