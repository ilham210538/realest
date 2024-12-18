import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:realest/CarSearchPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void confirmSignOut() {
    if (!mounted) return; // Check if the widget is still in the tree
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Sign Out",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 128, 0, 32),
          ),
        ),
        content: Text(
          "Are you sure you want to sign out?",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 128, 0, 32),
            ),
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text("Sign Out"),
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out: $e")),
      );
    }
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32), // AppBar background
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 245, 245, 220), // Title text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome,",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              _user?.email ?? "User Email",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 30),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.lock_outline,
              ),
              title: Text("Change Password"),
              onTap: _changePassword,
            ),
            ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Color.fromARGB(
                    255, 128, 0, 32), // Custom color for the icon
              ),
              title: Text(
                "Sign Out",
                style: TextStyle(
                  color: Color.fromARGB(
                      255, 128, 0, 32), // Custom color for the text
                ),
              ),
              onTap:
                  confirmSignOut, // Call the confirmSignOut function when tapped
            )
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();

  void _updatePassword() async {
    String newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password cannot be empty!")),
      );
      return;
    }

    try {
      await _auth.currentUser?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32), // AppBar background
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 245, 245, 220), // Title text color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter New Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 128, 0, 32),
              ),
              child: Text(
                "Update Password",
                style: TextStyle(
                  color: Color.fromARGB(255, 245, 245, 220),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteExcessEntries(DocumentReference userHistoryDoc) async {
  try {
    // Fetch current history entries
    DocumentSnapshot userHistorySnapshot = await userHistoryDoc.get();

    if (userHistorySnapshot.exists) {
      List entries =
          (userHistorySnapshot.data() as Map<String, dynamic>)['entries'] ?? [];

      // Sort entries by timestamp (descending)
      entries.sort((a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

      // If there are more than 20 entries, delete older ones
      if (entries.length > 20) {
        // Get entries to delete (older than the 20 most recent)
        List entriesToDelete = entries.skip(20).toList();

        for (var entry in entriesToDelete) {
          // Here, you can remove entries from the array in Firestore
          await userHistoryDoc.update({
            'entries': FieldValue.arrayRemove([entry])
          });
        }
      }
    }
  } catch (e) {
    print("Error deleting excess entries: $e");
  }
}

Future<void> addHistoryEntry(String action, String carName) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userId = _auth.currentUser?.uid ?? '';
  if (userId.isEmpty || action.isEmpty || carName.isEmpty) {
    print("Invalid input or user not signed in.");
    return;
  }

  try {
    DocumentReference userHistoryDoc =
        _firestore.collection('history').doc(userId);

    // Prepare the history entry with server timestamp
    Map<String, dynamic> newEntry = {
      'action': action,
      'car_name':
          carName.replaceAll('_', ' '), // Replace underscores with spaces
      'timestamp': Timestamp.now(),
    };

    // Add new entry to Firebase
    await userHistoryDoc.set({
      'entries': FieldValue.arrayUnion([newEntry]),
    }, SetOptions(merge: true)); // Merge to avoid overwriting existing fields

    // Fetch the current entries and delete older ones if there are more than 20
    await _deleteExcessEntries(userHistoryDoc);

    print("History entry added for user: $userId");
  } catch (e) {
    print("Failed to add history entry: $e");
  }
}

Stream<List<Map<String, dynamic>>> _mapHistoryStream(String userId) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  return _firestore
      .collection('history')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists && snapshot.data() != null) {
      List entries = (snapshot.data() as Map<String, dynamic>)['entries'] ?? [];

      // Sort entries to make sure they are in the correct order
      entries.sort((a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

      // Convert the Iterable to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(entries.take(20));
    }
    return [];
  });
}

Future<void> _limitHistoryEntries(DocumentReference userHistoryDoc) async {
  try {
    // Fetch the current history entries for the user
    DocumentSnapshot userHistorySnapshot = await userHistoryDoc.get();

    // If history exists and has more than 20 entries
    if (userHistorySnapshot.exists) {
      List entries =
          (userHistorySnapshot.data() as Map<String, dynamic>)['entries'] ?? [];

      if (entries.length > 20) {
        // Sort entries by timestamp and remove the oldest ones (FIFO)
        entries.sort((a, b) => (b['timestamp'] as Timestamp)
            .compareTo(a['timestamp'] as Timestamp));

        // Slice the list to only keep the 20 most recent entries
        entries = entries.take(20).toList();

        // Update the entries to keep only the most recent 20
        await userHistoryDoc.update({
          'entries': entries,
        });
      }
    }
  } catch (e) {
    print("Error limiting history entries: $e");
  }
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String userId = _auth.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'History',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 245, 245, 220),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 128, 0, 32),
        ),
        body: Center(child: Text("No user is signed in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 245, 245, 220),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with 'Name' and 'Date'
            Row(
              children: [
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Car Name',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color.fromARGB(255, 128, 0, 32),
                    ),
                  ),
                ),
                SizedBox(width: 80),
                Expanded(
                  child: Text(
                    'Date & Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color.fromARGB(255, 128, 0, 32),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.black54),

            // StreamBuilder for displaying history entries
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _mapHistoryStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading history"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No history found"));
                }

                final historyEntries = snapshot.data!;

                // Ensure we don't have more than 20 entries
                if (historyEntries.length > 20) {
                  historyEntries.sublist(20).forEach((entry) async {
                    // Delete old entries beyond the 20 most recent ones
                    await deleteHistoryEntry(userId, entry['timestamp']);
                  });
                }

                historyEntries.sort((a, b) => (b['timestamp'] as Timestamp)
                    .compareTo(a['timestamp'] as Timestamp));

                return Expanded(
                  child: ListView.builder(
                    itemCount: historyEntries.length,
                    itemBuilder: (context, index) {
                      final entry = historyEntries[index];
                      final action = entry['action'] ?? 'Unknown';
                      final carName = entry['car_name'] ?? 'Unknown';
                      final timestamp =
                          (entry['timestamp'] as Timestamp?)?.toDate();

                      return Column(
                        children: [
                          Dismissible(
                            key: Key(entry['timestamp']
                                .toString()), // Unique key for each item
                            direction: DismissDirection
                                .endToStart, // Only allow swipe left
                            background: Container(
                              color: Color.fromARGB(255, 128, 0,
                                  32), // Swipe-to-delete background color
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.delete,
                                color: Color.fromARGB(255, 245, 245, 220),
                              ),
                            ),
                            onDismissed: (direction) async {
                              // Delete entry from Firestore
                              await deleteHistoryEntry(userId, entry);

                              // Remove entry from the local list (UI update)
                              setState(() {
                                historyEntries.removeAt(index);
                              });

                              // Show confirmation snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$carName deleted')),
                              );
                            },

                            child: ListTile(
                              title: Text(
                                carName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Action: $action",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: timestamp != null
                                  ? Text(
                                      DateFormat('yyyy-MM-dd HH:mm')
                                          .format(timestamp),
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  : null,
                              onTap: () async {
                                // Handle the tap to fetch car info
                                print("Selected car name: $carName");
                                Map<String, String> carInfo = await _getCarInfo(
                                    _formatCarIdForFirestore(carName));
                                showDialog(
                                  context: context,
                                  builder: (_) => CarInfoDialog(
                                    carName: carName,
                                    carInfo: carInfo,
                                  ),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 10,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> deleteHistoryEntry(
    String userId, Map<String, dynamic> entry) async {
  try {
    // Reference to the history collection for the user
    final userHistoryDoc =
        FirebaseFirestore.instance.collection('history').doc(userId);

    // Delete the specific entry using its exact data (rather than just the timestamp)
    await userHistoryDoc.update({
      'entries':
          FieldValue.arrayRemove([entry]), // Remove the exact entry object
    });

    print("Entry successfully deleted from Firebase");
  } catch (e) {
    print("Error deleting history entry: $e");
  }
}

String _formatCarIdForFirestore(String carName) {
  return carName.replaceAll(' ', '_');
}

Future<Map<String, String>> _getCarInfo(String carId) async {
  await Firebase.initializeApp();
  Map<String, String> carInfo = {};
  print("Fetching car info for carId: $carId");
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('car_info')
        .doc(carId)
        .get();
    if (doc.exists) {
      carInfo = {
        'Make': doc['Make'] ?? 'N/A',
        'Model': doc['Model'] ?? 'N/A',
        'Generation': doc['Generation'] ?? 'N/A',
        'Peninsular Price': doc['Peninsular'] ?? 'N/A',
        'Insurance': doc['Insurance'] ?? 'N/A',
        'Roadtax': doc['Road Tax'] ?? 'N/A',
        'Audio': doc['Audio'] ?? 'N/A',
        '0-100 km/h': _formatField(doc.get(FieldPath(['0-100 km/h']))),
        'Airbags': doc['Airbags'] ?? 'N/A',
        'Arrangement': doc['Arrangement'] ?? 'N/A',
        'Assembly': doc['Assembly'] ?? 'N/A',
        'Auto Headlamps': doc['Auto Headlamps'] ?? 'N/A',
        'Auto Parking': doc['Auto Parking'] ?? 'N/A',
        'Auto Start/Stop':
            _formatField(doc.get(FieldPath(['Auto Start/Stop']))),
        'Auto Wipers': doc['Auto Wipers'] ?? 'N/A',
        'Blind Spot Info System': doc['Blind Spot Info System'] ?? 'N/A',
        'Boot Space': doc['Boot Space'] ?? 'N/A',
        'Capacity': doc['Capacity'] ?? 'N/A',
        'Co2': doc['Co2'] ?? 'N/A',
        'Collision Warning': doc['Collision Warning'] ?? 'N/A',
        'Cruise Control': doc['Cruise Control'] ?? 'N/A',
        'Cupholders': doc['Cupholders'] ?? 'N/A',
        'Doors': doc['Doors'] ?? 'N/A',
        'Driveline': doc['Driveline'] ?? 'N/A',
        'Engine Start': doc['Engine Start'] ?? 'N/A',
        'Factory Tyres': doc['Factory Tyres'] ?? 'N/A',
        'Engine Tech': doc['Engine Tech'] ?? 'N/A',
        'Folding Wing Mirrors': doc['Folding Wing Mirrors'] ?? 'N/A',
        'Front Brakes': doc['Front Brakes'] ?? 'N/A',
        'Front Suspension': doc['Front Suspension'] ?? 'N/A',
        'Front Wheels': doc['Front Wheels'] ?? 'N/A',
        'Fuel': doc['Fuel'] ?? 'N/A',
        'Fuel Tank': doc['Fuel Tank'] ?? 'N/A',
        'Height': doc['Height'] ?? 'N/A',
        'Hill Start Assist': doc['Hill Start Assist'] ?? 'N/A',
        'Horsepower': doc['Horsepower'] ?? 'N/A',
        'Lane-keeping Assist': doc['Lane-keeping Assist'] ?? 'N/A',
        'Length': doc['Length'] ?? 'N/A',
        'Manufacturer': doc['Manufacturer'] ?? 'N/A',
        'Paddle Shift': doc['Paddle Shift'] ?? 'N/A',
        'Parking Brake': doc['Parking Brake'] ?? 'N/A',
        'Parking Sensor Front': doc['Parking Sensor Front'] ?? 'N/A',
        'Parking Sensor Rear': doc['Parking Sensor Rear'] ?? 'N/A',
        'Power Sockets': doc['Power Sockets'] ?? 'N/A',
        'Power Windows': doc['Power Windows'] ?? 'N/A',
        'Rated Economy': doc['Rated Economy'] ?? 'N/A',
        'Rear Brakes': doc['Rear Brakes'] ?? 'N/A',
        'Rear Suspension': doc['Rear Suspension'] ?? 'N/A',
        'Rear Wheels': doc['Rear Wheels'] ?? 'N/A',
        'Reverse Camera': doc['Reverse Camera'] ?? 'N/A',
        'Seat Belts': doc['Seat Belts'] ?? 'N/A',
        'Seatbelt Reminder': doc['Seatbelt Reminder'] ?? 'N/A',
        'Seats': doc['Seats'] ?? 'N/A',
        'Spare Tyre': doc['Spare Tyre'] ?? 'N/A',
        'Steering': doc['Steering'] ?? 'N/A',
        'Sunroof': doc['Sunroof'] ?? 'N/A',
        'Torque': doc['Torque'] ?? 'N/A',
        'Transmission Name': doc['Transmission Name'] ?? 'N/A',
        'Type': doc['Type'] ?? 'N/A',
        'Tyre Front': doc['Tyre Front'] ?? 'N/A',
        'Tyre Rear': doc['Tyre Rear'] ?? 'N/A',
        'Warranty Manufacturer': doc['Warranty Manufacturer'] ?? 'N/A',
        'Weight': doc['Weight'] ?? 'N/A',
        'Wheelbase': doc['Wheelbase'] ?? 'N/A',
        'Width': doc['Width'] ?? 'N/A',
        // Add other fields as needed
      };
    } else {
      carInfo['Error'] = 'No information found for this variant';
    }
  } catch (e) {
    carInfo['Error'] = 'Failed to retrieve data: $e';
  }
  return carInfo;
}

// Helper function for formatting field values
String _formatField(dynamic fieldValue) {
  return (fieldValue == null || fieldValue.toString().trim().isEmpty)
      ? '-'
      : fieldValue.toString();
}

// Function to replace underscores with spaces in car names
String _formatCarName(String carName) {
  return carName.replaceAll('_', ' ');
}
