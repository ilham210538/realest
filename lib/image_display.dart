// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realest/car_info.dart';
// import 'package:realest/profileHistory.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data'; // Import this to use Float32List
import 'package:flutter/services.dart'; // Import to use rootBundle
import 'package:http/http.dart' as http;

class ImageDisplay extends StatefulWidget {
  final String source; // Either 'camera' or 'gallery'
  ImageDisplay({required this.source});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  File? _image;
  String _result = "No prediction yet";
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  late List<String> _labels;

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = widget.source == 'gallery'
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _image = File(pickedFile.path);
          _result = "Processing...";
        });
      }

      // // Remove background
      // File? backgroundRemovedFile = await _removeBackground(_image!);
      // if (backgroundRemovedFile != null && mounted) {
      //   setState(() {
      //     _image = backgroundRemovedFile;
      //   });
      // }

      String prediction = await _predictImage(_image!);
      if (mounted) {
        setState(() {
          _result = prediction;
        });

        // // Add history entry using your existing method
        // await addHistoryEntry('Predicted Car', prediction);
      }
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // final String flaskServerUrl = 'http://172.20.10.4:5000/remove-bg';

  // final String flaskServerUrl = 'http://10.0.2.2:5000/remove-bg';

  // final String flaskServerUrl = 'http://192.168.100.185:5000/remove-bg';

  // // Function to remove background using Rembg API
  // Future<File?> _removeBackground(File image) async {
  //   if (_isDisposed) return null; // Stop processing if disposed
  //   try {
  //     // Open the image file and send it to the server
  //     List<int> imageBytes = image.readAsBytesSync();
  //     print(
  //         'Image bytes length: ${imageBytes.length}'); // Log to check image size

  //     var request = http.MultipartRequest('POST', Uri.parse(flaskServerUrl));
  //     request.files.add(http.MultipartFile.fromBytes('file', imageBytes,
  //         filename: 'image.png'));

  //     // Set headers if needed (e.g., content type)
  //     request.headers.addAll({
  //       'Content-Type': 'multipart/form-data',
  //     });

  //     var response = await request.send();

  //     if (response.statusCode == 200) {
  //       // Get the response image and save it to a file
  //       var responseData = await http.Response.fromStream(response);
  //       final directory = await Directory.systemTemp.createTemp();
  //       final outputFile = File('${directory.path}/image_no_bg.png');
  //       await outputFile.writeAsBytes(responseData.bodyBytes);
  //       return outputFile;
  //     } else {
  //       print(
  //           'Background removal failed with status code: ${response.statusCode}');
  //       return null; // Return null if background removal fails
  //     }
  //   } catch (e) {
  //     if (_isDisposed) return null;
  //     print("Error removing background: $e");
  //     return null;
  //   }
  // }

  // Load TFLite model and make prediction
  Future<String> _predictImage(File image) async {
    if (_isDisposed) return "Widget disposed, operation canceled";
    String result = "Failed to load model";
    try {
      // Load the TFLite model
      _interpreter =
          await Interpreter.fromAsset('assets/car_classifier_model2.tflite');
      _labels = await _loadLabels();

      // Decode the image and resize it
      img.Image? inputImage = img.decodeImage(image.readAsBytesSync());
      if (inputImage == null) {
        return "Image decoding failed";
      }
      inputImage = img.copyResize(inputImage, width: 224, height: 224);

      // Create a new blank image with the target dimensions
      img.Image paddedImage = img.Image(width: 224, height: 224);
      img.fill(paddedImage,
          color: img.ColorFloat16.rgba(0, 0, 0, 0)); // Black background

      int targetWidth = 224;
      int targetHeight = 224;

      // Manually copy each pixel from inputImage to paddedImage
      for (int y = 0; y < inputImage.height; y++) {
        for (int x = 0; x < inputImage.width; x++) {
          img.Pixel pixel = inputImage.getPixel(x, y);
          paddedImage.setPixel((targetWidth - 224) ~/ 2 + x,
              (targetHeight - 224) ~/ 2 + y, pixel);
        }
      }

      // Convert image to a format acceptable by the model (normalized Float32List)
      List<int> pixels = paddedImage.getBytes();
      List<double> inputList = [];
      for (int i = 0; i < pixels.length; i++) {
        inputList.add(pixels[i] / 255.0); // Normalize pixel value to [0, 1]
      }

      // Convert the list into a Float32List and reshape if needed
      Float32List input = Float32List.fromList(inputList);

      // Prepare the output array with the correct shape (24, 236)
      var output = List.generate(24, (index) => List.filled(217, 0.0));

      // Run the model inference
      _interpreter.run(input, output);

      // Extract the top prediction (find the max value in the output for each entry in the first dimension)
      double highestProbability = -1;
      int topClassIndex = -1;

      // We are looking for the highest probability in the second dimension (236 classes)
      for (var i = 0; i < output.length; i++) {
        for (var j = 0; j < output[i].length; j++) {
          if (output[i][j] > highestProbability) {
            highestProbability = output[i][j];
            topClassIndex =
                j; // Store the index of the highest probability class
          }
        }
      }

      // Now `topClassIndex` will hold the index of the class with the highest probability
      result = _labels[topClassIndex]; // Get the corresponding class label

      _interpreter.close(); // Close the interpreter after use
    } catch (e) {
      if (_isDisposed) return "Widget disposed, operation canceled";
      result = "Error during prediction: $e";
    }
    return result;
  }

  Future<List<String>> _loadLabels() async {
    String labelsFile = await rootBundle.loadString('assets/listNEW2.txt');
    return labelsFile.split('\n');
  }

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 220),
      appBar: AppBar(
        title: Text(
          'Prediction',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _image == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        _image!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              _result.replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 128, 0, 32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Add LinearProgressIndicator here if processing
            if (_result == "Processing...")
              LinearProgressIndicator(
                color: Color.fromARGB(255, 128, 0, 32),
                minHeight: 3.5,
              ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: (_result != "Processing..." && _image != null)
                  ? () {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CarInfoPage(carModel: _result),
                          ),
                        );
                      }
                    }
                  : null, // Disable button if processing or no image is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: _result != "Processing..." && _image != null
                    ? Color.fromARGB(255, 128, 0, 32)
                    : Colors.grey, // Disabled state color
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _result != "Processing..." && _image != null
                        ? Color.fromARGB(255, 245, 245, 220)
                        : Colors.white, // Adjust icon color for disabled state
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'More Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _result != "Processing..." && _image != null
                          ? Color.fromARGB(255, 245, 245, 220)
                          : Colors.white, // Text color for disabled state
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Space before the info text
            // Only show the info text if prediction is processing
            if (_result == "Processing...")
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timelapse_sharp,
                      color: Color.fromARGB(255, 128, 0, 32),
                      size: 30,
                    ),
                    Text(
                      " Prediction may take some time...",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 128, 0, 32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
