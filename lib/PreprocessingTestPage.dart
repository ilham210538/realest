import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class PreprocessingTestPage extends StatefulWidget {
  final String source;
  PreprocessingTestPage({required this.source});

  @override
  _PreprocessingTestPageState createState() => _PreprocessingTestPageState();
}

class _PreprocessingTestPageState extends State<PreprocessingTestPage> {
  File? _image;
  Uint8List? _preprocessedImage; // Store the preprocessed image as a byte array
  final ImagePicker _picker = ImagePicker();
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    _loadLabels();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final pickedFile = widget.source == 'gallery'
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      img.Image? inputImage = img.decodeImage(_image!.readAsBytesSync());
      if (inputImage != null) {
        // Resize, pad, and convert image to Float32List
        img.Image resizedImage = _resizeWithAspectRatio(inputImage, 224);
        img.Image paddedImage = _padToSquare(resizedImage, 224);
        Uint8List preprocessed = Uint8List.fromList(img
            .encodeJpg(paddedImage)); // Encode the preprocessed image to JPEG

        setState(() {
          _preprocessedImage = preprocessed;
        });
      }
    }
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
    img.Image paddedImage = img.Image(width: targetSize, height: targetSize);
    img.fill(paddedImage, color: img.ColorFloat16.rgba(0, 0, 0, 0));

    int paddingX = (targetSize - image.width) ~/ 2;
    int paddingY = (targetSize - image.height) ~/ 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        paddedImage.setPixel(paddingX + x, paddingY + y, pixel);
      }
    }

    return paddedImage;
  }

  Future<void> _loadLabels() async {
    try {
      String labelsFile = await rootBundle.loadString('assets/FinalList.txt');
      setState(() {
        _labels = labelsFile.split('\n');
      });
      print("Labels loaded successfully");
    } catch (e) {
      print("Failed to load labels: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preprocessing Test"),
      ),
      body: Center(
        child: _image == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Original Image"),
                  _image != null
                      ? Image.file(
                          _image!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                  SizedBox(height: 20),
                  Text("Preprocessed Image"),
                  _preprocessedImage != null
                      ? Image.memory(
                          _preprocessedImage!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
