import 'package:chatapp/screens/startupscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../groupscreen/group_chat_screen.dart';
import '../model/usermodel.dart';
import '../screens/profile.dart';
import '../screens/settings.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blueGrey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where("uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Icon(Icons.error, color: Colors.white);
              }

              if (snapshot.hasData) {
                List<UserModel> groupData = snapshot.data!.docs
                    .map((doc) => UserModel.fromMap(doc.data()))
                    .toList();
                return UserAccountsDrawerHeader(
                  accountName: Text(groupData.first.name),
                  accountEmail: Text(groupData.first.email),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(groupData.first.imageUrl),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF19173D),
                    image: DecorationImage(
                      image: AssetImage('assets/bgimage.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            title: Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.group,
              color: Colors.white,
            ),
            title: Text(
              'Group',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => GroupChatHomeScreen(),
          ),
          ListTile(
            leading: Icon(
              Icons.description,
              color: Colors.white,
            ),
            title: Text(
              'Policies',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('App Policies'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('1. Policy 1: Description of policy 1...'),
                          SizedBox(height: 10),
                          Text('2. Policy 2: Description of policy 2...'),
                          SizedBox(height: 10),
                          Text('3. Policy 3: Description of policy 3...'),
                          // Add more policies as needed
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text(
              'Setting',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: Text(
              'Info',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Info App'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('1. Info 1: Description of policy 1...'),
                          SizedBox(height: 10),
                          Text('2. Info 2: Description of policy 2...'),
                          // Add more policies as needed
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Startupscreen()),
                      (Route<dynamic> route) => false, // This removes all previous routes.
                );
              },
            ),
          ],
        );
      },
    );
  }
}
