class ChatModel {
  String chatId;
  List<String> users;
  List<MessageModel> messages;

  ChatModel({
    required this.chatId,
    required this.users,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'users': users,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      users: List<String>.from(map['users']),
      messages: List<MessageModel>.from(
        map['messages']?.map((message) => MessageModel.fromMap(message)),
      ),
    );
  }
}

class MessageModel {
  String senderId;
  String text;
  DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
