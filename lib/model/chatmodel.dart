class ChatUsers {
  String text;
  String secondaryText;
  String image;
  String time;
  final Map<String, dynamic> userMap;
  final String chatdetailId;

  ChatUsers({
    required this.text,
    required this.secondaryText,
    required this.image,
    required this.time,
    required this.chatdetailId,
    required this.userMap,
  });
}
