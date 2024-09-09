// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//  // Adjust this import based on your file structure
//
// class EditDocumentScreen extends StatefulWidget {
//   final DocumentSnapshot document;
//
//   EditDocumentScreen({required this.document});
//
//   @override
//   _EditDocumentScreenState createState() => _EditDocumentScreenState();
// }
//
// class _EditDocumentScreenState extends State<EditDocumentScreen> {
//   late TextEditingController _titleController;
//   late TextEditingController _sizeController;
//   late TextEditingController _modifiedController;
//
//   @override
//   void initState() {
//     super.initState();
//     final data = widget.document.data() as Map<String, dynamic>;
//
//     _titleController = TextEditingController(text: data['title'] ?? '');
//     _sizeController = TextEditingController(text: data['size'] ?? '');
//     _modifiedController = TextEditingController(text: data['modified'] ?? '');
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _sizeController.dispose();
//     _modifiedController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveChanges() async {
//     try {
//       final updatedDocument = {
//         'title': _titleController.text,
//         'size': _sizeController.text,
//         'modified': _modifiedController.text,
//       };
//
//       await FirebaseFirestore.instance
//           .collection('documents')
//           .doc(widget.document.id)
//           .update(updatedDocument);
//
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Document updated successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update document: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF3A7BD5),
//         title: Text('Edit Document'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveChanges,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: 'Title'),
//             ),
//             TextField(
//               controller: _sizeController,
//               decoration: InputDecoration(labelText: 'Size'),
//             ),
//             TextField(
//               controller: _modifiedController,
//               decoration: InputDecoration(labelText: 'Modified Date'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
