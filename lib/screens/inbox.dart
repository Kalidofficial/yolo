import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InboxPage extends StatelessWidget {
  final String currentUserId;
  final String receiverId;

  // Constructor to receive parameters
  InboxPage({required this.currentUserId, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Inbox'),
          backgroundColor: Colors.black,
        ),
        body: Center(child: Text('User ID is empty!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users') // Ensure this is the correct collection name
            .doc(currentUserId) // currentUserId used to access the correct document
            .collection('inbox') // Assuming 'inbox' is a subcollection under 'users'
            .orderBy('timestamp') // Ensure 'timestamp' is a valid field for sorting
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages yet'));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final senderId = message['senderId'];
              final messageText = message['message'];
              final timestamp = message['timestamp'];

              final isSender = senderId == currentUserId;

              return Align(
                alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blue : Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      messageText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
