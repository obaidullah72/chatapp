import 'package:chatapp/groupscreen/group_chat_screen.dart';
import 'package:chatapp/screens/chatdetail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/navbar.dart';
import '../screens/profile.dart';
import 'chatusernewlist.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List chatList = [];
  List searchResults = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getAvailableChats();
  }

  void getAvailableChats() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .get()
        .then((value) {
      setState(() {
        chatList = value.docs;
        isLoading = false;
      });
    });
  }

  void searchUserByEmail(String email) async {
    // setState(() {
    //   isLoading = true;
    // });

    await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      setState(() {
        searchResults = value.docs;
        isLoading = false;
      });
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GroupChatHomeScreen()));
      } else if (_selectedIndex == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
            activeIcon: Icon(Icons.message_rounded),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Group'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      drawer: NavBarWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chats',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Search by email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                      if (value.isNotEmpty) {
                        searchUserByEmail(value);
                      } else {
                        setState(() {
                          searchResults.clear();
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: searchQuery.isNotEmpty && searchResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                String otherUserId =
                                    searchResults[index]['uid'];
                                String chatRoomId = createChatRoomId(
                                    _auth.currentUser!.uid, otherUserId);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreenRoom(
                                      chatRoomId: chatRoomId,
                                      chatRoomName: searchResults[index]
                                          ['name'],
                                      otherUserId: otherUserId,
                                    ),
                                  ),
                                );
                              },
                              leading: Icon(Icons.account_circle),
                              title: Text(searchResults[index]['name']),
                              subtitle: Text(searchResults[index]['email']),
                            );
                          },
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chatrooms')
                              .where('members',
                                  arrayContains: _auth.currentUser?.uid)
                              .orderBy('lastMessageTimestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'An error occurred: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No chats available'));
                            } else {
                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> chatRoomMap =
                                      snapshot.data!.docs[index].data()
                                          as Map<String, dynamic>;

                                  String chatRoomName =
                                      chatRoomMap['name'] ?? 'Unknown';
                                  String lastMessage =
                                      chatRoomMap['lastMessage'] ??
                                          'No Message';
                                  String lastMessageType =
                                      chatRoomMap['lastMessageType'] ?? 'text';
                                  String profileImageUrl =
                                      chatRoomMap['imageUrl'] ?? 'No Image';

                                  // Safely access the unreadMessages map
                                  int unreadCount =
                                      chatRoomMap['unreadMessages']
                                              ?[currentUserId] ??
                                          0;

                                  // Determine the other user's display name
                                  String otherUserId =
                                      chatRoomMap['members'].firstWhere(
                                    (member) => member != currentUserId,
                                    orElse: () => 'Unknown',
                                  );
                                  String displayName =
                                      chatRoomMap['memberNames']
                                              ?[otherUserId] ??
                                          'Unknown';

                                  return Dismissible(
                                    key: Key(chatRoomMap['chatRoomId']),
                                    direction: DismissDirection.startToEnd,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete Chat'),
                                          content: Text(
                                              'Are you sure you want to delete this chat?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) {
                                      deleteChat(chatRoomMap['chatRoomId']);
                                    },
                                    child: ListTile(
                                      leading: Stack(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: profileImageUrl
                                                    .isNotEmpty
                                                ? NetworkImage(profileImageUrl)
                                                : null,
                                            child: profileImageUrl.isEmpty
                                                ? Icon(Icons.person)
                                                : null,
                                          ),
                                          if (unreadCount > 0)
                                            Positioned(
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '$unreadCount',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      title: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontWeight: unreadCount > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(
                                        lastMessageType == "img"
                                            ? "[Image]"
                                            : lastMessage,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: unreadCount > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: Text(
                                        chatRoomMap['lastMessageTime'] ?? '',
                                        // Use formatted time here
                                        style: TextStyle(
                                          fontWeight: unreadCount > 0
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatScreenRoom(
                                              chatRoomId:
                                                  chatRoomMap['chatRoomId'],
                                              chatRoomName:
                                                  chatRoomMap['chatRoomName'],
                                              otherUserId: otherUserId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AllUsersScreen()),
          );
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  String createChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  void deleteChat(String chatRoomId) async {
    await _firestore.collection('chatrooms').doc(chatRoomId).delete();
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
