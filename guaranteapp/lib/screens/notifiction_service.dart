import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A7BD5),
            Color(0xFF80E8FF),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text('Notifications', style: TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  GestureDetector(
                    onTap: _markAllAsSeen,
                    child: Text(
                      'Mark all as seen',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No notifications available.'));
                  }

                  print('Snapshot data: ${snapshot.data!.docs.map((doc) => doc.data()).toList()}');

                  var notifications = snapshot.data!.docs;

                  // Separate notifications for today and yesterday
                  var todayNotifications = [];
                  var yesterdayNotifications = [];

                  var today = DateTime.now();
                  var yesterday = today.subtract(Duration(days: 1));

                  for (var doc in notifications) {
                    var notification = doc.data() as Map<String, dynamic>;
                    var timestamp = notification['timestamp'] as Timestamp;
                    var notificationDate = timestamp.toDate();

                    // Check if the notification is from today or yesterday
                    if (notificationDate.year == today.year &&
                        notificationDate.month == today.month &&
                        notificationDate.day == today.day) {
                      todayNotifications.add(notification);
                    } else if (notificationDate.year == yesterday.year &&
                        notificationDate.month == yesterday.month &&
                        notificationDate.day == yesterday.day) {
                      yesterdayNotifications.add(notification);
                    }
                  }

                  return ListView(
                    children: [
                      if (todayNotifications.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: todayNotifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(todayNotifications[index]);
                          },
                        ),
                      ],
                      if (yesterdayNotifications.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Yesterday', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: yesterdayNotifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(yesterdayNotifications[index]);
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Container(
                height: 5,
                width: 120,
                color: Colors.grey[700],
              ),
            )
          ],
        ),

      ),

    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    bool isSubscription = notification['type'] == 'subscription';
    Timestamp timestamp = notification['timestamp'];
    DateTime notificationDate = timestamp.toDate();
    DateTime today = DateTime.now();

    bool isToday = today.year == notificationDate.year &&
        today.month == notificationDate.month &&
        today.day == notificationDate.day;

    Widget notificationIcon = isSubscription
        ? Icon(Icons.subscriptions, color: Color(0xff2260FF), size: 18)
        : Icon(Icons.check, color: Colors.white, size: 18);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSubscription ? Colors.transparent : Color(0xff2260FF),
              borderRadius: BorderRadius.circular(5),
              border: isSubscription ? Border.all(color: Color(0xff2260FF)) : null,
            ),
            child: Center(child: notificationIcon),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(notification['body']),
              ],
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              _viewNotification(notification);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff2260FF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('View', style: TextStyle(color: Color(0xff2260FF))),
            ),
          ),
        ],
      ),
    );

  }

  void _markAllAsSeen() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'seen': true});
      }
    });
  }

  void _viewNotification(Map<String, dynamic> notification) {
    // Implement the view notification functionality
    print('Viewing notification: ${notification['title']}');
    // Optionally navigate to a detailed view of the notification if needed
  }
}
