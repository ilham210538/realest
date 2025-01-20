import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realest/loanCalculator.dart';

class VariantDetailPage extends StatelessWidget {
  final String variantId;
  VariantDetailPage({required this.variantId});

  // Fetch detailed car information for a specific variant
  Future<Map<String, Map<String, String>>> _getVariantDetails(
      String variantId) async {
    await Firebase.initializeApp(); // Reinitialize just in case

    CollectionReference cars =
        FirebaseFirestore.instance.collection('car_info');
    Map<String, Map<String, String>> groupedCarInfo = {};

    try {
      DocumentSnapshot doc = await cars.doc(variantId).get();
      if (doc.exists) {
        Map<String, dynamic> carInfo = doc.data() as Map<String, dynamic>;

        // Group the fields into categories
        groupedCarInfo = {
          'Naming': {
            'Make': carInfo['Make'] ?? '',
            'Model': carInfo['Model'] ?? '',
            'Generation': carInfo['Generation'] ?? '',
            'Manufacturer': carInfo['Manufacturer'] ?? '',
          },
          'Price and Costs': {
            'Peninsular Price': carInfo['Peninsular'] ?? '',
            'Insurance': carInfo['Insurance'] ?? '',
            'Roadtax': carInfo['Road Tax'] ?? '',
          },
          'Performance': {
            '0-100 km/h': carInfo['0-100 km/h'] ?? '',
            'Horsepower': carInfo['Horsepower'] ?? '',
            'Torque': carInfo['Torque'] ?? '',
            'Rated Economy': carInfo['Rated Economy'] ?? '',
            'Engine Tech': carInfo['Engine Tech'] ?? '',
          },
          'Dimensions': {
            'Height': carInfo['Height'] ?? '',
            'Length': carInfo['Length'] ?? '',
            'Width': carInfo['Width'] ?? '',
            'Weight': carInfo['Weight'] ?? '',
            'Wheelbase': carInfo['Wheelbase'] ?? '',
            'Boot Space': carInfo['Boot Space'] ?? '',
            'Fuel Tank': carInfo['Fuel Tank'] ?? '',
          },
          'Safety and Assistance': {
            'Airbags': carInfo['Airbags'] ?? '',
            'Collision Warning': carInfo['Collision Warning'] ?? '',
            'Lane-keeping Assist': carInfo['Lane-keeping Assist'] ?? '',
            'Parking Sensor Front': carInfo['Parking Sensor Front'] ?? '',
            'Parking Sensor Rear': carInfo['Parking Sensor Rear'] ?? '',
            'Reverse Camera': carInfo['Reverse Camera'] ?? '',
          },
          'Interior Features': {
            'Seats': carInfo['Seats'] ?? '',
            'Steering': carInfo['Steering'] ?? '',
            'Audio': carInfo['Audio'] ?? '',
            'Power Windows': carInfo['Power Windows'] ?? '',
            'Power Sockets': carInfo['Power Sockets'] ?? '',
            'Cupholders': carInfo['Cupholders'] ?? '',
            'Sunroof': carInfo['Sunroof'] ?? '',
          },
          'Wheels and Brakes': {
            'Factory Tyres': carInfo['Factory Tyres'] ?? '',
            'Tyre Front': carInfo['Tyre Front'] ?? '',
            'Tyre Rear': carInfo['Tyre Rear'] ?? '',
            'Front Brakes': carInfo['Front Brakes'] ?? '',
            'Rear Brakes': carInfo['Rear Brakes'] ?? '',
            'Driveline': carInfo['Driveline'] ?? '',
          },
          'Other Features': {
            'Arrangement': carInfo['Arrangement'] ?? '',
            'Assembly': carInfo['Assembly'] ?? '',
            'Auto Headlamps': carInfo['Auto Headlamps'] ?? '',
            'Auto Parking': carInfo['Auto Parking'] ?? '',
            'Auto Start/Stop': carInfo['Auto Start/Stop'] ?? '',
            'Folding Wing Mirrors': carInfo['Folding Wing Mirrors'] ?? '',
            'Hill Start Assist': carInfo['Hill Start Assist'] ?? '',
            'Seatbelt Reminder': carInfo['Seatbelt Reminder'] ?? '',
          },
        };
      } else {
        groupedCarInfo['Error'] = {'No information found for this variant': ''};
      }
    } catch (e) {
      groupedCarInfo['Error'] = {'Failed to retrieve data': e.toString()};
    }

    return groupedCarInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Variant Info',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 245, 245, 220),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
      ),
      body: FutureBuilder<Map<String, Map<String, String>>>(
        future: _getVariantDetails(variantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:
                        ListView(), // Empty list to ensure space is available
                  ),
                ),
                LinearProgressIndicator(
                  color: Color.fromARGB(255, 128, 0, 32),
                  minHeight: 3.5,
                ), // Progress bar at the bottom with no padding
              ],
            );
          } else if (snapshot.hasError || snapshot.data?['Error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error,
                      color: Color.fromARGB(255, 128, 0, 32), size: 40),
                  SizedBox(height: 10),
                  Text(
                    snapshot.data?['Error']?.keys.first ?? 'Error occurred',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          } else {
            final groupedCarInfo = snapshot.data ?? {};

            // Fetch values for the Loan Calculator
            final carPriceStr =
                groupedCarInfo['Price and Costs']?['Peninsular Price'] ?? '';
            final roadTaxStr =
                groupedCarInfo['Price and Costs']?['Roadtax'] ?? '';
            final insuranceStr =
                groupedCarInfo['Price and Costs']?['Insurance'] ?? '';

            final double carPrice = double.tryParse(
                    carPriceStr.replaceAll(',', '').replaceAll('RM', '')) ??
                0.0;
            final double roadTax = double.tryParse(
                    roadTaxStr.replaceAll(',', '').replaceAll('RM', '')) ??
                0.0;
            final double insurance = double.tryParse(
                    insuranceStr.replaceAll(',', '').replaceAll('RM', '')) ??
                0.0;

            // Icons for each category
            final categoryIcons = {
              'Naming': Icons.car_crash,
              'Price and Costs': Icons.monetization_on_rounded,
              'Performance': Icons.speed_sharp,
              'Dimensions': Icons.calculate_rounded,
              'Safety And Assistance': Icons.health_and_safety_sharp,
              'Interior Features': Icons.star,
              'Wheels and Brakes': Icons.info_rounded,
              'Other Features': Icons.insert_drive_file_rounded,
            };

            return Padding(
              padding: const EdgeInsets.all(12.0), // Reduced overall padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display car name with shadow for better visibility
                  Text(
                    variantId.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 26,
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

                  SizedBox(
                      height: 12), // Reduced space between title and content

                  // Display grouped car information with enhanced visual appeal
                  Expanded(
                    child: ListView(
                      children: [
                        for (var category in groupedCarInfo.entries)
                          if (category.key != 'Error')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.1),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ExpansionTile(
                                  leading: Icon(
                                    categoryIcons[category.key] ??
                                        Icons.health_and_safety_sharp,
                                    color: Color.fromARGB(255, 128, 0, 32),
                                    size: 26,
                                  ),
                                  title: Text(
                                    category.key,
                                    style: TextStyle(
                                      fontSize:
                                          18, // Slightly smaller font for longer names
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    softWrap:
                                        true, // Allows text to wrap to the next line
                                    overflow: TextOverflow
                                        .visible, // Ensures text is fully displayed
                                  ),
                                  children: [
                                    for (var entry in category.value.entries)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: ListTile(
                                          title: Text(
                                            entry.key.replaceAll('_', ' '),
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          subtitle: Text(
                                            entry.value,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 128, 0, 32),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),

                  // Button to navigate to the loan calculator with shadows
                  SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to the Loan Calculator Page with required values
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoanCalculatorPage(
                              carPrice: carPrice,
                              roadTax: roadTax,
                              insurance: insurance,
                              carName: variantId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 128, 0, 32),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Financing',
                        style: TextStyle(
                          fontSize: 22, // Slightly bigger font size
                          color: Color.fromARGB(255, 245, 245, 220),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
