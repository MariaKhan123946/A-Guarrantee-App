// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class EditDocumentScreen extends StatefulWidget {
//   final String documentId;
//
//   EditDocumentScreen({required this.documentId});
//
//   @override
//   _EditDocumentScreenState createState() => _EditDocumentScreenState();
// }
//
// class _EditDocumentScreenState extends State<EditDocumentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = '';
//   String _expiryDate = '';
//   late String _currentImageUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDocumentData();
//   }
//
//   void _fetchDocumentData() async {
//     DocumentSnapshot document = await FirebaseFirestore.instance
//         .collection('documents')
//         .doc(widget.documentId)
//         .get();
//     setState(() {
//       _title = document['title'];
//       _expiryDate = document['expiryDate'];
//       _currentImageUrl = document['imageUrl'];
//     });
//   }
//
//   void _updateDocument() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       await FirebaseFirestore.instance.collection('documents').doc(widget.documentId).update({
//         'title': _title,
//         'expiryDate': _expiryDate,
//       });
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Document'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _title,
//                 decoration: InputDecoration(labelText: 'Title'),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _title = value!;
//                 },
//               ),
//               TextFormField(
//                 initialValue: _expiryDate,
//                 decoration: InputDecoration(labelText: 'Expiry Date'),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter an expiry date';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _expiryDate = value!;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _updateDocument,
//                 child: Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
