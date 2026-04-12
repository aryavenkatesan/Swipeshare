import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_dialog.dart';
import 'package:swipeshare_app/components/adaptive/adaptive_time_picker.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/ratings_bottom_sheet.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/old_components/chat_screen/chat_bubble.dart';
import 'package:swipeshare_app/old_components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/old_components/star_container.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/services/order_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/profanity_utils.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class ChatPage extends StatefulWidget {
  final MealOrder orderData;

  const ChatPage({super.key, required this.orderData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatService _chatService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationService _notifService = NotificationService.instance;
  final ScrollController _scrollController = ScrollController();

  MealOrder? _liveOrder;
  StreamSubscription<MealOrder>? _orderSub;
  bool _barVisible = true;

  MealOrder get _order => _liveOrder ?? widget.orderData;

  ColorScheme get _colors => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    _notifService.activeChatId = widget.orderData.getRoomName();
    _chatService = ChatService(widget.orderData.getRoomName());
    _chatService.readNotifications();
    _orderSub = _chatService.orderStream.listen((order) {
      if (mounted) setState(() => _liveOrder = order);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    _notifService.activeChatId = null;
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    final isSticky = _order.them.markedComplete && !_order.me.markedComplete;
    if (isSticky) return;

    if (direction == ScrollDirection.forward && _barVisible) {
      setState(() => _barVisible = false);
    } else if (direction == ScrollDirection.reverse && !_barVisible) {
      setState(() => _barVisible = true);
    }
  }

  bool _buildBarVisible() {
    final order = _order;
    if (order.status != OrderStatus.active) return false;
    final isSticky = order.them.markedComplete && !order.me.markedComplete;
    return _barVisible || isSticky;
  }

  Future<void> _onMarkComplete() async {
    final confirmed = await AdaptiveDialog.showConfirmation(
      context: context,
      title: 'Mark as Complete',
      content: 'Confirm that the transaction was completed in person.',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
    );

    if (confirmed != true || !mounted) return;

    final order = _order;
    await safeVibrate(HapticsType.heavy);
    await OrderService.instance.markComplete(
      order.getRoomName(),
      order.currentUserRole,
    );

    if (!mounted) return;
    RatingsBottomSheet.show(context, [order]);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void sendTextMessage() async {
    //check profanity
    if (ProfanityUtils.hasProfanity(_messageController.text)) {
      await safeVibrate(HapticsType.error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SnackbarMessages.profanityInMessage),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
          ),
        );
      }
      return;
    }

    //send message
    if (_messageController.text.isNotEmpty) {
      await safeVibrate(HapticsType.medium);
      await _chatService.sendTextMessage(_messageController.text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void sendTimePicker() async {
    TimeOfDay? pickedTime = await AdaptiveTimePicker.showAdaptiveTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "Propose a time to meet",
      confirmText: "Send",
    );

    if (pickedTime != null) {
      await _chatService.sendTimeProposal(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        toolbarHeight: 72,
        centerTitle: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width: 8), BackButton()],
        ),
        title: Column(
          children: [
            FittedBox(fit: BoxFit.scaleDown, child: Text(order.them.name)),
            SizedBox(height: 3),
            Transform.translate(
              offset: Offset(-2, 0),
              child: StarContainer(stars: order.them.stars, background: false),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            children: [
              ChatSettingsMenu(chatService: _chatService, orderData: order),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(
              alpha: 0.3,
            ), // Customize color as needed
            height: 1.0,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Stack(
            children: [
              //messages + input always fill full height
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: _buildBarVisible() ? 56.0 : 0.0,
                  ),
                  Expanded(child: _buildMessageList()),
                  _buildMessageInput(),
                  SizedBox(height: 10),
                ],
              ),

              //complete bar slides up behind the AppBar when hidden
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: AnimatedSlide(
                    offset: _buildBarVisible()
                        ? Offset.zero
                        : const Offset(0, -1),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _buildCompleteBar(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteBar() {
    final order = _order;
    if (order.status != OrderStatus.active) return const SizedBox.shrink();

    final myMarked = order.me.markedComplete;
    final theyMarked = order.them.markedComplete;

    final buttonStyle = TextButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.grey.withValues(alpha: 0.12),
    );
    final buttonTextStyle = _textTheme.labelLarge?.copyWith(
      fontSize: 16,
      color: _colors.primary,
    );

    Widget actionArea;
    if (!myMarked && !theyMarked) {
      // State 1: neither confirmed
      actionArea = TextButton(
        onPressed: _onMarkComplete,
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark Complete', style: buttonTextStyle),
            const SizedBox(width: 6),
            Icon(Icons.thumb_up_alt_outlined, size: 16, color: _colors.primary),
          ],
        ),
      );
    } else if (myMarked && !theyMarked) {
      // State 2: I confirmed, waiting for them
      actionArea = Text(
        'Waiting for ${order.them.name}...',
        style: _textTheme.bodyMedium?.copyWith(
          color: SwipeshareColors.cardAccent,
        ),
      );
    } else if (theyMarked && !myMarked) {
      // State 3: they confirmed, I haven't (sticky)
      actionArea = TextButton(
        onPressed: _onMarkComplete,
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm Complete', style: buttonTextStyle),
            const SizedBox(width: 4),
            Icon(Icons.check, size: 16, color: _colors.primary),
          ],
        ),
      );
    } else {
      // State 4: both confirmed — order.status will become completed via Cloud Function
      return const SizedBox.shrink();
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _colors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${order.price.toStringAsFixed(2)}',
            style: _textTheme.bodyMedium,
          ),
          actionArea,
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.chatCol
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("An error occured. Please close and reopen the app to try again.");
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reversedDocs = snapshot.data!.docs.reversed
            .map((snapshot) => snapshot.data())
            .toList();

        return RefreshIndicator(
          onRefresh: () async => _chatService.readNotifications(),
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: reversedDocs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: 14);
              }

              final previousMessage = index < reversedDocs.length
                  ? reversedDocs[index]
                  : null;

              final message = reversedDocs[index - 1];
              return switch (message) {
                SystemMessage() => _buildSystemMessage(message),
                TimeProposal() => _buildTimeProposal(message),
                TextMessage() => _buildTextMessage(message, previousMessage),
              };
            },
          ),
        );
      },
    );
  }

  Widget _buildSystemMessage(SystemMessage message) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.10;
    return Column(
      children: [
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              message.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.56,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeProposal(TimeProposal proposal) {
    final bool isSent = proposal.senderId == _firebaseAuth.currentUser!.uid;
    final String timeString = TimeFormatter.formatTimeOfDayString(
      TimeFormatter.productionToString(proposal.proposedTime),
    );

    final textTheme = Theme.of(context).textTheme;

    Widget bottomSection;
    if (proposal.status != ProposalStatus.pending) {
      final String statusText = switch (proposal.status) {
        ProposalStatus.accepted => "Accepted",
        ProposalStatus.declined => "Declined",
        ProposalStatus.pending => "",
      };
      final Color statusColor = proposal.status == ProposalStatus.accepted
          ? SwipeshareColors.primary
          : SwipeshareColors.cardAccent;
      bottomSection = Text(
        statusText,
        textAlign: TextAlign.center,
        style: textTheme.bodyLarge?.copyWith(color: statusColor),
      );
    } else if (isSent) {
      // Pending, sent by us
      bottomSection = Text(
        "Pending...",
        textAlign: TextAlign.center,
        style: textTheme.bodyLarge?.copyWith(
          color: SwipeshareColors.cardAccent,
        ),
      );
    } else {
      // Pending, received — show Accept + Decline
      bottomSection = Column(
        children: [
          GestureDetector(
            onTap: () async {
              await _chatService.updateTimeProposal(
                proposal.id,
                ProposalStatus.accepted,
              );
            },
            child: Container(
              width: 108,
              height: 28,
              decoration: BoxDecoration(
                color: SwipeshareColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                "Accept",
                style: textTheme.bodyLarge?.copyWith(
                  color: SwipeshareColors.onPrimary,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              await _chatService.updateTimeProposal(
                proposal.id,
                ProposalStatus.declined,
              );
            },
            child: Text(
              "Decline",
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                color: SwipeshareColors.cardAccent,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Container(
              width: 212,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2ECF9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Time Proposal:",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  SizedBox(height: isSent ? 13 : 8),
                  Text(
                    timeString,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(fontSize: 32),
                  ),
                  SizedBox(height: 8),
                  bottomSection,
                  SizedBox(height: 4),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(TextMessage message, Message? previousMessage) {
    //align the messages based on who sent it
    var alignment = (message.senderId == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final bool showSenderName =
        previousMessage == null ||
        (previousMessage is! TextMessage) ||
        (previousMessage.senderId != message.senderId);

    final double maxBubbleWidth = MediaQuery.of(context).size.width * 0.85;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
          child: Column(
            crossAxisAlignment:
                (message.senderId == _firebaseAuth.currentUser!.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (showSenderName) Text(message.senderName),
              if (showSenderName) SizedBox(height: 5),
              ChatBubble(message: (message.content), alignment: alignment),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    if (_order.status != OrderStatus.active) {
      return Container(
        // width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Text(
          "This conversation has finished or been cancelled.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        ),
      );
    }

    final double vw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.01),
      child: Row(
        children: [
          // time widget
          IconButton(
            onPressed: sendTimePicker,
            icon: Icon(Icons.more_time, size: 30),
          ),

          // textfield
          Expanded(child: _buildAdaptiveTextField()),

          // send button
          IconButton(
            onPressed: sendTextMessage,
            icon: Icon(Icons.arrow_upward, size: 35),
          ),
        ],
      ),
    );
  }

  /// Builds a platform-adaptive text field
  /// CupertinoTextField on iOS, Material TextField on Android
  Widget _buildAdaptiveTextField() {
    final textStyle = GoogleFonts.instrumentSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    final placeholderStyle = GoogleFonts.instrumentSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    );

    if (AdaptiveTimePicker.useCupertino) {
      // iOS: CupertinoTextField for native look
      return CupertinoTextField(
        controller: _messageController,
        placeholder: "Enter Message",
        style: textStyle,
        placeholderStyle: placeholderStyle,
        minLines: 1,
        maxLines: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(11, 3, 168, 244),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      // Android: Material TextField
      return TextField(
        controller: _messageController,
        obscureText: false,
        minLines: 1,
        maxLines: 5,
        style: textStyle,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: const Color.fromARGB(11, 3, 168, 244),
          filled: true,
          hintText: "Enter Message",
          hintStyle: placeholderStyle,
        ),
      );
    }
  }
}
