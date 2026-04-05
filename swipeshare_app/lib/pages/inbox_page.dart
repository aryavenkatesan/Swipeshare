import 'dart:async';

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
  final _auth = FirebaseAuth.instance;
  final _orderService = OrderService.instance;

  List<MealOrder> _activeOrders = [];
  List<MealOrder> _pastOrders = [];
  bool _loading = true;
  Object? _error;

  // Tracks the latest message timestamp per chat room for sorting.
  final Map<String, DateTime?> _lastMsgTimes = {};
  final Map<String, StreamSubscription<QuerySnapshot<Message>>> _msgSubs = {};
  StreamSubscription<QuerySnapshot<MealOrder>>? _ordersSub;

  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser!.uid;
    _ordersSub = _orderService.orderCol
        .where(
          Filter.or(
            Filter('buyer.id', isEqualTo: uid),
            Filter('seller.id', isEqualTo: uid),
          ),
        )
        .snapshots()
        .listen(
          (snapshot) {
            final orders = snapshot.docs.map((doc) => doc.data()).toList();

            final active = orders
                .where((o) => o.status == OrderStatus.active)
                .toList();

            final past =
                orders.where((o) => o.status != OrderStatus.active).toList()
                  ..sort(
                    (a, b) => b.transactionDate.compareTo(a.transactionDate),
                  );

            // Set up per-room message subscriptions so we can sort by
            // most-recent activity whenever Firebase delivers a new message.
            _syncMsgSubscriptions(active);

            if (mounted) {
              setState(() {
                _activeOrders = active;
                _pastOrders = past;
                _loading = false;
              });
            }
          },
          onError: (e) {
            if (mounted) setState(() => _error = e);
          },
        );
  }

  /// Keeps `_msgSubs` in sync with the current set of active orders.
  /// Cancels subscriptions for orders that are no longer active and
  /// subscribes to any newly active rooms.
  void _syncMsgSubscriptions(List<MealOrder> activeOrders) {
    final activeRooms = {for (final o in activeOrders) o.getRoomName()};

    // Drop subscriptions for rooms that are no longer active.
    for (final room in _msgSubs.keys.toList()) {
      if (!activeRooms.contains(room)) {
        _msgSubs.remove(room)?.cancel();
        _lastMsgTimes.remove(room);
      }
    }

    // Subscribe to any new active rooms.
    for (final order in activeOrders) {
      final room = order.getRoomName();
      if (_msgSubs.containsKey(room)) continue;
      _msgSubs[room] = ChatService(room).chatCol
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((snap) {
            if (!mounted) return;
            setState(() {
              _lastMsgTimes[room] = snap.docs.firstOrNull?.data().timestamp;
            });
          });
    }
  }

  /// Active orders sorted by most-recent message descending.
  /// Falls back to meal-time order when no messages exist yet.
  List<MealOrder> get _sortedActiveOrders {
    final sorted = List<MealOrder>.from(_activeOrders);
    sorted.sort((a, b) {
      final ta = _lastMsgTimes[a.getRoomName()];
      final tb = _lastMsgTimes[b.getRoomName()];
      if (ta == null && tb == null) return MealOrder.bySoonest(a, b);
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });
    return sorted;
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    for (final sub in _msgSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _buildBody(colorScheme, textTheme);
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final active = _sortedActiveOrders;
    final past = _pastOrders;

    if (active.isEmpty && past.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "No conversations yet.\nComplete an order to start chatting!",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium!.copyWith(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: 6,
          ),
          child: Text("Active Chats", style: textTheme.titleMedium),
        ),

        if (active.isNotEmpty) ...[
          Divider(
            height: 1,
            color: const Color(0xFFE0E0E0),
            indent: 12,
            endIndent: 12,
          ),
          ...active.map(
            (o) => _InboxOrderTile(
              key: ValueKey(o.getRoomName()),
              order: o,
              isActive: true,
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              "No active chats. Start an order to start chatting!",
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
        Divider(
          height: 1,
          color: const Color(0xFFE0E0E0),
          indent: 12,
          endIndent: 12,
        ),
        if (past.isNotEmpty)
          ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: colorScheme.onSurface,
            collapsedIconColor: colorScheme.onSurface,
            title: Text("Past Chats", style: textTheme.titleMedium),
            children: past
                .map(
                  (o) => _InboxOrderTile(
                    key: ValueKey(o.getRoomName()),
                    order: o,
                    isActive: false,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _InboxOrderTile extends StatefulWidget {
  final MealOrder order;
  final bool isActive;

  const _InboxOrderTile({
    super.key,
    required this.order,
    required this.isActive,
  });

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

    final otherName = widget.order.them.name;

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
