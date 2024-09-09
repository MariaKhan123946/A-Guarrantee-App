import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        print("User is not authenticated.");
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "User is not authenticated.";
        });
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('dashboard') // Ensure the correct collection name
          .doc('fCS2sv5HXDvUzSOS9bTu') // Ensure the correct document ID
          .get();

      print("Fetching data from: dashboard/fCS2sv5HXDvUzSOS9bTu");

      if (snapshot.exists) {
        print("Document data: ${snapshot.data()}");
        setState(() {
          dashboardData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
          hasError = false;
        });
      } else {
        print("Document does not exist at path: dashboard/fCS2sv5HXDvUzSOS9bTu");
        setState(() {
          dashboardData = {};
          isLoading = false;
          hasError = true;
          errorMessage = "Document does not exist.";
        });
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = "Error fetching dashboard data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A7BD5), // Top color (blue)
                    Color(0xFF80E8FF), // Lighter bottom color (light blue)
                  ],
                ),
              ),
            ),
          ),
          // Content over the gradient
          Column(
            children: [
              // Gradient section with text
              Padding(
                padding: const EdgeInsets.only(top: 70, left: 15, right: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Back', style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                      child: Center(
                        child: const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // White section for dashboard data
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : hasError
                        ? Center(child: Text(errorMessage))
                        : dashboardData!.isEmpty
                        ? Center(child: Text("No data available"))
                        : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        children: [
                          buildDashboardCard("Registered Users", dashboardData!['registeredUsers'], Icons.person),
                          buildDashboardCard("Total Subscriptions", dashboardData!['totalSubscriptions'], Icons.subscriptions),
                          buildDashboardCard("Documents Uploaded", dashboardData!['documentsUploaded'] ?? '0', Icons.file_copy),
                          buildDashboardCard("Recent Logins", dashboardData!['recentLogins'], Icons.login),
                          buildDashboardCard("Total Downloads", dashboardData!['totalDownloads'], Icons.download),
                          buildDashboardCard("Total Revenue", "\$${dashboardData!['totalRevenue']}", Icons.attach_money),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDashboardCard(String title, dynamic value, IconData icon) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
