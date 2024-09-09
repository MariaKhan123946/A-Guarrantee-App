
import 'package:a_guarante/dashboard/admindashboard.dart';
import 'package:a_guarante/screens/eddit_screen.dart';
import 'package:a_guarante/screens/reset_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userdocument_screen.dart';
import 'your_document.dart'; // Ensure you have this screen defined

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isPushNotificationsEnabled = true;
  bool isSMSEnabled = false;
  bool isEmailEnabled = true;
  String userEmail = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A7BD5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notifications action if needed
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A7BD5),
              Color(0xFF80E8FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 16),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListItem(context, 'Edit profile', _editProfile),
                  _buildListItem(context, 'Admin dashboard', _adminDashboard),
                  _buildListItem(context, 'User Management', _userManagement),
                  _buildListItem(context, 'Change password', _changePassword),
                  _buildListItem(context, 'Your Documents', _yourDocuments),
                  _buildEmailListItem(userEmail, isEmailEnabled, (value) {
                    setState(() {
                      isEmailEnabled = value;
                    });
                  }),
                  _buildSwitchListItem('Push notifications', isPushNotificationsEnabled, (value) {
                    setState(() {
                      isPushNotificationsEnabled = value;
                    });
                  }),
                  _buildSwitchListItem('SMS', isSMSEnabled, (value) {
                    setState(() {
                      isSMSEnabled = value;
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A7BD5),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Save Settings',
                      style: TextStyle(fontSize: 16, color: Color(0xffFFFFFF)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFF3A7BD5)),
                        minimumSize: Size(135, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFF3A7BD5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, Function() onTap) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildEmailListItem(String email, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text('Email'),
      subtitle: Text(email),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF3A7BD5),
      ),
    );
  }

  Widget _buildSwitchListItem(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFF3A7BD5),
    );
  }

  // Save settings to Firebase Firestore
  void _saveSettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        "email": userEmail,
        'push_notifications': isPushNotificationsEnabled,
        'sms': isSMSEnabled,
        'email_enabled': isEmailEnabled,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to log in first.')),
      );
    }
  }

  // Logout function
  void _logout() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have been logged out.')),
    );
    // Navigate to login screen or other necessary actions
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Placeholder functions for list items
  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(), // Ensure EditScreen is defined
      ),
    );
  }

  void _adminDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDashboard(), // Ensure AdminDashboard is defined
      ),
    );
  }

  void _userManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserManagementScreen(), // Ensure UserManagementScreen is defined
      ),
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(), // Ensure ResetPasswordScreen is defined
      ),
    );
  }

  void _yourDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentSelectScreen(), // Ensure DocumentSelectScreen is defined
      ),
    );
  }
}
