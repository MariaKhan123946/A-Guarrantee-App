import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class EditDocumentScreen extends StatefulWidget {
  final DocumentSnapshot document;

  EditDocumentScreen({required this.document});

  @override
  _EditDocumentScreenState createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  late TextEditingController _titleController;
  late TextEditingController _sizeController;
  late TextEditingController _modifiedController;
  File? _selectedFile;
  String? _pdfUrl;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>?;
    _titleController = TextEditingController(text: data?['title'] ?? '');
    _sizeController = TextEditingController(text: data?['size']?.toString() ?? '');
    _modifiedController = TextEditingController(text: data?['modified'] ?? '');
    _pdfUrl = data?['file_url'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _modifiedController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _sizeController.text = (result.files.single.size / (1024 * 1024)).toStringAsFixed(2); // Size in MB
        _modifiedController.text = DateTime.now().toString(); // Current DateTime
      });
    }
  }

  Future<void> _uploadPdfAndSaveChanges() async {
    try {
      if (_selectedFile != null) {
        // Upload PDF to Firebase Storage
        final fileName = _selectedFile!.path.split('/').last;
        final storageRef = FirebaseStorage.instance.ref().child('documents/$fileName');
        final uploadTask = await storageRef.putFile(_selectedFile!);

        // Get the download URL
        _pdfUrl = await uploadTask.ref.getDownloadURL();
      }

      // Update Firestore document with new data
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(widget.document.id)
          .update({
        'title': _titleController.text,
        'size': _sizeController.text,
        'modified': _modifiedController.text,
        'file_url': _pdfUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document updated successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update document: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Document'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _uploadPdfAndSaveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(labelText: 'Size (Mb)'),
              keyboardType: TextInputType.number,
              readOnly: true,
            ),
            TextField(
              controller: _modifiedController,
              decoration: InputDecoration(labelText: 'Modified Date'),
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickPdf,
              child: Text('Select PDF'),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('Selected File: ${_selectedFile!.path.split('/').last}'),
              ),
          ],
        ),
      ),
    );
  }
}
