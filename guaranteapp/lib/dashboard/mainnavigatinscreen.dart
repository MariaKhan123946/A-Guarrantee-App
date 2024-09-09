import 'package:a_guarante/documents.dart';
import 'package:a_guarante/screens/your_document.dart';
import 'package:flutter/material.dart';
import 'package:a_guarante/screens/home_screen.dart';
import 'package:a_guarante/screens/document_select_screen.dart';
 // Ensure this file exists
import 'package:a_guarante/screens/subscription.dart';
import 'package:a_guarante/screens/eddit_screen.dart'; // Ensure this file exists

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [
    HomeScreen(),
    DocumentDetailScreen(), // Corrected screen reference
    UploadDocumentScreen(), // Ensure this screen exists
    SubscriptionPage(),
    EditScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[200],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file_outlined),
            label: 'Document',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload_outlined),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
