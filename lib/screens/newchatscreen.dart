import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chatsendmodel.dart';

class NewChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;

  const NewChatScreen({Key? key, required this.chatId, required this.userId}) : super(key: key);

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = MessageModel(
        senderId: _auth.currentUser!.uid,
        text: _messageController.text.trim(),
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final chat = ChatModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
                return ListView.builder(
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final message = chat.messages[index];
                    return ListTile(
                      title: Text(message.text),
                      subtitle: Text(message.senderId),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message...',
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
}
