import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_profile.dart';
import 'login.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  TextEditingController _searchController = TextEditingController();
  String displayName = 'No Name';
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      _fetchUserDisplayName();
      _fetchUsers();
    }
  }

  Future<void> _fetchUserDisplayName() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          displayName = userDoc['displayName'] ?? 'No Name';
        });
      }
    } catch (e) {
      print('Error fetching display name: $e');
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      final currentUserEmail = currentUser?.email;
      setState(() {
        allUsers = querySnapshot.docs
            .where((userDoc) {
          final user = userDoc.data() as Map<String, dynamic>;
          return user['email'] != currentUserEmail; // Exclude current user's profile
        })
            .toList();
        filteredUsers = List.from(allUsers);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Users...",
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              filteredUsers = allUsers.where((userDoc) {
                final user = userDoc.data() as Map<String, dynamic>;
                final displayName = user['displayName'] ?? '';
                return displayName.toLowerCase().contains(value.toLowerCase());
              }).toList();
            });
          },
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: currentUser?.photoURL != null
                        ? Image.network(
                      currentUser!.photoURL!,
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
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 20),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredUsers.isEmpty
          ? Center(child: Text('No users found', style: TextStyle(color: Colors.white)))
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final userDoc = filteredUsers[index];
          final user = userDoc.data() as Map<String, dynamic>;
          final isActive = user['isActive'] ?? false;
          final displayName = user['displayName'] ?? 'Unknown';
          final profilePhoto = user['profilePhoto'];
          final dateOfBirth = user['dateOfBirth'];
          final age = dateOfBirth != null
              ? _calculateAge(_parseDate(dateOfBirth))
              : null;

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profilecard', arguments: user);
            },
            child: Card(
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: ClipOval(
                      child: profilePhoto != null
                          ? Image.network(
                        profilePhoto,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 50, color: Colors.white);
                        },
                      )
                          : Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    displayName,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  if (age != null)
                    Text(
                      '$age years old',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  SizedBox(height: 5),
                  Icon(
                    Icons.circle,
                    color: isActive ? Colors.green : Colors.red,
                    size: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Home already selected
          } else if (index == 1) {
            Navigator.pushNamed(context, '/inbox');
          }
        },
      ),
    );
  }

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

  int? _calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  DateTime _parseDate(String dateStr) {
    try {
      final format = DateFormat('MM/dd/yyyy');
      return format.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }
}