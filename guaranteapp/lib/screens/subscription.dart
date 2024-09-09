import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isFreeTrialEnabled = false;
  String selectedPlan = '1_year';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  void _requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _sendNotification(String message) async {
    try {
      await _firebaseMessaging.subscribeToTopic('subscriptions');

      final user = _auth.currentUser;
      if (user != null) {
        // Add the notification to Firestore
        await _firestore.collection('notifications').add({
          'title': 'Subscription Update',
          'body': message,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
        });
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _handleSubscription() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'subscriptionPlan': selectedPlan,
          'isFreeTrialEnabled': isFreeTrialEnabled,
        });

        final message = isFreeTrialEnabled
            ? 'You have enabled the free trial for the $selectedPlan plan.'
            : 'You have subscribed to the $selectedPlan plan.';
        _sendNotification(message);

        // Navigate to the Settings screen after successful subscription
        Navigator.pushNamed(context, '/settings');
      } else {
        print('Successfull to subscribe');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfull to subscribe')),
        );
      }
    } catch (e) {
      print('Error updating subscription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to subscribe. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A7BD5), // Top color
              Color(0xFF80E8FF), // Bottom color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Subscriptions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Make your work more \n     faster and efficient',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Take your productivity to the next level with Premium.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Automatically extended. Cancel anytime.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Not sure yet? Enable free trial',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: isFreeTrialEnabled,
                              onChanged: (value) {
                                setState(() {
                                  isFreeTrialEnabled = value;
                                });
                              },
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      _buildPlanOption(
                        title: '1 year, \$89.99',
                        subtitle: 'Only \$7.50/ month',
                        storage: '30 GB Cloud Storage',
                        value: '1_year',
                        isSelected: selectedPlan == '1_year',
                        badgeText: 'Best value',
                      ),
                      _buildPlanOption(
                        title: '1 month, \$9.99',
                        storage: '30 GB Cloud Storage',
                        value: '1_month',
                        isSelected: selectedPlan == '1_month',
                      ),
                      _buildPlanOption(
                        title: 'Free Version',
                        storage: '5 GB Cloud Storage',
                        value: 'Free Version',
                        isSelected: selectedPlan == 'Free Version',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Subscribe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Document',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          // Handle bottom navigation bar item tap
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/document');
              break;
            case 2:
              Navigator.pushNamed(context, '/upload');
              break;
            case 3:
              Navigator.pushNamed(context, '/plans');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    String? subtitle,
    required String storage,
    required String value,
    required bool isSelected,
    String? badgeText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPlan = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightBlue[50] : Colors.white,
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
              SizedBox(height: 10),
              Text(
                storage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
