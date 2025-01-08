import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InboxPage extends StatefulWidget {
  final String chatId;
  final String senderId;
  final String receiverId;

  const InboxPage({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
  });

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _messageController = TextEditingController();
  String receiverName = '';

  @override
  void initState() {
    super.initState();
    _fetchReceiverName();
  }

  // Fetch the receiver's display name from Firestore
  Future<void> _fetchReceiverName() async {
    try {
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverId)
          .get();
      if (receiverDoc.exists) {
        setState(() {
          receiverName = receiverDoc['displayName'] ?? 'Unknown';
        });
      }
    } catch (error) {
      print('Error fetching receiver name: $error');
    }
  }

  // Send a message and save it to Firestore
  void _sendMessage() async {
    try {
      final String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';  // Get the current user's ID
      if (senderId.isEmpty) {
        print('Error: Sender ID is empty.');
        return;
      }

      final String receiverId = widget.receiverId;

      final messageText = _messageController.text.trim();
      if (messageText.isEmpty) return;

      // Add the message to Firestore under the correct chat collection
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': senderId,  // Ensure senderId is added to the message data
        'message': messageText,  // Use the message from the text field
        'timestamp': FieldValue.serverTimestamp(),
        'receiverId': receiverId,  // Ensure receiverId is added as well
      });

      _messageController.clear();  // Clear the message input field
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName.isNotEmpty ? receiverName : 'Chat'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isSentByCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser ? Colors.red : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['message'] ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
