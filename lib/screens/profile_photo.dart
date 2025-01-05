import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePhotoScreen extends StatefulWidget {
  @override
  _ProfilePhotoScreenState createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  File? _imageFile;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _base64Image = userDoc['profilePhoto']; // Fetch base64 string
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in.');
      }

      // Convert image to base64 string
      final bytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(bytes);

      // Save the base64 string to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'profilePhoto': base64Image, // Save the image as base64 string
        },
        SetOptions(merge: true),
      );

      setState(() {
        _isUploading = false;
        _base64Image = base64Image; // Update the displayed image
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Profile Photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _imageFile != null
                ? CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(_imageFile!),
            )
                : _base64Image != null
                ? CircleAvatar(
              radius: 60,
              backgroundImage: MemoryImage(base64Decode(_base64Image!)),
            )
                : CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
