import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogoutScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text('Settings',style: TextStyle(fontSize: 20,color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications,color: Colors.white,),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildListTile('Edit profile', context),
                  _buildListTile('Admin dashboard', context),
                  _buildListTile('User Management', context),
                  _buildListTile('Change password', context),
                  _buildListTile('Your Documents', context),
                  _buildSwitchTile('Email', false),
                  _buildSwitchTile('Push notifications', true),
                  _buildSwitchTile('SMS', false),
                ],
              ),
            ),
          ),
          Spacer(),
          _buildLogoutSection(context),
        ],
      ),
    );
  }

  ListTile _buildListTile(String title, BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Handle navigation to different screens
        // Example: Navigate to Edit Profile screen
      },
    );
  }

  SwitchListTile _buildSwitchTile(String title, bool value) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      value: value,
      onChanged: (bool newValue) {
        // Handle switch toggle, e.g., update Firestore user preferences
        _updateUserPreference(title, newValue);
      },
      activeColor: Colors.white,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
    );
  }

  void _updateUserPreference(String preference, bool value) {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).update({
        preference: value,
      });
    }
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text('Are you sure you want to log out?'),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Handle cancel action
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _auth.signOut(); // Handle logout action
                        Navigator.pushReplacementNamed(context, '/setting'); // Redirect to login
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        'Yes, Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: LogoutScreen()));
}
