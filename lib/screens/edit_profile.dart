import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking image from gallery
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controllers for form fields
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _aboutMeController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _lookingForController = TextEditingController();
  String? _profilePhoto;
  bool _isEditingDisplayName = false;
  bool _isEditingAboutMe = false;
  bool _isEditingDateOfBirth = false;
  bool _isEditingGender = false;
  bool _isEditingLookingFor = false;

  // Firebase user
  User? currentUser;
  String? currentDisplayName;
  String? currentAboutMe;
  String? currentDateOfBirth;
  String? currentGender;
  String? currentLookingFor;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (currentUser != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            currentDisplayName = userData?['displayName'];
            currentAboutMe = userData?['aboutMe'];
            currentDateOfBirth = userData?['dateOfBirth'];
            currentGender = userData?['gender'];
            currentLookingFor = userData?['lookingFor'];
            _profilePhoto = userData?['profilePhoto'];
            _displayNameController.text = currentDisplayName ?? '';
            _aboutMeController.text = currentAboutMe ?? '';
            _dateOfBirthController.text = currentDateOfBirth ?? '';
            _genderController.text = currentGender ?? '';
            _lookingForController.text = currentLookingFor ?? '';
          });
        }
      } catch (e) {
        print("Error retrieving user data: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the image to Firebase Storage and get the URL
      setState(() {
        _profilePhoto = pickedFile.path; // For now, using the file path instead of Firebase Storage URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Picture Section
              GestureDetector(
                onTap: () {
                  _showImageViewer();
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey,
                  backgroundImage: _profilePhoto != null
                      ? NetworkImage(_profilePhoto!)
                      : null,
                  child: _profilePhoto == null
                      ? Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
              SizedBox(height: 20),

              // View or Change Profile Picture Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Change Profile Pic', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _showImageViewer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('View Profile Pic', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Display Name
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditingDisplayName = !_isEditingDisplayName;
                        });
                      },
                      child: _isEditingDisplayName
                          ? TextFormField(
                        controller: _displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : Text(
                        currentDisplayName ?? 'No display name',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // About Me Input
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditingAboutMe = !_isEditingAboutMe;
                        });
                      },
                      child: _isEditingAboutMe
                          ? TextFormField(
                        controller: _aboutMeController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'About Me',
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : Text(
                        currentAboutMe ?? 'No About Me available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Date of Birth
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditingDateOfBirth = !_isEditingDateOfBirth;
                        });
                      },
                      child: _isEditingDateOfBirth
                          ? TextFormField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : Text(
                        currentDateOfBirth ?? 'No date of birth',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Gender
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditingGender = !_isEditingGender;
                        });
                      },
                      child: _isEditingGender
                          ? TextFormField(
                        controller: _genderController,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : Text(
                        currentGender ?? 'No gender specified',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Looking For
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditingLookingFor = !_isEditingLookingFor;
                        });
                      },
                      child: _isEditingLookingFor
                          ? TextFormField(
                        controller: _lookingForController,
                        decoration: InputDecoration(
                          labelText: 'Looking For',
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : Text(
                        currentLookingFor ?? 'Not specified',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  // Save the changes and show confirmation box
                  final confirmation = await _showConfirmationDialog();
                  if (confirmation == true) {
                    // Update Firestore with new data
                    await _firestore.collection('users').doc(currentUser!.uid).update({
                      'displayName': _displayNameController.text,
                      'aboutMe': _aboutMeController.text,
                      'dateOfBirth': _dateOfBirthController.text,
                      'gender': _genderController.text,
                      'lookingFor': _lookingForController.text,
                      'profilePhoto': _profilePhoto, // Update the profile photo field
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated successfully!')),
                    );
                    Navigator.pop(context); // Go back after saving
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog before saving
  Future<bool?> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Changes'),
          content: Text('Are you sure you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Show profile image in full screen
  void _showImageViewer() {
    if (_profilePhoto != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Image.network(_profilePhoto!),
          );
        },
      );
    }
  }
}
