import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/chat_screen/chat_bubble.dart';
import 'package:swipeshare_app/components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/components/chat_screen/time_formatter.dart';
import 'package:swipeshare_app/components/my_text_field.dart';
import 'package:swipeshare_app/components/star_container.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/pages/ratings_page.dart';
import 'package:swipeshare_app/services/chat/chat_service.dart';
import 'package:swipeshare_app/services/notification_service.dart';

class ChatPage extends StatefulWidget {
  final MealOrder orderData;

  const ChatPage({super.key, required this.orderData});

  String get receiverUserName =>
      orderData.sellerId == FirebaseAuth.instance.currentUser!.uid
      ? orderData.buyerName
      : orderData.sellerName;

  String get receiverUserID =>
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
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _notifService.activeChatId = widget.orderData.getRoomName();
    _chatService
        .readNotifications(widget.orderData)
        .then((_) => _notifService.updateBadgeCount());
  }

  @override
  void dispose() {
    _notifService.activeChatId = null;
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
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
        pickedTime.toString(),
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
        leadingWidth:
            130, // This gives enough space for BackButton (48) + padding (4) + StarContainer (70)
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width: 8), BackButton()],
        ),
        title: Column(
          children: [
            Text("${widget.receiverUserName}"),
            SizedBox(height: 3),

            Transform.translate(
              offset: Offset(-2, 0), // Trust it looks off center without this
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
            // The Row is still useful for grouping these two
            children: [
              IconButton(
                onPressed: () {
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
                              Navigator.of(context).pop(); // Close the dialog
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
                                    recieverId: widget.receiverUserID,
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
                icon: const Icon(Icons.task_alt),
                tooltip: 'Close Order',
              ),

              ChatSettingsMenu(
                currentUserId: _firebaseAuth.currentUser!.uid,
                currentUserEmail: _firebaseAuth.currentUser!.email!,
                receiverUserId: widget.receiverUserID,
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
        widget.receiverUserID,
        _firebaseAuth.currentUser!.uid,
        widget.orderData,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..");
        }

        // Scroll to bottom after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isFirstLoad) {
            _scrollToBottom(animate: false);
            _isFirstLoad = false;
          } else {
            _scrollToBottom(animate: true);
          }
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //check if it's a system message
    if (data['senderId'] == "system") {
      return Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
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
                      data['receiverId'] == widget.receiverUserID
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
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
