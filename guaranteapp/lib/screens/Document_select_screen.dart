import 'package:a_guarante/screens/Document_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'document_detail_screeen.dart';
import 'document_detail_delete.dart';

class DocumentDetailScreen extends StatefulWidget {
  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final CollectionReference documentCollection = FirebaseFirestore.instance.collection('documents');

  Future<void> _showDatePicker(BuildContext context, String documentId) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      await FirebaseFirestore.instance.collection('documents').doc(documentId).update({
        'expiryDate': formattedDate,
      });
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('documents').doc(documentId).delete();
      Fluttertoast.showToast(msg: 'Document deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting document: $e');
    }
  }

  Future<String> _downloadDocument(String downloadUrl, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        Fluttertoast.showToast(msg: 'File already downloaded: $fileName');
        return file.path;
      }

      final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      final downloadTask = ref.writeToFile(file);

      await downloadTask;

      Fluttertoast.showToast(msg: 'Download completed: $fileName');
      return file.path;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download failed: $e');
      return '';
    }
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Storage permission is required for downloading files.');
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
                      child: const Text('Back', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 50),
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
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: documentCollection.snapshots(),
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
                          imagePath: docData['imageUrl'] ?? '',
                          downloadUrl: docData['Url'] ?? '',
                          id: documents[index].id,
                        );

                        return DocumentCard(
                          document: document,
                          onSelect: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentDetailsDeleteScreen(
                                  documentId: documents[index].id,
                                  downloadedFilePath: '',
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            _showDatePicker(context, documents[index].id);
                          },
                          onDownload: () async {
                            await _requestStoragePermission();
                            String downloadedFilePath = await _downloadDocument(
                              document.downloadUrl,
                              document.title,
                            );

                            if (downloadedFilePath.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentDetailsDeleteScreen(
                                    documentId: documents[index].id,
                                    downloadedFilePath: downloadedFilePath,
                                  ),
                                ),
                              );
                            }
                          },
                          onDelete: () async {
                            bool? confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this document?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await _deleteDocument(documents[index].id);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentDetailsDeleteScreen(
                        documentId: '',
                        downloadedFilePath: 'https://firebasestorage.googleapis.com/v0/b/a-guarantee-c420d.appspot.com/o/uploads%2FResume.png?alt=media&token=79c021df-70e2-4b42-9f7c-7562ed641a3e',
                      ),
                    ),
                  );
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
                    'Select',
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
        items: const [
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
