import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/usermodel.dart';
import 'group_info.dart';

class GroupChatRoom extends StatelessWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> getCurrentUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  void onSendMessage(BuildContext context) async {
    UserModel? currentUser = await getCurrentUserData();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User data is null')),
      );
      return;
    }

    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": currentUser.name,
        "uid": currentUser.uid,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupInfo(
                    groupName: groupName,
                    groupId: groupChatId,
                  ),
                ),
              ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(groupChatId)
                  .collection('chats')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> chatMap =
                      snapshot.data!.docs[index].data()
                      as Map<String, dynamic>;

                      return messageTile(size, chatMap);
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          _buildMessageInput(context, size),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, Size size) {
    return Container(
      height: size.height / 10,
      width: size.width,
      alignment: Alignment.center,
      child: Container(
        height: size.height / 12,
        width: size.width / 1.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height / 17,
              width: size.width / 1.3,
              child: TextField(
                controller: _message,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.photo),
                  ),
                  hintText: "Send Message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(context)),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      String sendBy = chatMap['sendBy'] ?? 'Unknown';
      String messageType = chatMap['type'] ?? 'text';
      String message = chatMap['message'] ?? '';

      bool isSentByCurrentUser = chatMap['uid'] == _auth.currentUser?.uid;

      if (messageType == "text") {
        return Container(
          width: size.width,
          alignment: isSentByCurrentUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isSentByCurrentUser ? Colors.blue : Colors.grey,
              ),
              child: Column(
                crossAxisAlignment: isSentByCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    sendBy,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (messageType == "img") {
        return Container(
          width: size.width,
          alignment: isSentByCurrentUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              message,
            ),
          ),
        );
      } else if (messageType == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
