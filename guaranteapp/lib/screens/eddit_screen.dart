import 'dart:typed_data';
import 'package:a_guarante/documents.dart';
import 'package:a_guarante/screens/setting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'document_select_screen.dart';
import 'subscription.dart';

class EditScreen extends StatefulWidget {
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _profilePicController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        _loadUserData();
      }
    });
  }

  void _loadUserData() async {
    User user = _auth.currentUser!;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _profilePicController.text = userDoc['profilePic'] ?? '';
        _fullNameController.text = userDoc['fullName'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
        _dobController.text = userDoc['dob'] ?? '';
        _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User document does not exist')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
        return;
      }

      final fileBytes = await pickedFile.readAsBytes();
      if (fileBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading image file')),
        );
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final storageRef = _storage.ref().child('profile_pics/${user.uid}.jpg');
      final uploadTask = storageRef.putData(fileBytes);

      await uploadTask.whenComplete(() async {
        try {
          final downloadUrl = await storageRef.getDownloadURL();
          setState(() {
            _profilePicController.text = downloadUrl;
          });

          await _firestore.collection('users').doc(user.uid).update({
            'profilePic': downloadUrl,
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting download URL: $e')),
          );
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking or uploading image: $e')),
      );
    }
  }

  void _updateUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      User user = _auth.currentUser!;
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'profilePic': _profilePicController.text,
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'dob': _dobController.text,
          'phoneNumber': _phoneNumberController.text,
        });

        // Navigate to SettingsScreen after successful update
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(),));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating data: $e')),
        );
      }
    }
  }

  void _changePassword() async {
    User user = _auth.currentUser!;
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          await user.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error changing password: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a new password')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3A7BD5),
                    Color(0xFF80E8FF),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80), // To avoid overflow with bottom navigation
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 70),
                  child: const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      _profilePicController.text.isNotEmpty
                                          ? _profilePicController.text
                                          : '',
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Color(0xff9DB2CE)),
                                      onPressed: _pickAndUploadImage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 2,),
                          Text("New User",style: TextStyle(color: Color(0xff1D61E7),fontSize: 25),),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'Full Name',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'Email',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'Date of Birth',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _dobController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your date of birth';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'Phone Number',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _phoneNumberController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'New Password',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Color(0xff9DB2CE),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty && value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 190),
                            child: const Text(
                              'Confirm Password',
                              style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Color(0xffD0D0D0)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Color(0xff9DB2CE),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 30),

    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 50), backgroundColor: Color(0xff1D61E7),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ), // Button color
    ),
    onPressed: _updateUserData,
    child: Text(
    'Update Profile',
    style: TextStyle(fontSize: 18),
    ),
    ),
    ),

    SizedBox(height: 30.0),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    ]
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
}
