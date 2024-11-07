import 'package:flutter/material.dart';
import '../screens/chatdetail_page.dart';

class ChatUsersList extends StatefulWidget {
  final String text;
  final String secondaryText;
  final String image;
  final String time;
  final bool isMessageRead;
  final Map<String, dynamic> userMap;
  final String chatdetailId, chatname, otherUserid;
  // final String chatId;
  // final String currentUserId;
  // final String otherUserId;

  ChatUsersList({
    required this.text,
    required this.secondaryText,
    required this.image,
    required this.time,
    required this.isMessageRead,
    required this.userMap,
    required this.chatdetailId,
    required this.chatname, required this.otherUserid,
    // required this.chatId,
    // required this.currentUserId,
    // required this.otherUserId,
  });

  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatScreenRoom(
            chatRoomId: widget.chatdetailId,
            chatRoomName: widget.chatname,
            otherUserId: widget.otherUserid,
            // chatId: widget.chatId,
            // currentUserId: widget.currentUserId,
            // otherUserId: widget.otherUserId,
          );
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.image),
                    maxRadius: 30,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.text),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.secondaryText,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: 12,
                  color: widget.isMessageRead
                      ? Colors.pink
                      : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
