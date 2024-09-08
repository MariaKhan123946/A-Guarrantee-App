import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? _selectedDate;
  String? _expiryDate;

  @override
  void initState() {
    super.initState();
    // Initialize with some default expiry date
    _expiryDate = '25 June 2025'; // Default or previously set date
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _expiryDate = DateFormat('dd MMM yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set to transparent to use gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A7BD5), Color(0xFF00BFFF)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome and user profile section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: AssetImage(
                            'images/djvstock_Create_a_photo_of_a_young_man_with_a_clean_look 1.png'), // Replace with actual user image
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'New User',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Image.asset('images/img_5.png',height: 20,),
                        onPressed: () {
                          // Add your settings button action here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          // Add your notification button action here
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white, width: 1.0), // White border
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Here',
                        hintStyle: TextStyle(
                          color: Color(0xffFFFFFF), // Same color as the icon
                        ),
                        icon: Icon(
                          Icons.search,
                          color: Color(0xffFFFFFF), // White color for the icon
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Recent Files
                  const Text(
                    'Recent Files',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220, // Fixed height for the ListView to avoid overflow
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFileCard(
                            context,
                            'Driving License',
                            _expiryDate ?? '25 June 2025',
                            'images/Asset 1 1.png'), // Replace with actual images
                        _buildFileCard(
                            context,
                            'Passport',
                            '13 March 2024',
                            'images/pasaport_si_bilet-removebg-preview 1.png'), // Replace with actual images
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Document Type Section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Document Type',
                              style: TextStyle(
                                color: Color(0xFF003D94),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'View More',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDocumentTypeTile(
                            'Warranty',
                            '30 Jan 2025',
                            'images/vecteezy_car-rent-icon-design_28900469 1.png'
                        ),
                        _buildDocumentTypeTile(
                            'Vehicle Insurance Certificate',
                            '08 Sep 2024',
                            'images/Group.png'
                        ),
                        _buildDocumentTypeTile(
                            'Driving License',
                            '25 June 2025',
                            'images/Asset 1 1.png'
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF3A7BD5), // Top color (blue)// Light blue color for selected items
        unselectedItemColor: Color(0xFF9DB2CE), // Lighter blue color for unselected items
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Document',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
      BuildContext context, String title, String date, String imagePath) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Action Row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Main Image
                Container(
                  height: 70,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color for the container
                    borderRadius: BorderRadius.circular(20.0), // Match the border radius
                    border: Border.all(color: Colors.grey[300]!, width: 1), // Optional border
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      height: 50,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Spacing between the images
                // Action Image
                Image.asset(
                  'images/img_4.png',
                  height: 30,
                  width: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF003D94),
                fontSize: 14, // Increased font size for better readability
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Expiry Date
          Row(
            children: [
              IconButton(
                icon: Image.asset(
                  'images/img_3.png',
                  height: 15,
                  width: 15,
                ),
                onPressed: () {
                  _selectDate(context);
                },
              ),
              const SizedBox(width: 2), // Spacing between icon and text
              Text(
                'Expiry Date: $date',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10, // Adjusted for better readability
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset('images/img_1.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeTile(String title, String date, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0), // Margin between tiles
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), // Light grey border
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      child: ListTile(
        leading: Image.asset(imagePath, height: 40, width: 40),
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFF003D94),
            fontSize: 14, // Increased font size for better readability
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Expiry Date: $date'),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
}
