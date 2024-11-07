import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../model/usermodel.dart';

class ChatScreenRoom extends StatefulWidget {
  final String chatRoomId, chatRoomName, otherUserId;

  ChatScreenRoom({
    required this.chatRoomName,
    required this.chatRoomId,
    required this.otherUserId,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreenRoom> createState() => _ChatScreenRoomState();
}

class _ChatScreenRoomState extends State<ChatScreenRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? chatRoomName;

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
    setChatRoomName();
  }

  Future<void> setChatRoomName() async {
    try {
      // Fetch the chat room data from Firestore
      DocumentSnapshot chatRoomSnapshot =
      await _firestore.collection('chatrooms').doc(widget.chatRoomId).get();

      if (chatRoomSnapshot.exists) {
        final data = chatRoomSnapshot.data() as Map<String, dynamic>;
        String fetchedChatRoomName = data['memberNames'][widget.otherUserId] ?? widget.chatRoomName;

        // Only update the state if the fetched name is different from the current name
        if (fetchedChatRoomName != chatRoomName) {
          setState(() {
            chatRoomName = fetchedChatRoomName;
          });
        }
      }
    } catch (e) {
      print("Error fetching chat room name: $e");
    }
  }

  Future<void> createOrUpdateChatRoom(
      String chatRoomId, String lastMessage, String lastMessageType) async {
    try {
      UserModel? currentUser = await getCurrentUserData();
      if (currentUser == null) {
        print("Current user is null");
        return;
      }

      DocumentSnapshot otherUserSnapshot =
      await _firestore.collection('users').doc(widget.otherUserId).get();
      if (!otherUserSnapshot.exists) {
        print("Other user document does not exist");
        return;
      }
      UserModel? otherUser =
      UserModel.fromMap(otherUserSnapshot.data() as Map<String, dynamic>);
      if (otherUser == null) {
        print("Failed to parse other user data");
        return;
      }

      // Check if chat room exists, if not, create it
      DocumentReference chatRoomRef =
      _firestore.collection('chatrooms').doc(chatRoomId);
      DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        // Create a new chat room document if it doesn't exist
        await chatRoomRef.set({
          'chatRoomId': chatRoomId,
          'chatRoomName': widget.chatRoomName,
          'members': [currentUser.uid, widget.otherUserId],
          'memberNames': {
            currentUser.uid: currentUser.name,
            widget.otherUserId: otherUser.name,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'unreadMessages': {
            currentUser.uid: 0,
            widget.otherUserId: 0,
          },
        });
        print("Chat room created successfully.");
      }

      // Now proceed to update the chat room with the last message
      Map<String, int> unreadMessages = {};
      if (chatRoomSnapshot.exists) {
        final data = chatRoomSnapshot.data() as Map<String, dynamic>;
        unreadMessages = data['unreadMessages'] != null
            ? Map<String, int>.from(data['unreadMessages'])
            : {};
      }

      unreadMessages[widget.otherUserId] =
      unreadMessages.containsKey(widget.otherUserId)
          ? unreadMessages[widget.otherUserId]! + 1
          : 1;

      await chatRoomRef.update({
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadMessages': unreadMessages,
      });

      print("Chat room updated successfully");
    } catch (e) {
      print("Error creating or updating chat room: $e");
    }
  }

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

  Future<void> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child("chat_images/$fileName");
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Send image message
      sendMessage(downloadUrl, "img", widget.chatRoomId);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> markMessagesAsRead() async {
    UserModel? currentUser = await getCurrentUserData();

    if (currentUser == null) return;

    await _firestore.collection('chatrooms').doc(widget.chatRoomId).update({
      'unreadMessages.${currentUser.uid}': 0,
    });
  }

  Future<int> getUnreadCount() async {
    UserModel? currentUser = await getCurrentUserData();

    if (currentUser == null) return 0;

    DocumentSnapshot chatRoomDoc =
    await _firestore.collection('chatrooms').doc(widget.chatRoomId).get();
    if (chatRoomDoc.exists) {
      final data = chatRoomDoc.data() as Map<String, dynamic>;
      return data['unreadMessages'][currentUser.uid] ?? 0;
    }
    return 0;
  }

  Future<void> updateUnreadCount(String chatRoomId, String recipientId) async {
    // Increment the unread count for the recipient
    await _firestore.collection('chatrooms').doc(chatRoomId).update({
      'unreadMessages.$recipientId': FieldValue.increment(1),
    });
  }

  Future<void> sendMessage(String content, String type, String chatRoomId) async {
    String senderId = _auth.currentUser!.uid;

    var now = DateTime.now();
    String formattedTime = DateFormat.jm().format(now);

    if (content.trim().isNotEmpty) {
      try {
        UserModel? currentUser = await getCurrentUserData();
        if (currentUser != null) {
          DocumentReference chatRef = _firestore
              .collection('chatrooms')
              .doc(chatRoomId)
              .collection('chats')
              .doc();

          DocumentSnapshot chatRoomSnapshot = await _firestore
              .collection('chatrooms')
              .doc(chatRoomId)
              .get();

          Map<String, dynamic>? chatRoomData =
          chatRoomSnapshot.data() as Map<String, dynamic>?;


          String? otherUserName =
          chatRoomData?['memberNames'][widget.otherUserId];

          Map<String, dynamic> chatData = {
            "chatId": chatRef.id,
            "sendBy": currentUser.name,
            "uid": currentUser.uid,
            "message": content,
            "type": type,
            "time": formattedTime,
            "timestamp": now,
            "members": [
              {
                "name": currentUser.name,
                "uid": currentUser.uid,
              },
              {
                "name": widget.chatRoomName, // Other user's name
                "uid": widget.otherUserId,
              }
            ]
          };

          await chatRef.set(chatData);

          // DocumentSnapshot chatRoomSnapshot = await _firestore
          //     .collection('chatrooms')
          //     .doc(chatRoomId)
          //     .get();

          if (!chatRoomSnapshot.exists) {
            // If chat room doesn't exist, create it
            await _firestore.collection('chatrooms').doc(chatRoomId).set({
              'chatRoomId': chatRoomId,
              'chatRoomName': widget.chatRoomName,
              'members': [currentUser.uid, widget.otherUserId],
              'memberNames': {
                currentUser.uid: currentUser.name,
                widget.otherUserId: widget.chatRoomName, // assuming this stores the other user's name
              },
              'createdAt': now,
              'lastMessage': content,
              'lastMessageType': type,
              'lastMessageTimestamp': now,
              'lastMessageTime': formattedTime,
              'unreadMessages': {
                currentUser.uid: 0,
                widget.otherUserId: 1, // because the other user hasn't read it yet
              },
            });
            print("Chat room created and message sent successfully.");
          } else {
            // If it exists, just update the necessary fields
            Map<String, dynamic>? chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>?;

            if (chatRoomData != null) {
              Map<String, int> unreadMessages = Map<String, int>.from(chatRoomData['unreadMessages'] ?? {});
              unreadMessages[widget.otherUserId] = (unreadMessages[widget.otherUserId] ?? 0) + 1;

              await _firestore.collection('chatrooms').doc(chatRoomId).update({
                'lastMessage': content,
                'lastMessageType': type,
                'lastMessageTimestamp': now,
                'lastMessageTime': formattedTime,
                'unreadMessages': unreadMessages,
              });
              print("Chat room updated with new message.");
            } else {
              print("Failed to fetch chat room data.");
            }
          }

          _message.clear();
          print("Message sent and chat room updated successfully.");
        } else {
          print("User not authenticated.");
        }
      } catch (e) {
        print("Error sending message: $e");
      }
    } else {
      print("Message is empty. Not sending.");
    }
  }

  void _handleSendMessage() async {
    String messageContent = _message.text.trim();

    if (messageContent.isNotEmpty) {
      await sendMessage(messageContent, "text", widget.chatRoomId);
      _message.clear();
      setState(() {}); // Force UI update
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoomName ?? widget.chatRoomName),

      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatrooms')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No Messages",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> chatMap = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;

                      return messageTile(size, chatMap);
                    },
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
      child: SizedBox(
        height: size.height / 12,
        width: size.width / 1.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height / 17,
              width: size.width / 1.3,
              child: TextField(
                controller: _message,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => pickImage(),
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
              onPressed: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await uploadImage(imageFile);
    }
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(
      builder: (_) {
        if (chatMap['type'] == "text") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Text(
                chatMap['message'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          );
        } else if (chatMap['type'] == "img") {
          return Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: chatMap['sendBy'] == _auth.currentUser!.uid
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: chatMap['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: chatMap['message'] != "" ? null : Alignment.center,
                child: chatMap['message'] != ""
                    ? Image.network(
                  chatMap['message'],
                  fit: BoxFit.cover,
                )
                    : CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
