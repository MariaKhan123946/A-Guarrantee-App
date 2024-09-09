// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Document {
//   final String id;
//   final String name;
//   final String size;
//   final String modifiedDate;
//
//   Document({
//     required this.id,
//     required this.name,
//     required this.size,
//     required this.modifiedDate,
//   });
//
//   // Factory constructor to create a Document from Firestore data
//   factory Document.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     final data = doc.data();
//     return Document(
//       id: doc.id,
//       name: data['name'] ?? 'Unnamed Document',
//       size: data['size'] ?? 'Unknown size',
//       modifiedDate: data['modifiedDate'] ?? 'Unknown date',
//     );
//   }
// }
