import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realest/loanCalculator.dart';
import 'dart:math';

import 'package:realest/profileHistory.dart'; // For randomization

class CarSearchPage extends StatefulWidget {
  @override
  _CarSearchPageState createState() => _CarSearchPageState();
}

class _CarSearchPageState extends State<CarSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _carNames = []; // To hold the car names
  String searchQuery = '';
  List<String> searchResults = [];
  bool isSearching = false; // Track whether a search is in progress
  bool isFocused = false; // Track if the search bar is focused
  bool isLoading = false; // Track if data is loading

  // Function to fetch random car names when the page is opened
  Future<void> _fetchRandomCarNames() async {
    setState(() {
      isLoading = true; // Start loading when fetching data
    });
    await Firebase.initializeApp();
    CollectionReference cars =
        FirebaseFirestore.instance.collection('car_info');

    // Get all car names (document IDs)
    QuerySnapshot snapshot = await cars.get();
    List<String> carNameList = snapshot.docs.map((doc) => doc.id).toList();

    // Shuffle the list for randomness
    carNameList.shuffle(Random());

    setState(() {
      _carNames =
          carNameList.take(20).toList(); // Take top 20 shuffled car names
      isLoading = false; // End loading after data is fetched
    });
  }

  // Function to perform search and get suggestions based on query
  Future<void> _performSearch() async {
    setState(() {
      searchQuery = _searchController.text.trim();
      isSearching = true; // Set the searching flag to true
      isLoading = true; // Show loading indicator during search
    });

    if (searchQuery.isNotEmpty) {
      CollectionReference cars =
          FirebaseFirestore.instance.collection('car_info');

      // Fetch all cars that match the search query in the document ID
      QuerySnapshot snapshot = await cars.get();
      List<String> searchResultsList = snapshot.docs
          .where((doc) => doc.id
              .toLowerCase()
              .replaceAll('_', ' ')
              .contains(searchQuery.toLowerCase()))
          .map((doc) => doc.id)
          .toList();

      setState(() {
        searchResults = searchResultsList;
        isLoading = false; // End loading after search results are fetched
      });
    } else {
      setState(() {
        searchResults = [];
        isLoading = false; // End loading if query is empty
      });
    }
  }

  // Function to fetch car information based on the variant ID (document ID)
  Future<Map<String, String>> _getCarInfo(String carId) async {
    await Firebase.initializeApp();
    Map<String, String> carInfo = {};
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

  @override
  void initState() {
    super.initState();
    _fetchRandomCarNames(); // Fetch random car names when the page loads
  }

  // Function to replace underscores with spaces in car names
  String _formatCarName(String carName) {
    return carName.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FindMyCar',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 245, 245, 220),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'e.g. Honda City',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 128, 0, 32),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 128, 0, 32), width: 1),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchResults = [];
                          isSearching = false;
                          _fetchRandomCarNames();
                        });
                      },
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  ),
                  onChanged: (query) {
                    _performSearch();
                  },
                ),
                SizedBox(height: 20.0),

                // Label to show based on search state
                Text(
                  isSearching ? "Results:" : "Recommended:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.0),

                // // Show loading indicator if data is still loading
                // if (isLoading)
                //   Center(
                //     child: LinearProgressIndicator(
                //       color: Color.fromARGB(255, 128, 0, 32),
                //     ),
                //   )
                // else
                // Show random cars until search is performed
                Flexible(
                  child: ListView.builder(
                    itemCount:
                        isSearching ? searchResults.length : _carNames.length,
                    itemBuilder: (context, index) {
                      final carName =
                          isSearching ? searchResults[index] : _carNames[index];
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0.0),
                            margin: EdgeInsets.symmetric(vertical: 0),
                            child: ListTile(
                              title: Text(
                                _formatCarName(carName),
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                              onTap: () async {
                                await addHistoryEntry(
                                    'Searched Car', _formatCarName(carName));
                                final carInfo = await _getCarInfo(carName);

                                showDialog(
                                  context: context,
                                  builder: (context) => CarInfoDialog(
                                    carName: carName,
                                    carInfo: carInfo,
                                  ),
                                );
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.grey.withOpacity(0.5),
                            thickness: 3,
                            indent: 15,
                            endIndent: 15,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: Color.fromARGB(255, 128, 0, 32),
                minHeight: 3.5,
              ),
            ),
        ],
      ),
    );
  }
}

class CarInfoDialog extends StatelessWidget {
  final String carName;
  final Map<String, String> carInfo;

  CarInfoDialog({required this.carName, required this.carInfo});

  @override
  Widget build(BuildContext context) {
    // Group the fields
    final Map<String, Map<String, String>> groupedFields = {
      'Naming': {
        'Make': carInfo['Make']!,
        'Model': carInfo['Model']!,
        'Generation': carInfo['Generation']!,
        'Manufacturer': carInfo['Manufacturer']!,
      },
      'Price and Costs': {
        'Peninsular Price': carInfo['Peninsular Price']!,
        'Insurance': carInfo['Insurance']!,
        'Roadtax': carInfo['Roadtax']!,
      },
      'Performance': {
        '0-100 km/h': carInfo['0-100 km/h']!,
        'Horsepower': carInfo['Horsepower']!,
        'Torque': carInfo['Torque']!,
        'Rated Economy': carInfo['Rated Economy']!,
        'Engine Tech': carInfo['Engine Tech']!,
      },
      'Dimensions': {
        'Height': carInfo['Height']!,
        'Length': carInfo['Length']!,
        'Width': carInfo['Width']!,
        'Weight': carInfo['Weight']!,
        'Wheelbase': carInfo['Wheelbase']!,
        'Boot Space': carInfo['Boot Space']!,
        'Fuel Tank': carInfo['Fuel Tank']!,
      },
      'Safety and Assistance': {
        'Airbags': carInfo['Airbags']!,
        'Collision Warning': carInfo['Collision Warning']!,
        'Lane-keeping Assist': carInfo['Lane-keeping Assist']!,
        'Parking Sensor Front': carInfo['Parking Sensor Front']!,
        'Parking Sensor Rear': carInfo['Parking Sensor Rear']!,
        'Reverse Camera': carInfo['Reverse Camera']!,
      },
      'Interior Features': {
        'Seats': carInfo['Seats']!,
        'Steering': carInfo['Steering']!,
        'Audio': carInfo['Audio']!,
        'Power Windows': carInfo['Power Windows']!,
        'Power Sockets': carInfo['Power Sockets']!,
        'Cupholders': carInfo['Cupholders']!,
        'Sunroof': carInfo['Sunroof']!,
      },
      'Wheels and Brakes': {
        'Factory Tyres': carInfo['Factory Tyres']!,
        'Tyre Front': carInfo['Tyre Front']!,
        'Tyre Rear': carInfo['Tyre Rear']!,
        'Front Brakes': carInfo['Front Brakes']!,
        'Rear Brakes': carInfo['Rear Brakes']!,
        'Driveline': carInfo['Driveline']!,
      },
      'Other Features': {
        'Arrangement': carInfo['Arrangement']!,
        'Assembly': carInfo['Assembly']!,
        'Auto Headlamps': carInfo['Auto Headlamps']!,
        'Auto Parking': carInfo['Auto Parking']!,
        'Auto Start/Stop': carInfo['Auto Start/Stop']!,
        'Folding Wing Mirrors': carInfo['Folding Wing Mirrors']!,
        'Hill Start Assist': carInfo['Hill Start Assist']!,
        'Seatbelt Reminder': carInfo['Seatbelt Reminder']!,
      },
    };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 100, // 90% of screen width
        height:
            MediaQuery.of(context).size.height * 0.75, // 80% of screen height
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 25), // Space for the close button
                Center(
                  child: Text(
                    carName.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: groupedFields.entries.map((entry) {
                        return ExpansionTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          children: entry.value.entries.map((field) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.arrow_right,
                                      color: Colors.blue[900], size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: '${field.key}: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: field.value,
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 128, 0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      var carPriceValue = carInfo['Peninsular Price'] ?? '0.0';
                      var roadTaxValue = carInfo['Roadtax'] ?? '0.0';
                      var insuranceValue = carInfo['Insurance'] ?? '0.0';

                      // Debug: Print raw values before cleaning
                      print("Raw Car Price Value: $carPriceValue");
                      print("Raw Road Tax Value: $roadTaxValue");
                      print("Raw Insurance Value: $insuranceValue");

                      // Clean using regex: remove RM and any non-numeric characters except for decimals
                      String priceString = carPriceValue
                          .toString()
                          .replaceAll(RegExp(r'[^0-9.]'), '');
                      String roadTaxString = roadTaxValue
                          .toString()
                          .replaceAll(RegExp(r'[^0-9.]'), '');
                      String insuranceString = insuranceValue
                          .toString()
                          .replaceAll(RegExp(r'[^0-9.]'), '');

                      // Debug: Print cleaned strings
                      print("Cleaned Car Price String: $priceString");
                      print("Cleaned Road Tax String: $roadTaxString");
                      print("Cleaned Insurance String: $insuranceString");

                      // Try parsing the cleaned strings
                      double carPrice = double.tryParse(priceString) ?? 0.0;
                      double roadTax = double.tryParse(roadTaxString) ?? 0.0;
                      double insurance =
                          double.tryParse(insuranceString) ?? 0.0;

                      // Debug: Print final values
                      print("Final Car Price: $carPrice");
                      print("Final Road Tax: $roadTax");
                      print("Final Insurance: $insurance");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoanCalculatorPage(
                            carPrice: carPrice,
                            roadTax: roadTax,
                            insurance: insurance,
                            carName: carName,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Financing',
                      style: TextStyle(
                        fontSize: 18, // Corrected fontSize syntax
                        color: Colors.white,
                      ),
                    ))
              ],
            ),
            // Close button positioned at the top right
            Positioned(
              top: -15,
              right: -15,
              child: IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Color.fromARGB(255, 128, 0, 32)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
