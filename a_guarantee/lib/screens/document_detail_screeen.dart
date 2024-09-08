import 'package:a_guarantee/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DocumentDetailsScreen(),
    );
  }
}

class DocumentDetailsScreen extends StatelessWidget {
  final List<Document> documents = [
    Document(
      title: 'Driving License',
      expiryDate: '25 June 2025',
      size: '3.2 Mb',
      imagePath: 'images/Asset 1 1.png',
    ),
    Document(
      title: 'Passport',
      expiryDate: '13 March 2025',
      size: '3.5 Mb',
      imagePath: 'images/pasaport_si_bilet-removebg-preview 1.png',
    ),
    Document(
      title: 'CNIC',
      expiryDate: '12 May 2025',
      size: '4.1 Mb',
      imagePath: 'images/Asset 1 1 (1).png',
    ),
    Document(
      title: 'Resume',
      expiryDate: '10 April 2025',
      size: '2.6 Mb',
      imagePath: 'images/pasaport_si_bilet-removebg-preview 2 (1).png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A7BD5), // Top color (blue)
              Color(0xFF80E8FF), // Lighter bottom color (light blue)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Text('Back', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 50),
                    const Center(
                      child: Text(
                        'Document Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),  // Add some space here
              Expanded(  // Use Expanded here
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return DocumentCard(document: documents[index]);
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Center(
                  child: Text(
                    'Select',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file), label: 'Document'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1, // Set the current index to highlight the 'Document' tab
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}



class Document {
  final String title;
  final String expiryDate;
  final String size;
  final String imagePath;

  Document({
    required this.title,
    required this.expiryDate,
    required this.size,
    required this.imagePath,
  });
}

class DocumentCard extends StatelessWidget {
  final Document document;

  DocumentCard({required this.document});

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
                 Container(
                    width: 50, // Set width for the image container
                    height: 50, // Set height for the image container
                    decoration: BoxDecoration(
                      borderRadius:  BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0)
                      ), // Adjust radius as needed
                      border: Border.all(color: Colors.blue), // Optional: Add border if needed
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Ensure image fits within the container
                      child: Image.asset(
                        document.imagePath,
                        height: 50, // Ensure the image covers the container
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
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      document.expiryDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  document.size,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: SizedBox(
                    height: 24, // Set a fixed height for the button
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle edit action
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(fontSize: 16), // Adjust font size as needed
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () {
                // Handle download action
              },
              icon: Icon(Icons.download_rounded),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

