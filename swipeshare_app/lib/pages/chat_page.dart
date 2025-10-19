import 'package:intl/intl.dart';
import 'package:swipeshare_app/components/chat_screen/chat_bubble.dart';
import 'package:swipeshare_app/components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/components/chat_screen/time_formatter.dart';
import 'package:swipeshare_app/components/my_text_field.dart'; // Add this import
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/pages/ratings_page.dart';
import 'package:swipeshare_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final MealOrder orderData;
  const ChatPage({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
    required this.orderData,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _messageController.text,
        widget.orderData,
      );
      _messageController.clear();
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
        title: Text("${widget.receiverUserName}"),
        actions: <Widget>[
          Container(
            child: Row(
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
                                    builder: (context) => RatingsPage(),
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
                ),
              ],
            ),
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
          return Text("Error" + snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..");
        }

        return ListView(
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

    //check if its a time widget proposal
    if (data['senderId'] == 'time widget') {
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
                            onTap: () {
                              print("Declined");

                              // Add your decline logic here
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
                            onTap: () {
                              print("Accepted");
                              // Add your accept logic here
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
