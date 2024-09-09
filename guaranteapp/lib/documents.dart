import 'dart:io';
import 'dart:convert'; // For base64 encoding
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UploadDocumentScreen(),
    );
  }
}

class UploadDocumentScreen extends StatefulWidget {
  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  List<UploadDocumentItemData> _documents = [];

  @override
  void initState() {
    super.initState();

    // Request permission for notifications
    FirebaseMessaging.instance.requestPermission();

    // Get the token (you might use this to send notifications from a server)
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show a dialog or a snackbar
      }
    });
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      // Check if the file is an image
      bool isImage = file.extension == 'jpg' || file.extension == 'jpeg' || file.extension == 'png';
      String imageUrl = '';
      String fileData = base64Encode(File(file.path!).readAsBytesSync());

      UploadDocumentItemData newItem = UploadDocumentItemData(
        title: file.name,
        size: '${(file.size / 1024).toStringAsFixed(2)} KB',
        progress: 0.0,
        progressColor: Colors.blue,
      );

      setState(() {
        _documents.add(newItem);
      });

      try {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('uploads/${file.name}');

        UploadTask uploadTask = ref.putFile(File(file.path!));

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            newItem.progress = progress;
            newItem.progressColor = Colors.blue;
          });
        });

        await uploadTask.whenComplete(() async {
          String downloadUrl = await ref.getDownloadURL();

          if (isImage) {
            imageUrl = downloadUrl;
          }

          await FirebaseFirestore.instance.collection('documents').add({
            'title': file.name,
            'expiryDate': '2024-12-31',
            'size': '${(file.size / 1024).toStringAsFixed(2)} KB',
            'imageUrl': imageUrl,
            'fileData': fileData,
            'fileName': file.name,
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'uploadedAt': Timestamp.now(),
          });

          setState(() {
            newItem.isComplete = true;
            newItem.isViewable = true;
            newItem.progress = 1.0; // Forcefully set to 100%
            newItem.progressColor = Colors.green; // Change progress color to green on completion
          });

          _sendNotification(file.name);

          print('File uploaded successfully. Download URL: $downloadUrl');
        });

      } catch (e) {
        setState(() {
          newItem.isError = true;
        });
        print('Upload error: $e');
      }
    }
  }

  void _sendNotification(String documentTitle) {
    FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Document Uploaded',
      'body': 'Your document "$documentTitle" has been uploaded successfully.',
      'timestamp': Timestamp.now(),
      'type': 'upload',
    });

    print('Notification added to Firestore for document: $documentTitle');
  }

  Future<void> _downloadFile(String downloadUrl) async {
    try {
      // Implement actual downloading here using a package like Dio or http.
      print('Starting download from URL: $downloadUrl');
    } catch (e) {
      print('Download error: $e');
    }
  }

  void _deleteDocument(UploadDocumentItemData document) {
    setState(() {
      _documents.remove(document);
    });
  }

  void _viewDocument(UploadDocumentItemData document) async {
    if (document.downloadUrl != null) {
      await _downloadFile(document.downloadUrl!);
      print('Viewing document: ${document.title}');
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Upload Document', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFF3A7BD5),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Upload', style: TextStyle(color: Color(0xff353535))),
                        Spacer(),
                        Image.asset('images/img_26.png', height: 20),
                        Icon(Icons.close, size: 20, color: Color(0xffCACACA)),
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickAndUploadFile,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.upload_file, size: 50, color: Color(0xFF3A7BD5)),
                            SizedBox(height: 8),
                            Text(
                              'Click to Upload or drag and drop',
                              style: TextStyle(color: Color(0xFF3A7BD5)),
                            ),
                            Text(
                              '(Max. File size: 25 MB)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          return UploadDocumentItem(
                            data: _documents[index],
                            onDelete: () => _deleteDocument(_documents[index]),
                            onView: () => _viewDocument(_documents[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF3A7BD5),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Upload tab
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
            icon: Icon(Icons.event_note),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class UploadDocumentItem extends StatelessWidget {
  final UploadDocumentItemData data;
  final VoidCallback onDelete;
  final VoidCallback onView;

  UploadDocumentItem({
    required this.data,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Color(0xFF3A7BD5),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data.size, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: data.progress,
                      color: data.progressColor,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          data.isComplete ? '100%' : '${(data.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.blue),
            onPressed: onView,
          ),
        ],
      ),
    );
  }
}

class UploadDocumentItemData {
  final String title;
  final String size;
  final String? downloadUrl;
  double progress;
  Color progressColor;
  bool isComplete;
  bool isViewable;
  bool isError;

  UploadDocumentItemData({
    required this.title,
    required this.size,
    this.downloadUrl,
    this.progress = 0.0,
    this.progressColor = Colors.blue,
    this.isComplete = false,
    this.isViewable = false,
    this.isError = false,
  });
}
