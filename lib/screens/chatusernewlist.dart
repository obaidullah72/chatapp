import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text("Users"),
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.search),
          ),
        ],),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var user = snapshot.data!.docs[index];
                var profileImageUrl = user['imageUrl'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty ? Icon(Icons.person) : null,
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
