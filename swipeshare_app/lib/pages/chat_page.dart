import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/components/chat_bubble.dart';
import 'package:swipeshare_app/components/my_text_field.dart';
import 'package:swipeshare_app/providers/user_provider.dart';
import 'package:swipeshare_app/services/chat/chat_service.dart';

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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.receiverUserEmail)),
          body: SafeArea(
            child: Column(
              children: [
                //messages
                Expanded(
                  child: _buildMessageList(userProvider.currentUser!.id),
                ),

                //userInput
                _buildMessageInput(),

                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  //build message list
  Widget _buildMessageList(String userId) {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error" + snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading..");
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document, userId))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document, String uid) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the messages based on who sent it
    var alignment = (data['senderId'] == uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: (data['senderId'] == uid)
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
