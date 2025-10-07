import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/chat_bubble.dart';
import 'package:swipeshare_app/components/my_text_field.dart';
import 'package:swipeshare_app/models/db_user.dart';
import 'package:swipeshare_app/models/meal_order.dart';
import 'package:swipeshare_app/models/message.dart';
import 'package:swipeshare_app/services/chat_service.dart';
import 'package:swipeshare_app/services/order_service.dart';

class ChatPage extends StatefulWidget {
  final MealOrder order;
  final ChatService _chatService;

  ChatPage({super.key, required this.order})
    : _chatService = ChatService(order.id);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

enum SettingsItems { itemOne, itemTwo, itemThree }

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  SettingsItems? selectedItem;

  Future<void> sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await widget._chatService.sendTextMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DbUser>(
          future: widget._chatService.getReceivingUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (snapshot.hasError) {
              return const Text("Error");
            }
            final user = snapshot.data;
            return Text(user?.email ?? "Unknown");
          },
        ),
        actions: <Widget>[
          PopupMenuButton<SettingsItems>(
            initialValue: selectedItem,
            onSelected: (SettingsItems item) {
              setState(() {
                selectedItem = item;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SettingsItems>>[
                  PopupMenuItem<SettingsItems>(
                    value: SettingsItems.itemOne,
                    child: const Text('Report This User'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Report User'),
                            content: const Text(
                              'Are you sure you want to report this User?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  print("Reporting the person");
                                  //TODO: REPORT API GOES HERE

                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: const Text(
                                  'Report',
                                  style: TextStyle(
                                    color: Color.fromARGB(177, 96, 125, 139),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  print("Closing the Thingy");
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  PopupMenuItem<SettingsItems>(
                    value: SettingsItems.itemTwo,
                    child: Text('Block This User'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Block User'),
                            content: const Text(
                              'Are you sure you want to block this User?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  print("Blocking the person");
                                  //TODO: Block API GOES HERE
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: const Text(
                                  'Block',
                                  style: TextStyle(
                                    color: Color.fromARGB(177, 96, 125, 139),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  print("Closing the Thingy");
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  PopupMenuItem<SettingsItems>(
                    value: SettingsItems.itemThree,
                    child: Text('Cancel Order'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Cancel Order'),
                            content: const Text(
                              'Are you sure you want to Delete the Chat?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  await OrderService().cancelOrder(
                                    widget.order.id,
                                  );

                                  // Close the chat window
                                  navigator.pop();
                                  navigator.pop();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Color.fromARGB(177, 96, 125, 139),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  print("Closing the Thingy");
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close the dialog
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            //messages
            Expanded(child: _buildMessageList(user.uid)),

            //userInput
            _buildMessageInput(),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  //build message list
  Widget _buildMessageList(String userId) {
    return widget._chatService.messageStream(
      builder: (context, messages, isLoading, error) {
        if (error != null) {
          return Text("Error: ${error.toString()}");
        }

        if (isLoading) {
          return Text("Loading..");
        }

        return ListView(
          children: messages
              .map((document) => _buildMessageItem(document, userId))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(Message message, String uid) {
    //align the messages based on who sent it
    var alignment = (message.senderId == uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: (message.senderId == uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(message.senderEmail),
            const SizedBox(height: 5),
            ChatBubble(
              message: (message is TextMessage)
                  ? message.content
                  : "Time proposal not implemented yet",
              alignment: alignment,
            ),
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
