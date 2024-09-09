import 'package:a_guarante/documents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'document_detail_screeen.dart';
import 'subscription.dart';

class DocumentDetailsDeleteScreen extends StatefulWidget {
  final String documentId; // Pass documentId to fetch and delete
  final String downloadedFilePath; // Use this if you need it for other purposes

  DocumentDetailsDeleteScreen({
    required this.documentId,
    required this.downloadedFilePath, // Ensure this is used correctly
  });

  @override
  _DocumentDetailsDeleteScreenState createState() => _DocumentDetailsDeleteScreenState();
}

class _DocumentDetailsDeleteScreenState extends State<DocumentDetailsDeleteScreen> {
  bool _isDownloading = false;
  bool _downloadComplete = false;

  Future<void> deleteDocument(BuildContext context) async {
    try {
      // Fetch the document to get the download URL
      var docSnapshot = await FirebaseFirestore.instance.collection('documents').doc(widget.documentId).get();
      var documentUrl = docSnapshot['downloadUrl'];

      // Delete from Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(documentUrl);
      await storageRef.delete();

      // Delete from Firestore
      await FirebaseFirestore.instance.collection('documents').doc(widget.documentId).delete();

      // Navigate back after deletion
      Navigator.pop(context);
    } catch (e) {
      print("Error deleting document: $e");
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete document: $e')),
      );
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      // Update the expiry date in Firestore
      await FirebaseFirestore.instance.collection('documents').doc(widget.documentId).update({
        'expiryDate': formattedDate,
      });
    }
  }

  Future<void> _handleDownload(String url) async {
    try {
      setState(() {
        _isDownloading = true;
      });

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${url.split('/').last}');

      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.writeToFile(file);

      setState(() {
        _isDownloading = false;
        _downloadComplete = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed')),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download document: $e')),
      );
    }
  }
  int _currentIndex = 0;
  void _onBottomNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Back', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 50),
                    const Center(
                      child: Text(
                        'Document Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('documents').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var documents = snapshot.data!.docs;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        var docData = documents[index].data() as Map<String, dynamic>;
                        var document = Document(
                          title: docData['title'] ?? 'No Title',
                          expiryDate: docData['expiryDate'] ?? 'No Expiry Date',
                          size: docData['size'] ?? '0 MB',
                          imagePath: docData['imageUrl'] ?? 'https://via.placeholder.com/150', // Updated to imageUrl
                          downloadUrl: docData['downloadUrl'] ?? '',
                          id: documents[index].id,
                        );

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Handle document selection if needed
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(color: Colors.blue),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            document.imagePath,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      document.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            document.expiryDate,
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      document.size,
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: _downloadComplete
                                      ? Icon(Icons.check_circle, color: Colors.green)
                                      : _isDownloading
                                      ? CircularProgressIndicator()
                                      : Icon(Icons.download, color: Colors.blue),
                                  onPressed: () {
                                    if (!_isDownloading && !_downloadComplete) {
                                      _handleDownload(document.downloadUrl);
                                    }
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    _showDatePicker(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  deleteDocument(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Center(
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black26,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        onTap: _onBottomNavBarItemTapped,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_drive_file_outlined),
            label: 'Document',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.cloud_upload_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadDocumentScreen()),
                );
              },
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.calendar_today_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadDocumentScreen()),
                );
              },
            ),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionPage()),
                );
              },
            ),
            label: 'Profile',
          ),

        ],
      ),
    );
  }
}
