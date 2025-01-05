import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'profile_photo.dart'; // Import the ProfilePhotoScreen
import 'homepage.dart'; // Import the HomePage

class CompleteProfileScreen extends StatefulWidget {
  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? selectedGender;
  String? selectedLookingFor;
  String displayName = '';
  String aboutMe = '';
  String dateOfBirth = '';
  String? _base64Image;

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  // Fetch image from Firestore when the screen is loaded
  Future<void> _fetchProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _base64Image = userDoc['profilePhoto']; // Fetch base64 string
        });
      }
    }
  }

  // Save profile details to Firestore
  Future<void> _saveProfileDetails() async {
    if (displayName.isEmpty || aboutMe.isEmpty || dateOfBirth.isEmpty || selectedGender == null || selectedLookingFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'displayName': displayName,
            'aboutMe': aboutMe,
            'dateOfBirth': dateOfBirth,
            'gender': selectedGender,
            'lookingFor': selectedLookingFor,
          },
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile details saved successfully!')),
        );

        // Navigate to the HomePage after saving the details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile details: $e')),
        );
      }
    }
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        dateOfBirth = DateFormat('MM/dd/yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Complete Profile',
          style: TextStyle(
            fontFamily: 'Jersey10',
            color: Color(0xFFFF6100),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "First Things First",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jersey10',
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Finish up Profile Details to Start",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Jersey10',
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePhotoScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            "Add Photo",
                            style: TextStyle(
                              fontFamily: 'Jersey10',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Verify Photo functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            "Verify Photo",
                            style: TextStyle(
                              fontFamily: 'Jersey10',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Display Name
              TextField(
                controller: displayNameController,
                onChanged: (value) {
                  displayName = value;
                },
                style: TextStyle(color: Colors.white, fontFamily: 'Jersey10'),
                decoration: InputDecoration(
                  labelText: "Display Name",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6100)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // About Me
              TextField(
                controller: aboutMeController,
                onChanged: (value) {
                  aboutMe = value;
                },
                style: TextStyle(color: Colors.white, fontFamily: 'Jersey10'),
                decoration: InputDecoration(
                  labelText: "About Me",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6100)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Date of Birth - Date Picker
              Text(
                "Date of Birth",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Jersey10',
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(text: dateOfBirth),
                          style: TextStyle(color: Colors.white, fontFamily: 'Jersey10'),
                          decoration: InputDecoration(
                            hintText: "MM/DD/YYYY",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFF6100)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: selectedGender,
                dropdownColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Gender",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6100)),
                  ),
                ),
                items: ["Male", "Female"].map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              SizedBox(height: 16),
              // Looking For Dropdown
              DropdownButtonFormField<String>(
                value: selectedLookingFor,
                dropdownColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Looking For",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6100)),
                  ),
                ),
                items: ["Friends", "Meetup", "Time Pass"].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedLookingFor = value;
                  });
                },
              ),
              SizedBox(height: 32),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfileDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6100),
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontFamily: 'Jersey10',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
