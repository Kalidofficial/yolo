import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Authentication import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dummy blocked users list (replace with actual data from your system)
  List<String> blockedUsers = [""];

  // Function to deactivate account
  Future<void> _deactivateAccount() async {
    try {
      await _auth.currentUser?.delete();
      Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to unblock user
  void _unblockUser(String userEmail) {
    setState(() {
      blockedUsers.remove(userEmail); // Remove from blocked list
    });
  }

  // Function to reset password
  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Deactivate Account
            ListTile(
              title: Text('Deactivate Account'),
              onTap: () {
                _deactivateAccount();
              },
            ),
            Divider(),

            // Blocked Users List
            ListTile(
              title: Text('Block List'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Blocked Users'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: blockedUsers.map((user) {
                          return ListTile(
                            title: Text(user),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                _unblockUser(user); // Remove from blocked list
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Divider(),

            // Reset Password
            ListTile(
              title: Text('Reset Password'),
              onTap: () {
                _resetPassword();
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
