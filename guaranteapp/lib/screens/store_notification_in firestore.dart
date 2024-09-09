import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void _sendNotification(String documentTitle) {
  FirebaseFirestore.instance.collection('notifications').add({
    'title': 'Document Uploaded',
    'body': 'Your document "$documentTitle" has been uploaded successfully.',
    'timestamp': Timestamp.now(),
    'type': 'upload',
    'userId': FirebaseAuth.instance.currentUser?.uid, // Make sure you add the user ID
  });

  print('Notification added to Firestore for document: $documentTitle');
}
