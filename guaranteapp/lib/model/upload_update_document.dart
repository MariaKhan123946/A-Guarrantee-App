import 'package:flutter/animation.dart';

class UploadDocumentItemData {
  final String title;
  final String size;
  final double progress;
  final Color progressColor;
  final bool isComplete;
  final bool isViewable;
  bool isError; // Remove `late` keyword and provide a default value
  final String? downloadUrl;

  UploadDocumentItemData({
    required this.title,
    required this.size,
    required this.progress,
    required this.progressColor,
    this.isComplete = false,
    this.isViewable = false,
    this.isError = false, // Initialize with default value
    this.downloadUrl,
  });
}
