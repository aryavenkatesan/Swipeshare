import 'package:swipeshare_app/components/chat_screen/chat_bubble.dart';
import 'package:swipeshare_app/components/chat_screen/chat_settings.dart';
import 'package:swipeshare_app/components/my_text_field.dart'; // Add this import
import 'package:swipeshare_app/pages/ratings_page.dart';
import 'package:swipeshare_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
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
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
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
                  receiverUserEmail: widget.receiverUserEmail,
                  chatService: _chatService,
                ),
              ],
            ),
          ),
        ],
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
            Text(data['senderEmail']),
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
            icon: Icon(Icons.arrow_upward, size: 40),
          ),
        ],
      ),
    );
  }
}
