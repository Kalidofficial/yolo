import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;
  bool _isLoading = false;

  Future<void> _signUpUser() async {
    // Check if passwords match
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading screen
    });

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Successful! A verification email has been sent.")),
      );

      // Check email verification status
      await _checkEmailVerification(userCredential);
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading screen in case of error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _checkEmailVerification(UserCredential userCredential) async {
    bool isVerified = false;

    while (!isVerified) {
      await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds before rechecking
      await userCredential.user?.reload(); // Reload the user to update their status
      isVerified = userCredential.user?.emailVerified ?? false;

      if (isVerified) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to the complete profile screen
        Navigator.pushReplacementNamed(context, '/complete_profile');
        break; // Exit the loop
      }
    }

    if (!isVerified) {
      setState(() {
        _isLoading = false;
      });

      // Notify the user to verify their email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please verify your email before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Container(),
        title: null,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text(
              "Login",
              style: TextStyle(
                fontFamily: 'Jerry10',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(), // Show loading screen while signing up
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "YOLO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jerry10',
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 50),
            _buildTextField(_emailController, "Email", false),
            SizedBox(height: 20),
            _buildTextField(_passwordController, "Password", true),
            SizedBox(height: 20),
            _buildTextField(_confirmPasswordController, "Confirm Password", true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontFamily: 'Jerry10',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure ? !_passwordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Jerry10',
          color: Colors.white,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: obscure
            ? IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        )
            : null,
      ),
      style: TextStyle(
        fontFamily: 'Jerry10',
        color: Colors.white,
      ),
    );
  }
}
