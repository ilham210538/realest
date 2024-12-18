import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PreprocessingScreen extends StatefulWidget {
  final String source;
  PreprocessingScreen({required this.source});
  @override
  _PreprocessingScreenState createState() => _PreprocessingScreenState();
}

class _PreprocessingScreenState extends State<PreprocessingScreen> {
  File? _image;
  img.Image? _originalImage;
  img.Image? _preprocessedImage;
  late Interpreter _interpreter;
  late List<String> _labels;
  final ImagePicker _picker = ImagePicker();

  // Flask server URL
  final String flaskServerUrl = 'http://192.168.100.185:5000/remove-bg';

  // Send image to Flask server for background removal
  Future<File?> _removeBackground(File image) async {
    try {
      // Prepare the request
      var request = http.MultipartRequest('POST', Uri.parse(flaskServerUrl));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      // Send request
      var response = await request.send();
      if (response.statusCode == 200) {
        // Get the processed image bytes
        var imageBytes = await response.stream.toBytes();

        // Save the processed image locally
        String tempPath = '${Directory.systemTemp.path}/bg_removed.png';
        File processedImage = File(tempPath)..writeAsBytesSync(imageBytes);

        return processedImage;
      } else {
        print(
            'Failed to remove background. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during background removal: $e');
      return null;
    }
  }

  // Pick image from gallery and remove background
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File selectedImage = File(pickedFile.path);

      // Step 1: Remove background
      File? bgRemovedImage = await _removeBackground(selectedImage);
      if (bgRemovedImage == null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text("Failed to remove background. Try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      // Step 2: Continue preprocessing
      setState(() {
        _image = bgRemovedImage;
        _originalImage = img.decodeImage(bgRemovedImage.readAsBytesSync());
        _preprocessedImage = _applyPreprocessing(_originalImage!);
      });
    }
  }

  // Preprocess the image (resize, padding, and normalization)
  img.Image _applyPreprocessing(img.Image image) {
    int originalWidth = image.width;
    int originalHeight = image.height;

    // Calculate aspect ratio
    double aspectRatio = originalWidth / originalHeight;
    int targetWidth = 224;
    int targetHeight = 224;

    // Calculate new dimensions while maintaining the aspect ratio
    int newWidth = targetWidth;
    int newHeight = (newWidth / aspectRatio).round();

    if (newHeight > targetHeight) {
      newHeight = targetHeight;
      newWidth = (newHeight * aspectRatio).round();
    }

    // Resize the image to the calculated dimensions
    img.Image resizedImage =
        img.copyResize(image, width: newWidth, height: newHeight);

    // Create a new blank image with a black background (RGBA format)
    img.Image paddedImage = img.Image(width: 224, height: 224);
    img.fill(paddedImage,
        color: img.ColorFloat16.rgba(0, 0, 0, 0)); // Fill with black

    // Calculate offsets to center the resized image
    int offsetX = (targetWidth - newWidth) ~/ 2;
    int offsetY = (targetHeight - newHeight) ~/ 2;

    // Draw the resized image onto the padded image
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        // Extract the color from the PixelUint8 object
        img.Pixel pixel = resizedImage.getPixel(x, y);

        // Copy the pixel into the padded image
        paddedImage.setPixel(offsetX + x, offsetY + y, pixel);
      }
    }

    return paddedImage;
  }

  Float32List _imageToFloat32List(img.Image image) {
    List<int> pixels = image.getBytes();
    List<double> inputList = [];
    for (int i = 0; i < pixels.length; i++) {
      inputList.add(pixels[i] / 255.0);
    }
    return Float32List.fromList(inputList);
  }

  Future<String> _predictImage(File image) async {
    String result = "Failed to load model";
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/car_classifier_model.tflite');
      _labels = await _loadLabels();

      img.Image? inputImage = img.decodeImage(image.readAsBytesSync());
      if (inputImage == null) {
        return "Image decoding failed";
      }
      inputImage = _applyPreprocessing(inputImage);

      Float32List input = _imageToFloat32List(inputImage);

      // Update the output shape to match the model
      var output = List.filled(24 * 236, 0.0).reshape([24, 236]);

      _interpreter.run(input, output);

      // Process the output probabilities
      List<double> probabilities = output[0]; // Taking the first batch output
      int topIndex = probabilities.indexWhere(
          (p) => p == probabilities.reduce((a, b) => a > b ? a : b));

      result = _labels[topIndex];

      _interpreter.close();
    } catch (e) {
      result = "Error during prediction: $e";
    }
    return result;
  }

  Future<List<String>> _loadLabels() async {
    String labelsFile =
        await DefaultAssetBundle.of(context).loadString('assets/listNEW.txt');
    return labelsFile.split('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Preprocessing")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Image from Gallery"),
              ),
              if (_originalImage != null)
                Column(
                  children: [
                    Text("Original Image (Before Processing)"),
                    Image.memory(
                        Uint8List.fromList(img.encodePng(_originalImage!))),
                  ],
                ),
              if (_preprocessedImage != null)
                Column(
                  children: [
                    Text("Fully Preprocessed Image"),
                    Image.memory(
                        Uint8List.fromList(img.encodePng(_preprocessedImage!))),
                    FutureBuilder<String>(
                      future: _predictImage(File(_image!.path)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          return Text("Prediction: ${snapshot.data}");
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
