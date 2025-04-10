import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_setup/socket_manager/socket_manager.dart';

import 'chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  // Controller to get the text from the TextField
  final TextEditingController _controller = TextEditingController();

  // List of messages
  final List<ChatModel> _messagesList = [];

  // Function to send a message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        var messagesData = ChatModel(message: _controller.text, type: "sent");
        _sendMessageToSocket(_controller.text);
        _messagesList.add(messagesData);
        _controller.clear(); // Clear the input after sending
      });
    }
  }

  void _sendMessageToSocket(String message) {
    SocketManager.shared.sendMessage('message:$message');
  }

  void handleSocketBroadcast(String message) {
    setState(() {
      var messagesData = ChatModel(message: message, type: "received");
      _messagesList.add(messagesData);
    });
  }

  void _addBroadcastObservers() {
    FBroadcast.instance().register(
      "message_received",
      context: this,
      (value, callback) {
        handleSocketBroadcast(value as String);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _addBroadcastObservers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Displaying the messages in the chat
          Expanded(
            child: ListView.builder(
              itemCount: _messagesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _messagesList[index].message,
                    textDirection: _messagesList[index].type == 'sent'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                );
              },
            ),
          ),

          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    FBroadcast.instance().unregister(this);
  }
}
