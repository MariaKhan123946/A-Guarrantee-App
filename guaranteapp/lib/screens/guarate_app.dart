import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class logoutScreen extends StatefulWidget {
  @override
  _logoutScreenState createState() => _logoutScreenState();
}

class _logoutScreenState extends State<logoutScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPushNotificationsEnabled = true;
  bool isSMSEnabled = false;
  bool isEmailEnabled = true;
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? '';
      });

      // Fetch user settings from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          isPushNotificationsEnabled = userDoc.get('pushNotifications') ?? true;
          isSMSEnabled = userDoc.get('sms') ?? false;
          isEmailEnabled = userDoc.get('email') ?? true;
        });
      }
    }
  }

  void _updateSettings(String field, bool value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        field: value,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade400,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Handle back action
          },
        ),
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications action
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
                  _buildListTile('Edit profile'),
                  _buildListTile('Admin dashboard'),
                  _buildListTile('User Management'),
                  _buildListTile('Change password'),
                  _buildListTile('Your Documents'),
                  _buildSwitchTile('Email', isEmailEnabled, (value) {
                    setState(() {
                      isEmailEnabled = value;
                      _updateSettings('email', value);
                    });
                  }),
                  _buildSwitchTile('Push notifications', isPushNotificationsEnabled, (value) {
                    setState(() {
                      isPushNotificationsEnabled = value;
                      _updateSettings('pushNotifications', value);
                    });
                  }),
                  _buildSwitchTile('SMS', isSMSEnabled, (value) {
                    setState(() {
                      isSMSEnabled = value;
                      _updateSettings('sms', value);
                    });
                  }),
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

  ListTile _buildListTile(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Handle tile tap
      },
    );
  }

  SwitchListTile _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
    );
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
              SizedBox(height: 10),
              Text('Are you sure you want to log out?'),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle cancel action
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
                    onPressed: () {
                      _logout(context); // Handle logout action
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
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst); // Navigate to the first screen (usually login)
  }
}

void main() {
  runApp(MaterialApp(home: logoutScreen()));
}
