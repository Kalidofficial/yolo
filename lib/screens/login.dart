import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _passwordVisible = false;
  bool _isEmailVerified = false;
  bool _isLoading = false;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        setState(() {
          _isEmailVerified = false;
        });
        // Show the email verification dialog
        _showEmailVerificationDialog();
      } else {
        setState(() {
          _isEmailVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful")),
        );
        // Redirect to HomePage.dart after successful login
        Navigator.pushReplacementNamed(context, '/HomePage');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      // Prompt for existing or new account
      _showGoogleAccountChoiceDialog(googleUser);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showGoogleAccountChoiceDialog(GoogleSignInAccount googleUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Google Login",
            style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange),
          ),
          content: Text(
            "Do you want to use your existing account or add a new one?",
            style: TextStyle(fontFamily: 'Jerry10', color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _signInWithExistingAccount(googleUser);
                Navigator.pop(context);
              },
              child: Text(
                "Use Existing Account",
                style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                _addNewAccount(googleUser);
                Navigator.pop(context);
              },
              child: Text(
                "Add New Account",
                style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signInWithExistingAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Login Successful")),
        );
        // Redirect to HomePage.dart after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _addNewAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This account is not registered. Please sign up.")),
        );
        // Navigate to the signup page with the user's email
        Navigator.pushNamed(context, '/signup', arguments: user.email);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Email Verification",
            style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange),
          ),
          content: Text(
            "Please verify your email address before logging in. Check your inbox for the verification link.",
            style: TextStyle(fontFamily: 'Jerry10', color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to your email.", style: TextStyle(fontFamily: 'Jerry10'))),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e", style: TextStyle(fontFamily: 'Jerry10'))),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _resetEmailController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Reset Password", style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange)),
          content: TextField(
            controller: _resetEmailController,
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(fontFamily: 'Jerry10', color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange)),
            ),
            TextButton(
              onPressed: () {
                if (_resetEmailController.text.isNotEmpty) {
                  _emailController.text = _resetEmailController.text;
                  _resetPassword();
                }
              },
              child: Text("Reset", style: TextStyle(fontFamily: 'Jerry10', color: Colors.orange)),
            ),
          ],
        );
      },
    );
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
              Navigator.pushNamed(context, '/signup');
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontFamily: 'Jerry10',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
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
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  fontFamily: 'Jerry10',
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Jerry10',
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                  fontFamily: 'Jerry10',
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              style: TextStyle(
                fontFamily: 'Jerry10',
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              child: Text(
                _isLoading ? "Logging in..." : "Login",
                style: TextStyle(
                  fontFamily: 'Jerry10',
                ),
              ),
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontFamily: 'Jerry10',
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Or",
                style: TextStyle(
                  fontFamily: 'Jerry10',
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loginWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              icon: Icon(Icons.login),
              label: Text(
                "Login with Google",
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
}
