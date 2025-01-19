import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoanCalculatorPage extends StatefulWidget {
  final double carPrice;
  final double roadTax;
  final double insurance;
  final String carName; // Added carName

  LoanCalculatorPage({
    required this.carPrice,
    required this.roadTax,
    required this.insurance,
    required this.carName, // Accept carName as a parameter
  });

  @override
  _LoanCalculatorPageState createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  late TextEditingController _carPriceController;
  late TextEditingController _roadTaxController;
  late TextEditingController _insuranceController;
  final _downPaymentController = TextEditingController();
  final _interestController = TextEditingController();
  final _termController = TextEditingController();
  final _serviceCostController = TextEditingController();
  final _wearAndTearController = TextEditingController();
  final currencyFormat = NumberFormat("#,##0.00", "en_US");
  bool _isLoanCalculated = false;
  bool _isUpfrontCalculated = false;
  bool _isSalaryCalculated = false;
  bool _showPopup = false;

  double _emi = 0.0;
  double _totalPayment = 0.0;
  double _upfrontCost = 0.0;
  double _yearlyExpense = 0.0;
  double _monthlyExpense = 0.0;
  double _downPayment = 0.0;
  double _incomeAllocationPercentage = 20.0; // Default to 20%
  double _salaryRequiredDynamic =
      0.0; // Holds the dynamically calculated salary
  double _percentage = 20.0;
  double _requiredSalary = 0.0;

  double _opacity1 = 0.0;
  double _opacity2 = 0.0;
  double _opacity3 = 0.0;
  double _opacity4 = 0.0;
  double _opacity5 = 0.0;
  double _opacity6 = 0.0;
  double _opacity7 = 0.0;

  @override
  void initState() {
    super.initState();
    _carPriceController =
        TextEditingController(text: widget.carPrice.toString());
    _roadTaxController = TextEditingController(text: widget.roadTax.toString());
    _insuranceController =
        TextEditingController(text: widget.insurance.toString());
    _downPaymentController.text = "10"; // Default Down Payment Percentage

    // Trigger opacity change with a delay for each segment
    _animateOpacity();
  }

// Function to reset and animate opacity for loan-related calculations
  void _resetAndAnimateOpacityForLoan() {
    setState(() {
      _opacity1 = 0.0;
      _opacity2 = 0.0;
      _opacity3 = 0.0;
    });

    // Restart the animation after a small delay
    Future.delayed(Duration(milliseconds: 10), () {
      // Ensure fade-out is complete before triggering value updates
      Future.delayed(Duration(milliseconds: 300), () {
        _calculateLoan();
        _animateOpacity();
      });
    });
  }

  // Function to reset and animate opacity for upfront payment section
  void _resetAndAnimateOpacityForUpfront() {
    setState(() {
      _opacity4 = 0.0;
    });

    // Restart the animation after a small delay
    Future.delayed(Duration(milliseconds: 10), () {
      // Ensure fade-out is complete before triggering value updates
      Future.delayed(Duration(milliseconds: 300), () {
        _calculateUpfrontPayment(); // Fix typo here
        _animateOpacity();
      });
    });
  }

// Function to reset and animate opacity for required salary
  void _resetAndAnimateOpacityForRequired() {
    setState(() {
      _opacity5 = 0.0;
      _opacity6 = 0.0;
      _opacity7 = 0.0;
    });

    // Restart the animation after a small delay
    Future.delayed(Duration(milliseconds: 10), () {
      // Ensure fade-out is complete before triggering value updates
      Future.delayed(Duration(milliseconds: 300), () {
        _calculateRequiredSalaryWithPercentage();
        _animateOpacity();
      });
    });
  }

  // Function to trigger the opacity changes with delay
  void _animateOpacity() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity1 = 1.0; // First segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 120), () {
      setState(() {
        _opacity2 = 1.0; // Second segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 140), () {
      setState(() {
        _opacity3 = 1.0; // Third segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity4 = 1.0; // First segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity5 = 1.0; // Second segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 120), () {
      setState(() {
        _opacity6 = 1.0; // Third segment appears
      });
    });

    Future.delayed(Duration(milliseconds: 140), () {
      setState(() {
        _opacity7 = 1.0; // Third segment appears
      });
    });
  }

  void _calculateLoan() {
    try {
      // Wait for 1 second before executing the calculation
      Future.delayed(Duration(milliseconds: 400), () {
        double carPrice = _parseDouble(
            _carPriceController.text); // Get car price from user input
        double downPaymentPercent = _parseDouble(_downPaymentController.text) /
            100; // Get down payment percentage
        double interestRate =
            _parseDouble(_interestController.text) / 100; // Get interest rate
        int loanTermYears = int.tryParse(_termController.text) ??
            9; // Default to 9 years if no input
        int loanTermMonths =
            loanTermYears * 12; // Convert loan term from years to months

        // Calculate down payment and loan amount
        double downPayment =
            carPrice * downPaymentPercent; // Calculate the down payment value
        double loanAmount =
            carPrice - downPayment; // Remaining loan amount after down payment

        // Store the down payment value to use in UI
        _downPayment = downPayment;

        // Total interest calculation (interest on the loan amount for the loan term)
        double totalInterest = loanAmount * interestRate * loanTermYears;

        // Total loan payment (loan amount + total interest)
        double totalPayment = loanAmount + totalInterest;

        // Monthly payment (EMI)
        double emi = totalPayment /
            loanTermMonths; // Divide the total payment by the number of months

        // Set state to update UI with calculated values
        setState(() {
          _isLoanCalculated = true;
          _emi = emi; // Monthly EMI
          _totalPayment = totalPayment; // Total payment for the loan
        });
      });
    } catch (e) {
      _showErrorDialog('Invalid input. Please enter valid numbers.');
    }
  }

  void _calculateUpfrontPayment() {
    // Wait for 1 second before executing the calculation
    Future.delayed(Duration(milliseconds: 400), () {
      double roadTax = _parseDouble(_roadTaxController.text);
      double insurance = _parseDouble(_insuranceController.text);
      _upfrontCost = _downPayment + roadTax + insurance;

      // Set state to update UI with the calculated value
      setState(() {
        _isUpfrontCalculated = true;
      });
    });
  }

  void _calculateRequiredSalaryWithPercentage() {
    try {
      double roadTax = _parseDouble(_roadTaxController.text);
      double insurance = _parseDouble(_insuranceController.text);
      double wearAndTear = _parseDouble(_wearAndTearController.text);
      double serviceCost = _parseDouble(_serviceCostController.text);

      // Calculate yearly expenses and convert to monthly
      double totalyearlyExpenses =
          (_emi * 12 + roadTax + insurance + wearAndTear + serviceCost);
      double totalmonthlyExpenses =
          (_emi * 12 + roadTax + insurance + wearAndTear + serviceCost) / 12;

      print("Yearly Expenses: $totalyearlyExpenses");
      print("Monthly Expenses: $totalmonthlyExpenses");

      // Calculate required salary based on the slider percentage
      double requiredSalary =
          totalmonthlyExpenses / (_incomeAllocationPercentage / 100);
      print("Required Salary: $requiredSalary");

      setState(() {
        _monthlyExpense = totalmonthlyExpenses;
        _requiredSalary = requiredSalary;
      });
    } catch (e) {
      _showErrorDialog('Invalid input. Please enter valid numbers.');
    }
  }

  double _parseDouble(String input) {
    if (input.isEmpty) {
      return 0.0; // Return 0.0 if input is empty
    }
    try {
      return double.parse(input);
    } catch (e) {
      return 0.0; // Return 0.0 if parsing fails
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDynamicSliderPopup() {
    double tempSliderValue =
        _incomeAllocationPercentage; // Initial slider value
    _requiredSalary = _monthlyExpense /
        (tempSliderValue / 100); // Initial calculation for salary

    // Debugging to check values before showing the dialog
    print("SLIDER Monthly Expense: $_monthlyExpense");
    print("SLIDER Required Salary: $_requiredSalary");

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setPopupState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: SingleChildScrollView(
                // Make the dialog scrollable
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  width: MediaQuery.of(context).size.width *
                      0.85, // Adjusted width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title Text (Slider Percentage)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Allocate ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600, // Slightly bold
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "${tempSliderValue.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 27, // Larger size for the number
                                fontWeight:
                                    FontWeight.bold, // Bold for the number
                                color: tempSliderValue >= 35
                                    ? Color.fromARGB(255, 128, 0,
                                        32) // Original color for 35-60%
                                    : Colors.green, // Green color for 1-34%
                              ),
                            ),
                            TextSpan(
                              text: "%",
                              style: TextStyle(
                                fontSize: 27, // Larger size for the percentage
                                fontWeight:
                                    FontWeight.bold, // Bold for the percentage
                                color: tempSliderValue >= 35
                                    ? Color.fromARGB(255, 128, 0,
                                        32) // Original color for 35-60%
                                    : Colors.green, // Green color for 1-34%
                              ),
                            ),
                            TextSpan(
                              text: " of your monthly salary",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600, // Slightly bold
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center, // Center the text
                      ),

                      SizedBox(height: 20),

                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Required Salary: ",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Black for the text
                              ),
                            ),
                            TextSpan(
                              text:
                                  "RM${currencyFormat.format(_requiredSalary)}",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: tempSliderValue >= 35
                                    ? Color.fromARGB(255, 128, 0,
                                        32) // Original color for 35-60%
                                    : Colors.green, // Green color for 1-34%
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center, // Centered text
                      ),
                      SizedBox(height: 20),

                      Text(
                        tempSliderValue >= 35
                            ? "It is not advisable to spend that chunk of your income for a car :)"
                            : "The monthly expenses total up to RM${_monthlyExpense.toStringAsFixed(2)} which includes:\n\n"
                                "1) Road Tax\n"
                                "2) Insurance\n"
                                "3) Loan Payment\n"
                                "4) Service Cost\n"
                                "5) Wear and Tear",
                        style: TextStyle(
                          fontSize: 16,
                          color: tempSliderValue >= 35
                              ? Colors.black54
                              : Colors
                                  .black54, // Red for warning, black for normal
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 30),

                      // Slider
                      Slider(
                        value: tempSliderValue,
                        min: 1,
                        max: 60,
                        divisions: 59,
                        activeColor: Color.fromARGB(255, 128, 0, 32),
                        label: "${tempSliderValue.toStringAsFixed(0)}%",
                        onChanged: (value) {
                          setPopupState(() {
                            tempSliderValue = value;
                            _requiredSalary = _monthlyExpense / (value / 100);
                          });
                        },
                      ),

                      SizedBox(height: 30),

                      // OK Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _incomeAllocationPercentage = tempSliderValue;
                            _requiredSalary = _requiredSalary;
                          });
                          Navigator.pop(context); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 128, 0, 32),
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financing',
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                widget.carName
                    .replaceAll('_', ' '), // Replace underscores with spaces
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
              SizedBox(height: 10),
              Divider(
                color: Colors.grey, // Color of the line
                thickness: 2, // Thickness of the line
                indent: 0, // Space before the line starts
                endIndent: 0, // Space after the line ends
              ),
              SizedBox(height: 5),

              // Loan Calculation Section
              _buildSectionTitle("Loan Calculation"),
              _buildInputField('Car Price', _carPriceController),
              _buildInputField('Down Payment (%)', _downPaymentController,
                  hint: 'e.g. 10'),
              _buildInputField('Loan Term (Years)', _termController,
                  hint: 'e.g. 9'),
              _buildInputField('Interest Rate (%)', _interestController,
                  hint: 'e.g. 2.5'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _resetAndAnimateOpacityForLoan(); // Reset and animate opacity
                  _calculateLoan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 128, 0, 32),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Color.fromARGB(255, 245, 245, 220),
                  minimumSize: Size(250, 45),
                ),
                child: Text('Calculate Loan'),
              ),
              SizedBox(height: 20),
              //TEXT FOR INFORMING
              _isLoanCalculated
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First row with downpayment and remaining price
                        AnimatedOpacity(
                          opacity: _opacity1,
                          duration: Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right,
                                  size: 18,
                                  color: Color.fromARGB(255, 128, 0, 32)),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "After a downpayment of ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                      TextSpan(
                                        text:
                                            "RM${currencyFormat.format(_downPayment)}, ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text:
                                            "the remaining price of the car is ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                      TextSpan(
                                        text:
                                            "RM${currencyFormat.format(_parseDouble(_carPriceController.text) - _downPayment)}.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        // Second row with monthly payment
                        AnimatedOpacity(
                          opacity: _opacity2,
                          duration: Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right,
                                  size: 18,
                                  color: Color.fromARGB(255, 128, 0, 32)),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "Your monthly payment will be approximately ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                      TextSpan(
                                        text:
                                            "RM${currencyFormat.format(_emi)} ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text:
                                            "based on the loan term and interest rate provided.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        // Third row with total payment
                        AnimatedOpacity(
                          opacity: _opacity3,
                          duration: Duration(milliseconds: 500),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right,
                                  size: 18,
                                  color: Color.fromARGB(255, 128, 0, 32)),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "In total, you will pay ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                      TextSpan(
                                        text:
                                            "RM${currencyFormat.format(_totalPayment)} ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: "over the course of the loan.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 128, 0, 32)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        "Enter the details according to your preference, then a loan amount will be calculated based on given information",
                        textAlign: TextAlign
                            .center, // Ensures text is centered within its container
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
              SizedBox(height: 15),
// Divider line
              Divider(
                color: Colors.grey, // Color of the line
                thickness: 2, // Thickness of the line
                indent: 0, // Space before the line starts
                endIndent: 0, // Space after the line ends
              ),
              SizedBox(height: 5),

              // Upfront Payment Section
              _buildSectionTitle("Upfront Payment"),
              _buildResultBox(
                  'Down Payment (RM)', _downPayment.toStringAsFixed(2),
                  isDownPayment: true, isEmpty: _downPayment == 0),

              _buildInputField('Road Tax', _roadTaxController),
              _buildInputField('Insurance', _insuranceController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _resetAndAnimateOpacityForUpfront(); // Reset and animate opacity
                  _calculateUpfrontPayment(); // Call the calculate loan function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 128, 0, 32),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Color.fromARGB(255, 245, 245, 220),
                  minimumSize: Size(250, 45),
                ),
                child: Text('Calculate Upfront Payment'),
              ),
              SizedBox(height: 20),
              // Upfront Payment Text Output
              _isUpfrontCalculated
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First row with total upfront cost
                        AnimatedOpacity(
                          opacity: _opacity4,
                          duration: Duration(seconds: 2),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right,
                                  size: 18,
                                  color: Color.fromARGB(255, 128, 0, 32)),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "Your total upfront cost will be approximately ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 128, 0,
                                              32), // Normal text color
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "RM${currencyFormat.format(_upfrontCost)} ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .black, // Bold black for the total cost
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "based on the down payment, road tax, and insurance.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 128, 0,
                                              32), // Normal text color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        "All details [DP, RT & I] have been extracted from database. If not, enter amounts manually",
                        textAlign: TextAlign
                            .center, // Ensures text is centered within its container
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),

              SizedBox(height: 15),
// Divider line
              Divider(
                color: Colors.grey, // Color of the line
                thickness: 2, // Thickness of the line
                indent: 0, // Space before the line starts
                endIndent: 0, // Space after the line ends
              ),
              SizedBox(height: 5),

              // Required Salary Section
              _buildSectionTitle("Required Salary"),
              _buildResultBox('Monthly Payment (RM)', _emi.toStringAsFixed(2),
                  isDownPayment: true, // Reuse logic for indicator
                  isEmpty: _emi == 0), // Check if empty
              _buildResultBox('Road Tax (RM)',
                  _parseDouble(_roadTaxController.text).toStringAsFixed(2),
                  isDownPayment: true,
                  isEmpty: _parseDouble(_roadTaxController.text) == 0),
              _buildResultBox('Insurance (RM)',
                  _parseDouble(_insuranceController.text).toStringAsFixed(2),
                  isDownPayment: true,
                  isEmpty: _parseDouble(_insuranceController.text) == 0),
              _buildInputField(
                  'Service Cost (Per Year)', _serviceCostController),
              _buildInputField(
                  'Wear and Tear (Per Year)', _wearAndTearController),
              SizedBox(height: 20),
              //
              SizedBox(height: 10),
              // Button to Calculate Required Salary
              ElevatedButton(
                onPressed: () {
                  _calculateRequiredSalaryWithPercentage(); // First calculate the required salary
                  _showDynamicSliderPopup(); // Then show the dynamic slider popup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 128, 0, 32),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Color.fromARGB(255, 245, 245, 220),
                  minimumSize: Size(250, 45),
                ),
                child: Text('Calculate Required Salary'),
              ),

              SizedBox(height: 20),
              // Required Salary Text Output
              _isSalaryCalculated
                  ? Container() // If salary is calculated, don't show anything
                  : Center(
                      child: Text(
                        "Please include estimates of Service Costs & Wear and Tear for more accurate calculations",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 128, 0, 32), // Consistent with app theme
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label on the left side
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          // Input box on the right side
          Container(
            width: 130, // Adjust width as necessary
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(String label, String value,
      {bool isDownPayment = false, bool isEmpty = false}) {
    // Apply color and icon only if it's the Down Payment field
    Color boxColor = Colors.white; // Default color for all fields
    Icon? icon = null;

    // Check if it's the Down Payment field
    if (isDownPayment) {
      if (isEmpty) {
        boxColor = Colors.red[100]!; // Red background when value is empty
        icon = Icon(Icons.close, color: Colors.red, size: 16); // 'X' when empty
      } else {
        boxColor =
            Colors.green[100]!; // Green background when value is provided
        icon = Icon(Icons.check,
            color: Colors.green, size: 16); // Check mark when filled
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: boxColor, // Set box color dynamically based on value
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                if (icon != null)
                  icon!, // Display icon if it's the Down Payment field
              ],
            ),
          ],
        ),
      ),
    );
  }
}
