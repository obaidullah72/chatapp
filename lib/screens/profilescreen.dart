import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/usermodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Profiles'),
            Icon(
              Icons.search,
              color: Colors.white,
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
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
                return Icon(Icons.error, color: Colors.red);
              }

              if (snapshot.hasData) {
                List<UserModel> groupData = snapshot.data!.docs
                    .map((doc) => UserModel.fromMap(doc.data()))
                    .toList();

                UserModel userData = groupData.first;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(userData.imageUrl),
                          maxRadius: 30,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData.name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            userData.email ?? 'Email',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 15.0),
          //   child: Row(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 20.0, right: 20),
          //         child: CircleAvatar(
          //           backgroundImage: AssetImage('assets/logo.png'),
          //           maxRadius: 30,
          //         ),
          //       ),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Username',
          //             style: TextStyle(
          //                 fontSize: 20, fontWeight: FontWeight.bold),
          //           ),
          //           SizedBox(
          //             height: 5,
          //           ),
          //           Text(
          //             'About Us',
          //             style: TextStyle(fontSize: 16),
          //           ),
          //
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Divider(),
          ListTile(
            onTap: () => _showaccountscreen(context),
            leading: Icon(Icons.key),
            title: Text('Accounts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Security Notifications, Change Numbers',
                style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            onTap: () => _notificationscreen(context),
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Message, Groups, Call tones',
                style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            onTap: () => _showLanguageDrawer(context),
            leading: Icon(Icons.language_outlined),
            title: Text('App Languages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('English (device language)',
                style: TextStyle(fontSize: 12)),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help Center',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Help Center, Contact Us, Privacy Policy',
                style: TextStyle(fontSize: 12)),
            onTap: () => _showHelpCenterBottomSheet(context),
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Invite a friend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // Add onTap functionality if needed
          ),
          ListTile(
            leading: Icon(Icons.security_update_good_outlined),
            title: Text('App Updates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onTap: () => _showAppUpdatesBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _showLanguageDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LanguageDrawer();
      },
    );
  }

  void _showHelpCenterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return HelpCenterScreen(); // Convert to a proper widget
      },
    );
  }

  void _showAppUpdatesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AppUpdatesScreen(); // Convert to a proper widget
      },
    );
  }

  void _showaccountscreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AccountsScreen(); // Convert to a proper widget
      },
    );
  }

  void _notificationscreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NotificationsScreen(); // Convert to a proper widget
      },
    );
  }
}

class AccountsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: ()=> _showAccountDetailsDialog(context),
          child: Text('Account Settings'),
        ),
      ),
    );
  }

  void _showAccountDetailsDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred. Please try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            }

            if (snapshot.hasData) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;

              _nameController.text = userData['name'] ?? '';
              _emailController.text = userData['email'] ?? '';
              _phoneController.text = userData['phoneNumber'] ?? '';

              return AlertDialog(
                title: Text('Edit Account Details'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundImage:
                          NetworkImage(userData['imageUrl'] ?? ''),
                          radius: 40,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Save'),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .update({
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'phoneNumber': _phoneController.text,
                      }).then((value) {
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              );
            }
            return Container();
          },
        );
      },
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  bool _notificationsEnabled = true;
  String _selectedRingtone = 'Default Ringtone';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            _showNotificationSettingsModalSheet(context);
          },
          child: Text('Change Notification Settings'),
        ),
      ),
    );
  }

  void _showNotificationSettingsModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              height: 300, // Adjust the height as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Settings',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications'),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Ringtone'),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedRingtone,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRingtone = newValue!;
                        print('Dropdown selected: $_selectedRingtone'); // Debugging print
                        _playRingtone(newValue);
                      });
                    },
                    items: <String>[
                      'Default Ringtone',
                      'Ringtone 1',
                      'Ringtone 2',
                      'Ringtone 3'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Save'),
                        onPressed: () {
                          // Save settings logic here
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _playRingtone(String ringtone) async {
    String path = '';

    switch (ringtone) {
      case 'Default Ringtone':
        path = '';
        break;
      case 'Ringtone 1':
        path = 'audio/Champion.mp3';
        break;
      case 'Ringtone 2':
        path = 'audio/Winner.mp3';
        break;
      case 'Ringtone 3':
        path = 'audio/Sea.mp3';
        break;
    }

    // Debugging prints
    print('Selected Ringtone: $ringtone');
    print('Path: $path');

    if (path.isNotEmpty) {
      await _audioPlayer.stop(); // Stop any currently playing audio
      print('Stopped any currently playing audio.');

      await _audioPlayer.play(AssetSource(path));
      // print('AudioPlayer play result: $result');
    } else {
      print('Path is empty, not playing any ringtone.');
    }
  }
}


// class NotificationsScreen extends StatelessWidget {
//   bool _notificationsEnabled = true;
//   String _selectedRingtone = 'Default Ringtone';
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _showNotificationSettingsModalSheet(context);
//           },
//           child: Text('Change Notification Settings'),
//         ),
//       ),
//     );
//   }
//
//   void _showNotificationSettingsModalSheet(BuildContext context) {
//     bool _notificationsEnabled = true;
//     String _selectedRingtone = 'Default Ringtone';
//
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: EdgeInsets.all(16.0),
//               height: 300, // Adjust the height as needed
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Notification Settings',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                   Divider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Notifications'),
//                       Switch(
//                         value: _notificationsEnabled,
//                         onChanged: (value) {
//                           setState(() {
//                             _notificationsEnabled = value;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Text('Ringtone'),
//                   SizedBox(height: 10),
//                   DropdownButton<String>(
//                     value: _selectedRingtone,
//                     isExpanded: true,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedRingtone = newValue!;
//                       });
//                     },
//                     items: <String>[
//                       'Default Ringtone',
//                       'Ringtone 1',
//                       'Ringtone 2',
//                       'Ringtone 3'
//                     ].map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                   Spacer(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         child: Text('Cancel'),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                       TextButton(
//                         child: Text('Save'),
//                         onPressed: () {
//                           // Save settings logic here
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// void _showNotificationSettingsDialog(BuildContext context) {
//   bool _notificationsEnabled = true;
//   String _selectedRingtone = 'Default Ringtone';
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text('Notification Settings'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Notifications'),
//                       Switch(
//                         value: _notificationsEnabled,
//                         onChanged: (value) {
//                           setState(() {
//                             _notificationsEnabled = value;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   Text('Ringtone'),
//                   SizedBox(height: 10),
//                   DropdownButton<String>(
//                     value: _selectedRingtone,
//                     isExpanded: true,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedRingtone = newValue!;
//                       });
//                     },
//                     items: <String>[
//                       'Default Ringtone',
//                       'Ringtone 1',
//                       'Ringtone 2',
//                       'Ringtone 3'
//                     ].map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('Cancel'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: Text('Save'),
//                 onPressed: () {
//                   // Save settings logic here
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

class LanguageDrawer extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Chinese', 'code': 'zh'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 250, // Ensuring the modal sheet is visible
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(languages[index]['name']!),
                  onTap: () {
                    _selectLanguage(context, languages[index]['code']!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(BuildContext context, String languageCode) {
    // Handle language change here
    print("Language selected: $languageCode");
    Navigator.of(context).pop();
  }
}

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Help Center Content Goes Here',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Contact Us: support@example.com',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              'Privacy Policy: www.example.com/privacy',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class AppUpdatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Updates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Version 2.0.1',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Bug fixes and performance improvements.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              'Visit www.example.com/updates for more details.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
