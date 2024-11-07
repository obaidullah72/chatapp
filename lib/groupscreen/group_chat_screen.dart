
import 'package:chatapp/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/navbar.dart';
import '../screens/profile.dart';
import 'create_group/add_members.dart';
import 'group_chat_room.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (_selectedIndex == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
          BottomNavigationBarItem(icon: Icon(Icons.message),label: 'Chat',),
          BottomNavigationBarItem(icon: Icon(Icons.group),label: 'Group',activeIcon: Icon(Icons.group_rounded)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: 'Profile'),
        ],
        currentIndex: _selectedIndex,

        onTap: _onItemTapped,
      ),
      drawer: NavBarWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SafeArea(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Groups',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      // String otherUserId = 'otherUserId';
                      // _startNewChat(otherUserId);  // Assuming otherUserId is defined
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueGrey,
                      ),
                      padding:
                      EdgeInsets.only(left: 8, right: 8, bottom: 2, top: 2),
                      height: 30,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'New',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupChatRoom(
                        groupName: groupList[index]['name'],
                        groupChatId: groupList[index]['id'],
                      ),
                    ),
                  ),
                  leading: Icon(Icons.group),
                  title: Text(groupList[index]['name']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ),
    );
  }
}
