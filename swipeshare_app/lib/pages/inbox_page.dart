import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/pages/chat_page.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/order_service.dart';

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  bool _pastExpanded = true;

  final _auth = FirebaseAuth.instance;
  final _orderService = OrderService.instance;

  Widget _buildPastChatsHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _pastExpanded = !_pastExpanded),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  "Past Chats",
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  _pastExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE0E0E0),
            indent: 12,
            endIndent: 12,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final uid = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: colorScheme.onSurface,
            size: 30,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          "Inbox",
          style: textTheme.headlineMedium!.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE0E0E0)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<MealOrder>>(
        stream: _orderService.orderCol
            .where(
              Filter.or(
                Filter('buyerId', isEqualTo: uid),
                Filter('sellerId', isEqualTo: uid),
              ),
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders =
              snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

          final active =
              orders.where((o) => o.status == OrderStatus.active).toList()
                ..sort(MealOrder.bySoonest);

          final past =
              orders.where((o) => o.status != OrderStatus.active).toList()
                ..sort(
                  (a, b) => b.transactionDate.compareTo(a.transactionDate),
                );

          if (active.isEmpty && past.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "No conversations yet.\nComplete an order to start chatting!",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            );
          }

          return ListView(
            children: [
              ...active.map((o) => _InboxOrderTile(order: o, isActive: true)),
              if (past.isNotEmpty)
                _buildPastChatsHeader(context, colorScheme, textTheme),
              if (_pastExpanded)
                ...past.map((o) => _InboxOrderTile(order: o, isActive: false)),
            ],
          );
        },
      ),
    );
  }
}

class _InboxOrderTile extends StatefulWidget {
  final MealOrder order;
  final bool isActive;

  const _InboxOrderTile({required this.order, required this.isActive});

  @override
  State<_InboxOrderTile> createState() => _InboxOrderTileState();
}

class _InboxOrderTileState extends State<_InboxOrderTile> {
  late final Stream<QuerySnapshot<Message>> _lastMsgStream;

  @override
  void initState() {
    super.initState();
    _lastMsgStream = ChatService(
      widget.order.getRoomName(),
    ).chatCol.orderBy('timestamp', descending: true).limit(1).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final otherName = (uid == widget.order.sellerId)
        ? widget.order.buyerName
        : widget.order.sellerName;

    final nameColor = widget.isActive
        ? colorScheme.onSurface
        : Colors.grey.shade400;
    final textColor = widget.isActive
        ? Colors.grey.shade600
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(orderData: widget.order)),
      ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: StreamBuilder<QuerySnapshot<Message>>(
              stream: _lastMsgStream,
              builder: (context, snap) {
                final lastMsg = snap.data?.docs.firstOrNull?.data();

                final preview = lastMsg == null
                    ? ''
                    : switch (lastMsg) {
                        TextMessage m => m.content,
                        TimeProposal p => '${p.senderName} proposed a time',
                        SystemMessage m => m.content,
                      };

                final timestamp = lastMsg?.timestamp;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            otherName,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: nameColor,
                            ),
                          ),
                        ),
                        if (timestamp != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _relativeTime(timestamp),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFE0E0E0),
            indent: 12,
            endIndent: 12,
          ),
        ],
      ),
    );
  }
}
