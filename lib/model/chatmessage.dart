import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Sender,
  Receiver,
}

class ChatMessage {
  String senderId;
  String receiverId;
  String message;
  Timestamp timestamp;
  MessageType type;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'type': type.toString().split('.').last, // Store as string
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
      type: MessageType.values.firstWhere((e) => e.toString() == 'MessageType.' + map['type']),
    );
  }
}
