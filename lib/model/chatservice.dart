import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatmessage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(ChatMessage chatMessage) async {
    await _firestore.collection('chats').add(chatMessage.toMap());
  }

  Stream<List<ChatMessage>> getMessages(String senderId, String receiverId) {
    return _firestore
        .collection('chats')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<ChatMessage> messages = [];
      query.docs.forEach((doc) {
        messages.add(ChatMessage.fromMap(doc.data() as Map<String, dynamic>));
      });
      return messages;
    });
  }
}
