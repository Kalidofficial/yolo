import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoScreen extends StatefulWidget {
  @override
  _ProfilePhotoScreenState createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _photos = [];

  Future<void> _addPhoto() async {
    if (_photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload up to 3 photos.')),
      );
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photos.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Profile Photos',
          style: TextStyle(
            fontFamily: 'Jersey10',
            color: Color(0xFFFF6100),
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // Makes the arrow white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Your Photos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jersey10',
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You can upload up to 3 photos",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontFamily: 'Jersey10',
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildPhotoCard(index < _photos.length ? _photos[index] : null);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(File? photo) {
    return GestureDetector(
      onTap: photo == null ? _addPhoto : null, // Only add photo on empty card
      child: Card(
        color: Colors.grey[800],
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: double.infinity,  // Allow the card to take the full width
          height: 300,  // Set a fixed height for the card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),  // Optional rounded corners
          ),
          child: photo != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),  // Round the image corners
            child: AspectRatio(
              aspectRatio: 1.0, // Adjust to your preferred aspect ratio
              child: Image.file(
                photo,
                fit: BoxFit.contain,  // Ensure image fits within the card without distortion
                width: double.infinity,  // Ensures the image fills the width of the card
                height: double.infinity, // Ensures the image fills the height of the card
              ),
            ),
          )
              : Center(
            child: Icon(Icons.add, size: 50, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}