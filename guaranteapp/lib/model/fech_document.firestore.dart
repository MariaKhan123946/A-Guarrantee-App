// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
//
// import '../screens/document_detail_delete.dart'; // Import the Document model
//
// class DocumentListScreen extends StatefulWidget {
//   @override
//   _DocumentListScreenState createState() => _DocumentListScreenState();
// }
//
// class _DocumentListScreenState extends State<DocumentListScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);  // Handle back button
//           },
//         ),
//         title: Text('Your Documents'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _firestore.collection('documents').snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//
//           var documents = snapshot.data!.docs.map((doc) => Document.fromFirestore(doc)).toList();
//
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final document = documents[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 child: Card(
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.insert_drive_file, color: Colors.blue, size: 30),
//                             SizedBox(width: 10),
//                             Text(
//                               document.name,
//                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Text('${document.size}, modified ${document.modifiedDate}', style: TextStyle(color: Colors.grey)),
//                         SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 _viewDocument(document);
//                               },
//                               child: Text('View'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 _editDocument(document);
//                               },
//                               child: Text('Edit'),
//                             ),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                               onPressed: () {
//                                 _deleteDocument(document.id);
//                               },
//                               child: Text('Delete'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void _viewDocument(Document document) {
//     // Implement document viewing logic
//   }
//
//   void _editDocument(Document document) {
//     // Implement document editing logic
//   }
//
//   void _deleteDocument(String documentId) async {
//     await _firestore.collection('documents').doc(documentId).delete();
//   }
// }
