import 'package:a_guarante/dashboard/mainnavigatinscreen.dart';
import 'package:a_guarante/documents.dart';
import 'package:a_guarante/screens/Document_select_screen.dart';
import 'package:a_guarante/screens/home_screen.dart';
import 'package:a_guarante/screens/login_screen.dart';
import 'package:a_guarante/screens/notifiction_service.dart';
import 'package:a_guarante/screens/setting_screen.dart';
import 'package:a_guarante/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:WelcomeScreen(),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => UploadDocumentScreen(),
      //   '/login': (context) => LoginScreen(),
      //   '/register': (context) => RegisterScreen(),
      //   'home': (context) => HomeScreen(), // MainNavigationScreen as the main app screen
      // },
    );
  }
}
