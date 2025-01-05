import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'edit_profile.dart'; // Import the edit profile screen
import 'settings.dart'; // Import the settings screen
import 'login.dart'; // Import the login screen
import 'package:firebase_auth/firebase_auth.dart';

class UserAccountsPage extends StatefulWidget {
  @override
  _UserAccountsPageState createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends State<UserAccountsPage> {
  bool isGhostMode = false; // Track whether Ghost Mode is on
  late String displayName = 'Loading...'; // Default value while fetching data
  late String profilePicUrl = ''; // Profile picture URL

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore or Firebase Authentication
  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        displayName = userDoc['displayName'] ?? 'displayName'; // Replace with field in Firestore
        profilePicUrl = userDoc['profilePicUrl'] ?? ''; // Replace with profile pic field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Dirty white background
      appBar: AppBar(
        title: Text('User Account'),
        backgroundColor: Colors.red, // AppBar color
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Pic and Display Name
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: profilePicUrl.isNotEmpty
                        ? Image.network(
                      profilePicUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 50, color: Colors.white);
                      },
                    )
                        : Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  displayName,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(height: 20),
                // Online Mode Toggle
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isGhostMode ? Colors.grey : Colors.green,
                      size: 10,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isGhostMode ? 'Ghost Mode' : 'Online',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Switch(
                      value: isGhostMode,
                      onChanged: (value) async {
                        // Show confirmation dialog before switching
                        bool? confirmed = await _showConfirmationDialog();
                        if (confirmed == true) {
                          setState(() {
                            isGhostMode = value;
                          });
                        }
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Edit Profile Button
                _buildDrawerItem(
                  icon: Icons.edit,
                  text: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Settings Button
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Logout Button
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text("Main Content Goes Here"),
      ),
    );
  }

  // Function to build each item in the drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.grey[800],
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the confirmation dialog when toggling Ghost Mode
  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to turn on Ghost Mode?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User cancels
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // User confirms
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
