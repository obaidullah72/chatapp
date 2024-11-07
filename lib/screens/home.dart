import 'package:chatapp/groupscreen/group_chat_screen.dart';
import 'package:chatapp/screens/chatpage.dart';
import 'package:chatapp/screens/profile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChatHomeScreen()));
      } else if (_selectedIndex == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.blueGrey,
      //   unselectedItemColor: Colors.black,
      //   selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      //   unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.message),label: 'Chat', activeIcon: Icon(Icons.message_rounded)),
      //     BottomNavigationBarItem(icon: Icon(Icons.group),label: 'Group'),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: 'Profile'),
      //   ],
      //   currentIndex: _selectedIndex,
      //
      //   onTap: _onItemTapped,
      // ),
      body: ChatHomeScreen(),
    );
  }
}
