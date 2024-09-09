import 'package:a_guarante/screens/Document_select_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


import 'edit_documemnt_screen.dart';
import 'edit_document.dart';

class DocumentSelectScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A7BD5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Your Documents',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('documents').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var documents = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var document = documents[index];
                return _buildDocumentCard(context, document);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;

    String title = data != null && data.containsKey('title')
        ? data['title']
        : 'Untitled Document';

    String size = data != null && data.containsKey('size')
        ? '${data['size']} Mb'
        : 'Unknown Size';

    String modified = data != null && data.containsKey('modified')
        ? 'modified ${data['modified']}'
        : 'Unknown Date';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file, color: Color(0xFF3A7BD5), size: 36),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A7BD5),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$size, $modified',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildMoreOptions(context, document),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _viewDocument(context, document),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF3A7BD5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('View', style: TextStyle(color: Color(0xFF3A7BD5))),
                ),
                ElevatedButton(
                  onPressed: () => _editDocument(context, document),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF3A7BD5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Edit', style: TextStyle(color: Color(0xFF3A7BD5))),
                ),
                ElevatedButton(
                  onPressed: () => _deleteDocument(context, document),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3A7BD5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocument(BuildContext context, DocumentSnapshot document) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DocumentDetailScreen(),
    //   ),
    // );
  }

  void _editDocument(BuildContext context, DocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDocumentScreen(document: document),
      ),
    );
  }

  void _deleteDocument(BuildContext context, DocumentSnapshot document) async {
    try {
      String fileUrl = document['file_url'];
      String documentId = document.id;

      // Delete the file from Firebase Storage
      await _storage.refFromURL(fileUrl).delete();

      // Delete the document from Firestore
      await _firestore.collection('documents').doc(documentId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete document: $e')),
      );
    }
  }

  Widget _buildMoreOptions(BuildContext context, DocumentSnapshot document) {
    return Wrap(
      children: [
        ListTile(
          leading: Icon(Icons.visibility),
          title: Text('View'),
          onTap: () {
            Navigator.pop(context); // Close the bottom sheet
            _viewDocument(context, document);
          },
        ),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit'),
          onTap: () {
            Navigator.pop(context); // Close the bottom sheet
            _editDocument(context, document);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text('Delete'),
          onTap: () {
            Navigator.pop(context); // Close the bottom sheet
            _deleteDocument(context, document);
          },
        ),
      ],
    );
  }
}
