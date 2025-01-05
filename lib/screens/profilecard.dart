import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ProfileCardPage extends StatelessWidget {
  final Map<String, dynamic> user; // User data passed as argument

  // Constructor to receive user data
  ProfileCardPage({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user['displayName'] ?? 'Unknown';
    final profilePhoto = user['profilePhoto'];
    final dateOfBirth = user['dateOfBirth']; // mm/dd/yy format
    final gender = user['gender'] ?? 'Not specified';
    final lookingFor = user['lookingFor'] ?? 'Not specified';
    final aboutMe = user['aboutMe'] ?? 'No about available';
    final isActive = user['isActive'] ?? false;

    // Parse the dateOfBirth if it's not null
    final age = dateOfBirth != null
        ? _calculateAge(dateOfBirth)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(displayName),
        actions: [
          IconButton(
            onPressed: () {
              // Handle block action here
              _blockUser(context);
            },
            icon: Icon(Icons.block, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey,
              child: profilePhoto != null
                  ? ClipOval(
                child: Image.network(
                  profilePhoto,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Icon(Icons.person, size: 60, color: Colors.white);
                  },
                ),
              )
                  : Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 32),  // Increased gap
            // Name, Age, and Online Status
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$displayName, ${age ?? "N/A"} years old',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),  // Increased gap
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: isActive ? Colors.green : Colors.red,
                    size: 10,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isActive ? 'Online Now' : 'Offline Now',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),  // Increased gap
            // Gender and Looking For
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gender: $gender',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),  // Increased gap
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Looking For: $lookingFor',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 32),  // Increased gap
            // Bio
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Me: $aboutMe',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Spacer(),  // This will push the footer to the bottom
            // Footer to send a message
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Padding from the bottom
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Say something...',
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.send,  // Send icon inside the message input
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to calculate age based on birthdate (mm/dd/yy format)
  int _calculateAge(String birthDate) {
    final dateFormat = DateFormat('MM/dd/yy'); // Define the custom date format
    final date = dateFormat.parse(birthDate); // Parse the date
    final currentDate = DateTime.now();
    int age = currentDate.year - date.year;
    if (currentDate.month < date.month ||
        (currentDate.month == date.month && currentDate.day < date.day)) {
      age--;
    }
    return age;
  }

  // Method to block the user (store in Blocklist.dart)
  void _blockUser(BuildContext context) {
    // Logic to add the user to a blocklist (could be a Firestore collection)
    print('User blocked! Add them to Blocklist collection.');

    // You can handle the block action and navigate to Blocklist screen here
    // For example, if you want to store the blocked user:
    // Firestore.firestore().collection('blockedUsers').add({...});

    // Navigate to the Blocklist page (optional)
    Navigator.pushNamed(context, '/blocklist');
  }
}
