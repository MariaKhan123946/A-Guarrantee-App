import 'package:a_guarante/screens/guarate_app.dart';
import 'package:a_guarante/screens/logou.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:a_guarante/screens/setting_screen.dart';

class UserManagementScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back, color: Colors.white),
        title: Text('User Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Here',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5, // Adjust height as needed
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No users found'));
                      }

                      final users = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var userData = users[index].data() as Map<String, dynamic>;
                          String userId = users[index].id;
                          return _buildUserProfileCard(userData, userId, context);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildListTile('Subscriptions'),
                      _buildListTile('Email Address'),
                      _buildListTile('Registration Date'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(Map<String, dynamic> userData, String userId, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: 300,  // Set the fixed width for the container
        height: 120, // Set the fixed height for the container
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(8.0),
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            userData['displayName'] ?? 'No Name',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            userData['email'] ?? 'No Email',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
          trailing: Container(
            width: 100,  // Set a fixed width for the buttons container
            child: Wrap(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogoutScreen(
                            // Pass userId if needed
                          ),
                        ),
                      );
                    },
                    child: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,  // White background
                      foregroundColor: Colors.blue,    // Blue text
                      textStyle: TextStyle(fontSize: 14.0),
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      minimumSize: Size(80, 25), // Adjust the size as needed
                      side: BorderSide(color: Colors.blue),  // Optional: Blue border
                    ),
                  ),
                  SizedBox(height: 4), // Space between buttons
                  ElevatedButton(
                    onPressed: () {
                      _deleteUser(userId);
                    },
                    child: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,  // Blue background
                      foregroundColor: Colors.white, // White text
                      textStyle: TextStyle(fontSize: 14.0),
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      minimumSize: Size(80, 25), // Adjust the size as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

    );
  }


  void _deleteUser(String userId) {
    _firestore.collection('users').doc(userId).delete().then((_) {
      print('User deleted');
    }).catchError((error) {
      print('Error deleting user: $error');
    });
  }

  Widget _buildListTile(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
