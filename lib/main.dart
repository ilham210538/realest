import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realest/CarSearchPage.dart';
import 'package:realest/PreprocessingTestPage.dart';
import 'package:realest/firebase_options.dart';
import 'package:realest/profileHistory.dart';
import 'image_display.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'loginPage.dart'; // Import your login screen

final ImagePicker _picker = ImagePicker();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(CarClassificationApp());
}

class CarClassificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Classification',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 128, 0, 32),
        scaffoldBackgroundColor: Color.fromARGB(255, 245, 245, 220),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 128, 0, 32),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      initialRoute: '/main',
      routes: {
        '/home': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return MainPage();
        }
        return LoginScreen();
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin<MainPage> {
  @override
  bool get wantKeepAlive => true;
  String? notificationMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final User? user = FirebaseAuth.instance.currentUser;
      final String? email = user?.email;

      if (email != null) {
        setState(() {
          notificationMessage = "Logged in as $email";
        });

        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            notificationMessage = null;
          });
        });
      }
    });
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Custom background color
          title: Text(
            "Log Out",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 128, 0, 32), // Custom color for title
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w400, // Muted color for content text
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(
                    255, 128, 0, 32), // Custom primary color for Cancel button
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled the logout
              },
              child: Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.red, // Contrasting color (red) for Log Out button
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the logout
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required to keep alive the state
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AutoScan',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 245, 245, 220),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.settings,
              size: 32,
              color: Color.fromARGB(
                  255, 245, 245, 220), // Custom color for the settings icon
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              } else if (value == 'logout') {
                // Show confirmation dialog for logout
                bool? confirmLogout = await _showLogoutDialog(context);
                if (confirmLogout == true) {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 30,
                        color: Color.fromARGB(255, 128, 0, 32),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Profile View',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Custom color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history,
                          size: 30, color: Color.fromARGB(255, 128, 0, 32)),
                      SizedBox(width: 10),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Custom color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 30, color: Color.fromARGB(255, 128, 0, 32)),
                      SizedBox(width: 10),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Custom color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            color: Color.fromARGB(
                255, 245, 245, 220), // Background color for the menu
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Rounded corners for the menu
            ),
            elevation: 4, // Shadow for the popup
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/AUTOSCAN-removebg-preview.png',
                    width: 700,
                  ),
                ),
                Text(
                  'Welcome to AUTOSCAN!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 128, 0, 32),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'An app created to predict car models from images',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 128, 0, 32),
                  ),
                ),
// Predict from Camera Button
                SizedBox(height: 35),
                _buildButton(
                  context,
                  label: 'Predict from Camera',
                  icon: Icons.camera_alt,
                  onPressed: () async {
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageDisplay(image: File(pickedFile.path)),
                        ),
                      );
                    }
                  },
                ),

// Predict from Gallery Button
                SizedBox(height: 20),
                _buildButton(
                  context,
                  label: 'Predict from Gallery',
                  icon: Icons.photo_library,
                  onPressed: () async {
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageDisplay(image: File(pickedFile.path)),
                        ),
                      );
                    }
                  },
                ),

                SizedBox(height: 20),
                _buildButton(
                  context,
                  label: 'Search a Car',
                  icon: Icons.search,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarSearchPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          if (notificationMessage != null)
            Positioned(
              top: 5,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: Color.fromARGB(255, 128, 0, 32),
                  child: Text(
                    notificationMessage!,
                    style: TextStyle(
                      color: Color.fromARGB(255, 245, 245, 220),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Color.fromARGB(255, 245, 245, 220)),
      label: Text(
        label,
        style: TextStyle(color: Color.fromARGB(255, 245, 245, 220)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
        padding: EdgeInsets.symmetric(vertical: 15),
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
