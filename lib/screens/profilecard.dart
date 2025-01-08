import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inbox.dart'; // Import the Inbox page
import 'package:firebase_auth/firebase_auth.dart'; // For getting the current user's ID

class ProfileCardPage extends StatefulWidget {
  final Map<String, dynamic> user; // User data passed as argument
  final String currentUserId; // Current user ID for sending message

  ProfileCardPage({required this.user, required this.currentUserId});

  @override
  _ProfileCardPageState createState() => _ProfileCardPageState();
}

class _ProfileCardPageState extends State<ProfileCardPage> {
  @override
  Widget build(BuildContext context) {
    final displayName = widget.user['displayName'] ?? 'Unknown';
    final profilePhoto = widget.user['profilePhoto'];
    final dateOfBirth = widget.user['dateOfBirth']; // mm/dd/yy format
    final gender = widget.user['gender'] ?? 'Not specified';
    final lookingFor = widget.user['lookingFor'] ?? 'Not specified';
    final aboutMe = widget.user['aboutMe'] ?? 'No about available';
    final isActive = widget.user['isActive'] ?? false;

    final age = dateOfBirth != null ? _calculateAge(dateOfBirth) : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(displayName),
        actions: [
          IconButton(
            onPressed: () {
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
                    return Icon(Icons.person, size: 60, color: Colors.white);
                  },
                ),
              )
                  : Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$displayName, ${age ?? "N/A"} years old',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gender: $gender',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Looking For: $lookingFor',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Me: $aboutMe',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: () {
                  _sendMessage(context);
                },
                child: Text(
                  'Send Message',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAge(String birthDate) {
    final dateFormat = DateFormat('MM/dd/yy');
    final date = dateFormat.parse(birthDate);
    final currentDate = DateTime.now();
    int age = currentDate.year - date.year;
    if (currentDate.month < date.month ||
        (currentDate.month == date.month && currentDate.day < date.day)) {
      age--;
    }
    return age;
  }

  void _blockUser(BuildContext context) {
    print('User blocked!');
  }

  void _sendMessage(BuildContext context) async {
    try {
      final receiverDisplayName = widget.user['displayName'];
      if (receiverDisplayName == null || receiverDisplayName.isEmpty) {
        print('Error: Receiver display name is missing.');
        return;
      }

      final senderId = widget.currentUserId;

      // Fetch receiver user ID based on their display name
      final receiverSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isEqualTo: receiverDisplayName)
          .get();

      if (receiverSnapshot.docs.isEmpty) {
        print('Error: Receiver not found.');
        return;
      }

      final receiverId = receiverSnapshot.docs.first.id;

      final chatId = _generateChatId(senderId, receiverId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InboxPage(
            chatId: chatId,
            senderId: senderId,
            receiverId: receiverId,
          ),
        ),
      );
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  String _generateChatId(String user1, String user2) {
    // Generate a chat ID by sorting the user IDs to create a unique, ordered chat ID
    return '${user1.compareTo(user2) < 0 ? user1 : user2}_${user1.compareTo(user2) < 0 ? user2 : user1}';
  }
}
