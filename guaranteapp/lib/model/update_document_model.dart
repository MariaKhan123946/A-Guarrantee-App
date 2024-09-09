class Document {
  final String title;
  final String expiryDate;
  final String size;
  final String imagePath; // This should be the URL of the image
  final String downloadUrl;
  final String id;

  Document({
    required this.title,
    required this.expiryDate,
    required this.size,
    required this.imagePath,
    required this.downloadUrl,
    required this.id,
  });
}
