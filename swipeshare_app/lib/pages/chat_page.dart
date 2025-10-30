import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/chat_screen/chat_bubble.dart';
import 'package:swipeshare_app/components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/components/my_text_field.dart';
import 'package:swipeshare_app/components/star_container.dart';
import 'package:swipeshare_app/components/time_formatter.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/pages/ratings_page.dart';
import 'package:swipeshare_app/services/chat/chat_service.dart';
import 'package:swipeshare_app/services/notification_service.dart';
import 'package:swipeshare_app/utils/profanity_utils.dart';

class ChatPage extends StatefulWidget {
  final MealOrder orderData;

  const ChatPage({super.key, required this.orderData});

  String get receiverUserName =>
      orderData.sellerId == FirebaseAuth.instance.currentUser!.uid
      ? orderData.buyerName
      : orderData.sellerName;

  String get receiverUserId =>
      orderData.sellerId == FirebaseAuth.instance.currentUser!.uid
      ? orderData.buyerId
      : orderData.sellerId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationService _notifService = NotificationService.instance;
  final ScrollController _scrollController = ScrollController();

  bool _isChatDeleted = false;

  @override
  void initState() {
    super.initState();
    _isChatDeleted = widget.orderData.isChatDeleted;
    _notifService.activeChatId = widget.orderData.getRoomName();
    _chatService
        .readNotifications(widget.orderData)
        .then((_) => _notifService.updateBadgeCount());
    _listenToOrderChanges();
  }

  void _listenToOrderChanges() {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderData.getRoomName())
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists && mounted) {
            final data = snapshot.data();
            if (data != null && data['isChatDeleted'] != null) {
              setState(() {
                _isChatDeleted = data['isChatDeleted'];
              });
            }
          }
        });
  }

  @override
  void dispose() {
    _notifService.activeChatId = null;
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
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

  void sendMessage() async {
    //check profanity
    if (ProfanityUtils.hasProfanity(_messageController.text)) {
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.error);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Message contains profanity, please change.")),
        );
      }
      return;
    }

    //send message
    if (_messageController.text.isNotEmpty) {
      if (await Haptics.canVibrate()) {
        Haptics.vibrate(HapticsType.medium);
      }
      await _chatService.sendMessage(
        widget.receiverUserId,
        _messageController.text,
        widget.orderData,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void sendTimePicker() async {
    //send a popup to select the time, have cancel and send buttons
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Change the purple color (selected time, buttons, etc.)
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(168, 81, 142, 248),
              surface: const Color.fromARGB(255, 241, 241, 241),
              onSurface: Colors.black,
            ),
            // Button colors
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Cancel/Send button color
              ),
            ),
          ),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.inputOnly,
      helpText: "What time would you like to propose?",
      barrierColor: const Color.fromARGB(142, 72, 81, 97),
    );

    if (pickedTime != null) {
      await _chatService.timeWidget(
        widget.orderData.getRoomName(),
        TimeFormatter.productionToString(pickedTime),
      );
    }
  }
  //if sent go to chat_service and post a thingy
  //yada yada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        leadingWidth: 130,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width: 8), BackButton()],
        ),
        title: Column(
          children: [
            Text(widget.receiverUserName),
            SizedBox(height: 3),
            Transform.translate(
              offset: Offset(-2, 0),
              child: StarContainer(
                stars:
                    _firebaseAuth.currentUser!.uid != widget.orderData.buyerId
                    ? widget.orderData.buyerStars
                    : widget.orderData.sellerStars,
                background: false,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                onPressed: _isChatDeleted
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Close Order'),
                              content: const Text(
                                'Are you sure you want to mark this order as complete? This action cannot be undone.',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RatingsPage(
                                          recieverId: widget.receiverUserId,
                                          orderData: widget.orderData,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Color.fromARGB(177, 96, 125, 139),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                icon: Icon(
                  Icons.task_alt,
                  color:
                      _isChatDeleted // ⭐ Use the state variable instead
                      ? Colors.grey
                      : null,
                ),
                tooltip:
                    _isChatDeleted // ⭐ Use the state variable instead
                    ? 'Order already closed'
                    : 'Close Order',
              ),
              ChatSettingsMenu(
                currentUserId: _firebaseAuth.currentUser!.uid,
                currentUserEmail: _firebaseAuth.currentUser!.email!,
                receiverUserId: widget.receiverUserId,
                receiverUserName: widget.receiverUserName,
                chatService: _chatService,
                orderData: widget.orderData,
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.3), // Customize color as needed
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //messages
            Expanded(child: _buildMessageList()),

            //userInput
            _buildMessageInput(),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserId,
        _firebaseAuth.currentUser!.uid,
        widget.orderData,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reversedDocs = snapshot.data!.docs.reversed.toList();

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // to add padding for last message
          itemCount: reversedDocs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SizedBox(height: 14);
              //adding padding for the very last message
            }

            final doc = reversedDocs[index - 1];
            return _buildMessageItem(doc);
          },
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.10;

    //check if it's a system message
    if (data['senderId'] == "system") {
      return Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                data['message'],
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
          SizedBox(height: 32),
        ],
      );
    }

    if (data['senderId'] == 'time widget') {
      Message messageWithDocId = Message.fromFirestore(document);

      String statusString = '';

      if (messageWithDocId.status == 'accepted') {
        statusString = 'the time was accepted';
      } else if (messageWithDocId.status == 'declined') {
        statusString = 'the time was declined';
      } //figuring out statusString string here so that we can avoid another conditional in the return statement

      return Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Column(
              children: [
                // Main message
                Text(
                  "${data['senderName']} proposes this time: ${TimeFormatter.formatTimeOfDay(data['message'])}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.56,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 12),
                statusString != ''
                    //if the propsal was accepted or declined, show that here
                    ? Text(
                        statusString,
                        style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.56,
                          decoration: TextDecoration.none,
                        ),
                      )
                    :
                      // Decline and Accept buttons
                      data['receiverId'] == widget.receiverUserId
                    // data['receiverID'] is the sender's id of the time widget
                    //ik its confusing
                    //if the sender id != the receiver id
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          // Decline button
                          GestureDetector(
                            onTap: () async {
                              print("Declined");

                              await _chatService.updateTimeWidgetStatus(
                                widget.orderData,
                                messageWithDocId.documentId!,
                                'declined',
                                'n/a',
                              );
                            },
                            child: Text(
                              "Decline",
                              style: TextStyle(
                                color: Colors.blueGrey[300],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          SizedBox(width: 24), // Space between buttons
                          // Accept button
                          GestureDetector(
                            onTap: () async {
                              print("Accepted");
                              // Add your accept logic here
                              await _chatService.updateTimeWidgetStatus(
                                widget.orderData,
                                messageWithDocId.documentId!,
                                'accepted',
                                data['message'],
                              );
                            },
                            child: Text(
                              "Accept",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "wating for response....",
                        style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.56,
                          decoration: TextDecoration.none,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      );
    }

    //align the messages based on who sent it
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(data['senderName']),
            const SizedBox(height: 5),
            ChatBubble(message: (data['message']), alignment: alignment),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    final double vw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.01),
      child: Row(
        children: [
          //time widget
          IconButton(
            onPressed: sendTimePicker,
            icon: Icon(Icons.lock_clock_outlined, size: 30),
          ),

          //textfield
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Enter Message",
              obscureText: false,
            ),
          ),

          //send button
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.arrow_upward, size: 35),
          ),
        ],
      ),
    );
  }
}
