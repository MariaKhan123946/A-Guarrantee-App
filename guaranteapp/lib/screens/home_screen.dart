import 'package:a_guarante/dashboard/mainnavigatinscreen.dart';
import 'package:a_guarante/documents.dart';
import 'package:a_guarante/screens/eddit_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_document.dart';
import 'document_select_screen.dart';
import 'subscription.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  void _onBottomNavBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/document');
        break;
      case 2:
        Navigator.pushNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushNamed(context, '/plans');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
    // Navigate to the selected page based on inde


  @override
  Widget build(BuildContext context) {
  // HomeContent Method
    return Scaffold(
      body:Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A7BD5), // Top color (blue)
            Color(0xFF80E8FF), // Lighter bottom color (light blue)
          ],
        ),
      ),
      child: SafeArea(
          child: Column(
            children: [
              // AppBar Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                        'images/djvstock_Create_a_photo_of_a_young_man_with_a_clean_look 1.png', // Use the local asset image
                      ),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome", style: TextStyle(color: Colors.white,fontSize: 10)),
                        SizedBox(height: 3,),
                        Text("New User", style: TextStyle(color: Colors.white,fontSize: 20)),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                  ],
                )

              ),
              SizedBox(height: 10),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:TextField(
                  style: TextStyle(color: Colors.white), // Text color inside the search bar
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    hintText: 'Search Here',
                    hintStyle: TextStyle(color: Colors.white), // Placeholder text color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Color(0xFF3A7BD5),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Recent Files Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Recent Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xffFFFFFF))),
                ),
              ),
              SizedBox(height: 10),

              // Recent Files List
              Container(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    recentFileCard(
                      title: "Driving License",
                      expiryDate: "2025-06-25", // Use Date format as yyyy-MM-dd
                      iconUrl: 'https://firebasestorage.googleapis.com/v0/b/a-guarantee-c420d.appspot.com/o/uploads%2FDriving%20License.png?alt=media&token=52048415-2692-4337-b55e-fa976ddb7047',
                      context: context,
                    ),
                    recentFileCard(
                      title: "CNIC",
                      expiryDate: "2025-03-13",
                      iconUrl: 'https://firebasestorage.googleapis.com/v0/b/a-guarantee-c420d.appspot.com/o/uploads%2FCNIC.png?alt=media&token=53034728-416e-4918-8705-c03b5f92853d',
                      context: context,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Document Type Section inside a White Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Document Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/documentTypes'); // Navigate to document types screen
                            },
                            child: Text("View More →", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Document Type List
                      Expanded(
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('documents').snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var documents = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                var document = documents[index];
                                return documentTypeCard(
                                  title: document['title'],
                                  expiryDate: document['expiryDate'],
                                  documentId: document.id,
                                  imageUrl: document['imageUrl'], // Fetch imageUrl
                                  context: context,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),

        ),

      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black26,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        onTap: _onBottomNavBarItemTapped,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.insert_drive_file_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DocumentDetailScreen()),
                );
              },
            ),
            label: 'Document',
          ),

          BottomNavigationBarItem(
    icon: IconButton(
    icon: Icon(Icons.cloud_upload_outlined),
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UploadDocumentScreen()),
    );
    },
    ),
    label: 'Upload',
    ),

          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.calendar_today_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionPage()),
                );
              },
            ),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
    icon: IconButton(
    icon: Icon(Icons.person_outline),
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditScreen()),
    );
    },
    ),
    label: 'Profile',
    ),

        ],
      ),

    );
  }
  // Widget for Recent File Card
  Widget recentFileCard({
    required String title,
    required String expiryDate,
    required String iconUrl,
    required BuildContext context,
  }) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
                child: Center(child: Image.network(iconUrl, height: 50,))),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue[800],fontSize: 16)),
            SizedBox(height: 5),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.calendar_today_outlined,color: Color(0xff858383),),
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(expiryDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null && selectedDate != DateTime.parse(expiryDate)) {
                      print("Selected Date: ${DateFormat('dd MMMM yyyy').format(selectedDate)}");
                    }
                  },
                ),
                SizedBox(width: 2),
                Text(
                  "Expiry Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(expiryDate))}",
                  style: TextStyle(fontSize: 8),
                ),
              ],
            ),
            Container(
              height: 40,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    // White Container with "Delete" text
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: GestureDetector(
                        onTap: (){
                          _confirmDeleteDocument(title, context);
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xff2260FF), // Red text for delete
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Spacing between delete container and image
                    // Image
                    Image.asset(
                      'images/img_24.png',
                      height: 35,
                      width: 35,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }


  // Widget for Document Type Card
  Widget documentTypeCard({
    required String title,
    required String expiryDate,
    required String documentId,
    required String imageUrl,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(title),
          subtitle: Text("Expiry Date: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(expiryDate))}"),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                // Navigator.push(
                //   context,
                //   // MaterialPageRoute(
                //   //   builder: (context) => EditDocumentScreen(documentId: documentId),
                //   // ),
                // );
              } else if (value == 'delete') {
                _confirmDeleteDocument(title, context);
              }
            },
          ),
        ),

    );
  }

  // Confirm Delete Dialog
  void _confirmDeleteDocument(String documentTitle, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete $documentTitle?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              // Add your document delete functionality here
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
