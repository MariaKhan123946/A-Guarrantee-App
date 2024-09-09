import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Passwords do not match.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
      return;
    }

    try {
      // Here you would need to use Firebase Authentication's method to confirm the password reset
      // For example, if you have a code for password reset:
      // await FirebaseAuth.instance.confirmPasswordReset(code: _resetCode, newPassword: _newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Password has been reset successfully.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          e.message ?? "Error resetting password.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
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
            ),
          ),
          // Content over the gradient
          Column(
            children: [
              // Gradient section with text
              Container(
                padding: const EdgeInsets.only(top: 70),
                child: const Center(
                  child: Text(
                    'A GUARANTEE',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // White section for reset password form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Back button (moved to the start)
                                Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Color(0xFF4983F6), Color(0xFF003D94)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // This color is replaced by the gradient
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'New Password',
                                  style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                                ),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: !_isNewPasswordVisible,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xffD0D0D0)), // Light grey border color
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                    hintText: 'Enter new password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[400], // Grey color for the icon
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isNewPasswordVisible = !_isNewPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Confirm New Password',
                                  style: TextStyle(fontSize: 16, color: Color(0xff6C7278)),
                                ),
                                TextField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xffD0D0D0)), // Light grey border color
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                    hintText: 'Confirm new password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[400], // Grey color for the icon
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff1D61E7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xffFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 5,
                            width: 120,
                            color: Colors.grey,
                          ),
                        ),
                         // Optional: Add spacing between the grey container and the screen bottom
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
