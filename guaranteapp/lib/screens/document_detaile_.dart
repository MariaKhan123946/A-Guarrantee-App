// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
//
// class DocumentDetailScreen extends StatelessWidget {
//   final DocumentSnapshot document;
//
//   DocumentDetailScreen({required this.document});
//
//   @override
//   Widget build(BuildContext context) {
//     final data = document.data() as Map<String, dynamic>?;
//
//     String title = data != null && data.containsKey('title') ? data['title'] : 'Untitled Document';
//     String size = data != null && data.containsKey('size') ? '${data['size']} Mb' : 'Unknown Size';
//     String modified = data != null && data.containsKey('modified') ? 'modified ${data['modified']}' : 'Unknown Date';
//     String fileUrl = data != null && data.containsKey('file_url') ? data['file_url'] : '';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Document Details'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Title: $title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Text('Size: $size', style: TextStyle(fontSize: 16)),
//                 Text('Modified: $modified', style: TextStyle(fontSize: 16)),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//           Expanded(
//             child: PDFView(
//               filePath: fileUrl,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
