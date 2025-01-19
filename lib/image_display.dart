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

final ImagePicker _picker = ImagePicker();

class CustomCircularProgress extends StatefulWidget {
  final double progress; // The final progress value (0 to 1)

  const CustomCircularProgress({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  _CustomCircularProgressState createState() => _CustomCircularProgressState();
}

class _CustomCircularProgressState extends State<CustomCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initializeAnimation();
    _controller.forward();
  }

  void _initializeAnimation() {
    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(CustomCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _controller.reset();
      _initializeAnimation();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 60,
          height: 60,
          child: CustomPaint(
            painter: CircleProgressPainter(_progressAnimation.value),
            child: Center(
              child: Text(
                "${(_progressAnimation.value * 100).toInt()}%", // Calculate percentage from progress
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 8.0;

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );

    double arcAngle = 2 * 3.14 * progress;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      -3.14 / 2, // Start at the top
      arcAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ImageDisplay extends StatefulWidget {
  final File image;
  ImageDisplay({required this.image});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  late File _image; // Image file passed from Main
  String _result = "No Prediction Yet";
  Interpreter? _interpreter;
  late List<String> _labels;
  bool isLoading = false;
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _image = widget.image; // Initialize with the passed image
    // Optionally, scroll to the bottom initially
    setState(() {
      isLoading = true; // Show loading indicator immediately
    });

    // Add a slight delay before starting the image processing
    Future.delayed(Duration(seconds: 2), () async {
      if (!_isDisposed) {
        // Check if disposed before processing
        await _processImage(); // Process the image after the delay
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _onPredictionsLoaded() {
    // Call this method once predictions are set and screen content is ready to be scrolled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(); // Scroll to the bottom after the frame is drawn
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose(); // Don't forget to dispose the controller

    // _interpreter?.close(); // Safely close the model interpreter if it exists
    super.dispose();
  }

  // Modify the prediction logic to include probabilities
  Future<void> _processImage() async {
    if (_isDisposed) return; // Don't continue if the widget has been disposed

    setState(() {
      isLoading = true;
    });

    try {
      _interpreter ??= await Interpreter.fromAsset('assets/ModelA_GB.tflite');

      _labels = await _loadLabels();

      // Decode and preprocess the image
      img.Image? inputImage = img.decodeImage(_image.readAsBytesSync());
      if (inputImage == null) {
        throw Exception("Image decoding failed");
      }

      img.Image resizedImage = _resizeWithAspectRatio(inputImage, 224);
      img.Image paddedImage = _padToSquare(resizedImage, 224);

      Float32List input = _imageToFloat32List(paddedImage);
      var reshapedInput = input.reshape([1, 224, 224, 3]);

      var output = List.generate(1, (index) => List.filled(209, 0.0));

      // Run inference
      if (_interpreter != null) {
        _interpreter?.run(reshapedInput, output);
      }

      // Store top predictions and probabilities
      List<Map<String, dynamic>> topPredictions = [];
      for (int i = 0; i < output[0].length; i++) {
        topPredictions.add({
          'label': _labels[i],
          'probability': output[0][i],
        });
      }

      // Sort predictions by probability
      topPredictions
          .sort((a, b) => b['probability'].compareTo(a['probability']));

      // Limit to top 3 predictions
      topPredictions = topPredictions.take(3).toList();

      if (!_isDisposed && mounted) {
        setState(() {
          // Directly set the label if it's a string
          _result = topPredictions[0]
              ['label']; // Display the top prediction label directly
          _topPredictions = topPredictions; // Store top predictions for display
        });

        // Trigger the scroll to bottom once predictions are loaded
        _onPredictionsLoaded();
      }
    } catch (e) {
      if (_isDisposed) return;
      if (mounted) {
        setState(() {
          _result = "Error: $e";
        });
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _interpreter?.close(); // Close the interpreter safely
    }
  }

// Add a variable to store the top predictions
  List<Map<String, dynamic>> _topPredictions = [];

  Future<List<String>> _loadLabels() async {
    String labelsFile = await rootBundle.loadString('assets/GBFINAL.txt');
    return labelsFile.split('\n');
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
    img.fill(paddedImage,
        color: img.ColorFloat16.rgba(0, 0, 0, 0)); // Black background

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

  Float32List _imageToFloat32List(img.Image image) {
    List<double> inputList = [];
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        inputList.add((pixel.r - 123.68) / 255.0);
        inputList.add((pixel.g - 116.78) / 255.0);
        inputList.add((pixel.b - 103.94) / 255.0);
      }
    }
    return Float32List.fromList(inputList);
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
          icon: Icon(
            Icons.home,
            color: Color.fromARGB(255, 245, 245, 220),
            size: 30,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        // Wrap the body with SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image Display Section
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
                      constraints: BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 300,
                      ),
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

            // Prediction Result
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

            // Loading Indicator
            if (isLoading)
              LinearProgressIndicator(
                color: Color.fromARGB(255, 128, 0, 32),
                minHeight: 3.5,
              ),

            const SizedBox(height: 15),

            // More Info Button
            ElevatedButton(
              onPressed:
                  isLoading || _result == "Processing..." || _image == null
                      ? null
                      : () {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CarInfoPage(carModel: _result),
                              ),
                            );
                          }
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading ||
                        _result == "Processing..." ||
                        _image == null
                    ? Colors.grey // Dimmed color when loading or unavailable
                    : Color.fromARGB(255, 128, 0, 32),
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
                    color: isLoading ||
                            _result == "Processing..." ||
                            _image == null
                        ? Colors.white // Dimmed icon color
                        : Color.fromARGB(255, 245, 245, 220),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Car Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLoading ||
                              _result == "Processing..." ||
                              _image == null
                          ? Colors.white // Dimmed text color
                          : Color.fromARGB(255, 245, 245, 220),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: isLoading ||
                            _result == "Processing..." ||
                            _image == null
                        ? Colors.white // Dimmed icon color
                        : Color.fromARGB(255, 245, 245, 220),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Display Top 3 Predictions if available
            if (_topPredictions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Top 3 Probabilities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Display top 3 predictions
                      ..._topPredictions.take(3).map((prediction) {
                        // Convert probability to a percentage
                        final int probability =
                            (prediction['probability'] * 100).toInt();
                        final String label =
                            prediction['label'].replaceAll('_', ' ');

                        // Inside the widget that calls CustomCircularProgress
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CustomCircularProgress(
                                  progress: prediction[
                                      'probability'], // Only pass progress (fraction)
                                  // No need to pass percentage, it will be calculated in the widget
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  "$label",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 5),

            Text(
              "Select another image to predict?",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            // Two buttons (camera and gallery to re-predict)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 128, 0, 32),
                        padding: EdgeInsets.all(18),
                        shape: CircleBorder(),
                      ),
                      child: Icon(Icons.photo_camera,
                          color: Color.fromARGB(255, 245, 245, 220)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'From Camera',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                    width: 45), // Adjust the width to control spacing
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 128, 0, 32),
                        padding: EdgeInsets.all(18),
                        shape: CircleBorder(),
                      ),
                      child: Icon(Icons.image,
                          color: Color.fromARGB(255, 245, 245, 220)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'From Gallery',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
