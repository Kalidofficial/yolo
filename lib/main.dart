import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/inbox.dart';
import 'screens/login.dart';
import 'screens/profilecard.dart';
import 'screens/signup.dart';
import 'screens/complete_profile.dart'; // Import your complete profile screen
import 'screens/homepage.dart'; // Import your HomePage screen
import 'screens/user_account.dart';
import 'screens/edit_profile.dart'; // Import Edit Profile page
import 'screens/settings.dart'; // Import Settings page

void main() async {
  // Ensure widgets are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/login', // Start from the login screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/complete_profile': (context) => CompleteProfileScreen(), // Complete profile screen route
        '/HomePage': (context) => HomePage(), // Home page route should be '/home'
        '/profilecard': (context) => ProfileCardPage(
          user: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
          currentUserId: '', // You will need to pass the current user ID here
        ),
        '/user_account': (context) => UserAccountsPage(), // Add route for user account page
        '/edit_profile': (context) => EditProfilePage(), // Add route for edit profile page
        '/settings': (context) => SettingsPage(), // Add route for settings page
        '/inbox': (context) => InboxPage(
          currentUserId: '', receiverId: '',
        ),
      },
    );
  }
}
