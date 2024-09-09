import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image picker package
import 'document_detail_delete.dart';
import 'document_detail_screeen.dart';

class EditDocumentForm extends StatefulWidget {
  final Document document;
  final Function(Document) onSave;

  EditDocumentForm({
    required this.document,
    required this.onSave,
  });

  @override
  _EditDocumentFormState createState() => _EditDocumentFormState();
}

class _EditDocumentFormState extends State<EditDocumentForm> {
  late TextEditingController _titleController;
  late TextEditingController _expiryDateController;
  late TextEditingController _sizeController;
  late String imageUrl;
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _expiryDateController = TextEditingController(text: widget.document.expiryDate);
    _sizeController = TextEditingController(text: widget.document.size);
    imageUrl = widget.document.imagePath;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageUrl = image.path; // Update the image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Document'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: imageUrl.isNotEmpty
                  ? Image.file(
                File(imageUrl),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.image, color: Colors.grey),
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date'),
            ),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(labelText: 'Size'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // When saving, retain the document's ID and downloadUrl
            widget.onSave(
              Document(
                title: _titleController.text,
                expiryDate: _expiryDateController.text,
                size: _sizeController.text,
                imagePath: imageUrl, // Pass the updated image path
                downloadUrl: widget.document.downloadUrl, // Keep the existing download URL
                id: widget.document.id, // Retain the document ID
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}