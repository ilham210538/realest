// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_interpolation_to_compose_strings

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realest/VariantDetailPage.dart';
import 'package:realest/profileHistory.dart';

class CarInfoPage extends StatelessWidget {
  final String carModel;
  CarInfoPage({required this.carModel});

  // Fetch car variants from Firestore
  Future<List<Map<String, String>>> _getVariants(String model) async {
    await Firebase.initializeApp(); // Reinitialize just in case

    // Remove any trailing underscores from the model prediction
    String formattedModel = model.replaceAll(' ', '_').trim();
    CollectionReference cars =
        FirebaseFirestore.instance.collection('car_info');

    List<Map<String, String>> variants = [];

    try {
      QuerySnapshot querySnapshot = await cars
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: formattedModel)
          .where(FieldPath.documentId, isLessThan: '$formattedModel\uf8ff')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // Debugging print to check raw document data
          // print("Document ID: ${doc.id}");
          // print("Document Data: ${doc.data()}");

          variants.add({
            'Variant': doc.id.replaceFirst(formattedModel + '_', ''),
            'Make': doc['Make'] ?? 'N/A',
            'Model': doc['Model'] ?? 'N/A',
            'Generation': doc['Generation'] ?? 'N/A',
            'Peninsular Price': doc['Peninsular'] ?? 'N/A',
            'Insurance': doc['Insurance'] ?? 'N/A',
            'Roadtax': doc['Road Tax'] ?? 'N/A',
            'DocumentID': doc.id,
          });
        }
      } else {
        variants.add({'Error': 'No variants found for $formattedModel'});
      }
    } catch (e) {
      variants.add({'Error': 'Failed to retrieve data: $e'});
    }

    return variants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Car Variants',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 245, 245, 220),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 128, 0, 32),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _getVariants(carModel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Expanded(
                  child: ListView(), // Empty list to ensure space is available
                ),
                LinearProgressIndicator(
                  color: Color.fromARGB(255, 128, 0, 32),
                  minHeight: 3.5,
                ), // Remove the Padding to make it stick to the bottom
              ],
            );
          } else if (snapshot.hasError || snapshot.data?[0]['Error'] != null) {
            return Center(
              child: Text(
                snapshot.data?[0]['Error'] ?? 'Error occurred',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else {
            final variants = snapshot.data ?? [];
            // Group by Make, Model, Generation
            final groupedVariants = <String, List<Map<String, String>>>{};
            for (var variant in variants) {
              String groupKey =
                  "${variant['Make']} ${variant['Model']} ${variant['Generation']}";
              groupedVariants.putIfAbsent(groupKey, () => []);
              groupedVariants[groupKey]!.add(variant);
            }

            return ListView(
              padding: EdgeInsets.all(12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Please select a Variant to view",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Render grouped car variants
                ...groupedVariants.entries.map((entry) {
                  String groupKey = entry.key;
                  List<Map<String, String>> groupVariants = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading for Make, Model, Generation
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Text(
                                groupKey,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 128, 0, 32),
                                ),
                              ),
                            ),
                            // Variants heading with slight padding
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Variants:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Dropdown with Variants
                            Column(
                              children: groupVariants.map((variant) {
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0.01),
                                      title: Text(
                                        variant['Variant']
                                                ?.replaceAll('_', ' ') ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons
                                            .keyboard_double_arrow_right_rounded,
                                        color: Color.fromARGB(255, 128, 0, 32),
                                        size: 25,
                                      ),
                                      onTap: () async {
                                        String predictedCar =
                                            "${variant['Make']} ${variant['Model']} ${variant['Generation']}";
                                        String variantName = variant['Variant']
                                                ?.replaceAll('_', ' ') ??
                                            'Unknown Variant';

                                        String fullCarName =
                                            '$predictedCar $variantName';

                                        await addHistoryEntry(
                                            'Prediction Variant', fullCarName);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VariantDetailPage(
                                              variantId: variant['DocumentID']!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Divider(),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // Make sure there's no bottom padding on the last item so the progress bar sticks to the bottom
                if (snapshot.connectionState == ConnectionState.waiting)
                  LinearProgressIndicator(), // Show progress bar at the very bottom
              ],
            );
          }
        },
      ),
    );
  }
}
