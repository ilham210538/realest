// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realest/car_info.dart';
import 'package:realest/main.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ImageDisplay extends StatefulWidget {
  final String source;
  ImageDisplay({required this.source});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  File? _image;
  String _result = "No Prediction Yet";
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> _pickImage() async {
    final pickedFile = widget.source == 'gallery'
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Processing...";
      });

      String prediction = await _predictImage(_image!);
      if (mounted) {
        setState(() {
          _result = prediction;
        });
      }
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<String> _predictImage(File image) async {
    if (_isDisposed) return "Widget disposed, operation canceled";
    String result = "Failed to load model";
    try {
      _interpreter = await Interpreter.fromAsset('assets/ModelC.tflite');
      _labels = await _loadLabels();

      img.Image? inputImage = img.decodeImage(image.readAsBytesSync());
      if (inputImage == null) return "Image decoding failed";

      // Resize while maintaining aspect ratio
      img.Image resizedImage = _resizeWithAspectRatio(inputImage, 224);

      // Add black padding to make it 224x224
      img.Image paddedImage = _padToSquare(resizedImage, 224);

      // Convert image to normalized Float32List
      Float32List input = _imageToFloat32List(paddedImage);

      // Reshape to match model input [1, 224, 224, 3]
      var reshapedInput = input.reshape([1, 224, 224, 3]);

      var output = List.generate(1, (index) => List.filled(242, 0.0));

      // Simulate the delay before prediction
      await Future.delayed(Duration(seconds: 2));

      _interpreter.run(reshapedInput, output);

      double highestProbability = -1;
      int topClassIndex = -1;
      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > highestProbability) {
          highestProbability = output[0][i];
          topClassIndex = i;
        }
      }

      result = _labels[topClassIndex];
      _interpreter.close();
    } catch (e) {
      if (_isDisposed) return "Widget disposed, operation canceled";
      result = "Error during prediction: $e";
    }
    return result;
  }

  img.Image _resizeWithAspectRatio(img.Image image, int targetSize) {
    int originalWidth = image.width;
    int originalHeight = image.height;
    double aspectRatio = originalWidth / originalHeight;

    int newWidth, newHeight;
    if (aspectRatio > 1) {
      newWidth = targetSize;
      newHeight = (targetSize / aspectRatio).round();
    } else {
      newHeight = targetSize;
      newWidth = (targetSize * aspectRatio).round();
    }

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  img.Image _padToSquare(img.Image image, int targetSize) {
    // Create a new blank image with the target dimensions
    img.Image paddedImage = img.Image(width: targetSize, height: targetSize);
    img.fill(paddedImage,
        color: img.ColorFloat16.rgba(0, 0, 0, 0)); // Black background

    int paddingX = (targetSize - image.width) ~/ 2;
    int paddingY = (targetSize - image.height) ~/ 2;

    // Manually copy each pixel from image to paddedImage
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        paddedImage.setPixel(paddingX + x, paddingY + y, pixel);
      }
    }

    return paddedImage;
  }

  Float32List _imageToFloat32List(img.Image image) {
    List<double> inputList = [];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        inputList.add((pixel.r - 123.68) /
            255.0); // Subtract RGB means from ImageNet data
        inputList.add((pixel.g - 116.78) / 255.0);
        inputList.add((pixel.b - 103.94) / 255.0);
      }
    }
    return Float32List.fromList(inputList);
  }

  Future<List<String>> _loadLabels() async {
    String labelsFile = await rootBundle.loadString('assets/VGG16NameList.txt');
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Check if an image is selected and a prediction is done
            if (_image == null || _result == null || _result.isEmpty) {
              // No image selected or no prediction, navigate to the MainPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainPage(), // Navigate to MainPage if no image or prediction
                ),
              );
            } else {
              // If image is selected and prediction is done, go back to gallery
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDisplay(source: 'gallery'),
                ),
              );
            }
          },
        ),
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
              child: _image != null
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 128, 0, 32),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.file(
                          _image!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No Image Selected',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 128, 0, 32),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            _result != null && _result.isNotEmpty
                ? Text(
                    _result.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 128, 0, 32),
                    ),
                    textAlign: TextAlign.center,
                  )
                : Center(
                    child: Text(
                      'No Prediction Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 128, 0, 32),
                      ),
                    ),
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
                    : Colors.grey,
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
                        : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'More Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _result != "Processing..." && _image != null
                          ? Color.fromARGB(255, 245, 245, 220)
                          : Colors.white,
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
