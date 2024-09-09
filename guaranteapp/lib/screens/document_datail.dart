// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class DocumentDetailsScreen extends StatelessWidget {
//   final String documentId;
//
//   DocumentDetailsScreen({required this.documentId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Document Details')),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance.collection('documents').doc(documentId).get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(child: Text('No document found'));
//           }
//
//           var document = snapshot.data!.data() as Map<String, dynamic>;
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Title: ${document['fileName']}', style: TextStyle(fontSize: 18)),
//                 Text('URL: ${document['fileURL']}', style: TextStyle(fontSize: 16)),
//                 Text('Upload Date: ${DateFormat('dd MMM yyyy').format((document['uploadDate'] as Timestamp).toDate())}', style: TextStyle(fontSize: 16)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
