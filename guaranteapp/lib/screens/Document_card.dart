import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:a_guarante/screens/editdocumentform.dart'; // Ensure this import is correct
import 'package:a_guarante/screens/document_detail_delete.dart';

import 'document_detail_screeen.dart'; // Ensure this import is correct

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDownload;

  DocumentCard({
    required this.document,
    required this.onDelete,
    required this.onSelect,
    required this.onEdit,
    required this.onDownload,
  });

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditDocumentForm(
        document: document,
        onSave: (updatedDocument) {
          // Handle saving of the updated document here
          onEdit(); // Call the onEdit callback to reflect the changes
        },
      ),
    );
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(document.expiryDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      // Handle updating expiry date in Firestore or local state
      // For now, just call the onEdit callback as an example
      onEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onSelect,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        document.imagePath,
                        height: 50,
                        fit: BoxFit.cover, // Ensures the image covers the container properly
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 2),
                GestureDetector(
                  onTap: () => _selectExpiryDate(context),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                      SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          document.expiryDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  document.size,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.download, color: Colors.blue),
              onPressed: onDownload,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _showEditDialog(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}