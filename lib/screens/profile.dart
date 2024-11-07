import 'package:chatapp/screens/profilescreen.dart';
import 'package:flutter/material.dart';

import '../groupscreen/group_chat_screen.dart';
import 'home.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (_selectedIndex == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChatHomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          BottomNavigationBarItem(icon: Icon(Icons.message),label: 'Chat', ),
          BottomNavigationBarItem(icon: Icon(Icons.group),label: 'Group', ),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),label: 'Profile', activeIcon: Icon(Icons.account_circle_rounded)),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: ProfileScreen(),
    );  }
}
