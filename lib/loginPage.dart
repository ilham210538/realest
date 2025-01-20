import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage;

  void _login() async {
    try {
      // Attempt to log in with the provided email and password
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to the home page on successful login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      String errorText = 'An unknown error occurred. Please try again.';

      // Log the exception for debugging
      print('Error: $e');

      if (e is FirebaseAuthException) {
        // Log the error code and message to help with debugging
        print('Firebase Auth Error: ${e.code}');
        print('Error details: ${e.message}');

        // Handle specific FirebaseAuthException error codes
        switch (e.code) {
          case 'user-not-found':
            errorText =
                'No user found with this email. Please check the email address or sign up if you don\'t have an account.';
            break;
          case 'wrong-password':
            errorText = 'Incorrect password. Please check and try again.';
            break;
          case 'invalid-email':
            errorText =
                'The email address is invalid. Please enter a valid email address.';
            break;
          case 'user-disabled':
            errorText =
                'Your account has been disabled. Please contact support for further assistance.';
            break;
          case 'too-many-requests':
            errorText =
                'Too many login attempts. Please try again later or reset your password if needed.';
            break;
          case 'email-already-in-use':
            errorText =
                'This email is already associated with an account. Please log in or reset your password if you forgot it.';
            break;
          default:
            errorText = 'An error occurred. Please try again later.';
            break;
        }
      } else {
        // In case it's not a FirebaseAuthException, log it as a general error
        errorText = 'An unknown error occurred. Please try again.';
        print('Non-Firebase error: $e');
      }

      // Update UI to show the error message
      setState(() {
        errorMessage = errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AutoScan"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32), // AppBar background
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 245, 245, 220), // Title text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: SingleChildScrollView(
          // Enables scrolling
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures horizontal stretching
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/AUTOSCAN-removebg-preview.png',
                  width: 400,
                ),
              ),
              Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 128, 0, 32),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Enter credentials to log in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 128, 0, 32),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              // Display a user-friendly error message
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 128, 0, 32),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor:
                      Color.fromARGB(255, 245, 245, 220), // Text color (beige)
                  minimumSize: Size(250, 45),
                ),
                child: Text("Login"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Color.fromARGB(255, 128, 0, 32)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage;

  void _signup() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to the home page after successful signup
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      String errorText = 'An unknown error occurred. Please try again.';

      if (e is FirebaseAuthException) {
        print('Firebase Auth Error: ${e.code}'); // Log error code

        switch (e.code) {
          case 'email-already-in-use':
            errorText =
                'An account already exists with this email. Please use a different email or log in if you already have an account.';
            break;
          case 'weak-password':
            errorText =
                'The password is too weak. Please choose a stronger password.';
            break;
          case 'invalid-email':
            errorText =
                'The email address is invalid. Please enter a valid email address.';
            break;
          default:
            errorText =
                'An error occurred during signup. Please try again later.';
            break;
        }
      }

      setState(() {
        errorMessage = errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AutoScan"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32), // AppBar background
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 245, 245, 220), // Title text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: SingleChildScrollView(
          // Added to make the page scrollable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures widgets stretch if needed
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/AUTOSCAN-removebg-preview.png',
                  width: 400,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Account Creation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 128, 0, 32),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Please create an account to access features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 128, 0, 32),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 128, 0, 32),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor:
                      Color.fromARGB(255, 245, 245, 220), // Text color (beige)
                  minimumSize: Size(250, 45),
                ),
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
