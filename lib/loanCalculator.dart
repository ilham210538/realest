import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  double _emi = 0.0;
  double _totalPayment = 0.0;
  double _upfrontCost = 0.0;
  double _yearlyExpense = 0.0;
  double _monthlyExpense = 0.0;
  double _monthlyIncomeRequired30 = 0.0;
  double _monthlyIncomeRequired20 = 0.0;
  double _downPayment = 0.0;
  double _salaryRequired20 = 0.0; // For 20% income allocation
  double _salaryRequired30 = 0.0; // For 30% income allocation

  @override
  void initState() {
    super.initState();
    _carPriceController =
        TextEditingController(text: widget.carPrice.toString());
    _roadTaxController = TextEditingController(text: widget.roadTax.toString());
    _insuranceController =
        TextEditingController(text: widget.insurance.toString());
    _downPaymentController.text = "10"; // Default Down Payment Percentage
    // _termController.text = "9"; // Default Loan Term in Years
    // _serviceCostController.text = "1100"; // Default Service Cost
    // _wearAndTearController.text = "1200"; // Default Wear & Tear Cost
  }

  void _calculateLoan() {
    try {
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
        _emi = emi; // Monthly EMI
        _totalPayment = totalPayment; // Total payment for the loan
      });
    } catch (e) {
      _showErrorDialog('Invalid input. Please enter valid numbers.');
    }
  }

  void _calculateUpfrontPayment() {
    double roadTax = _parseDouble(_roadTaxController.text);
    double insurance = _parseDouble(_insuranceController.text);
    _upfrontCost = _downPayment + roadTax + insurance;
    setState(() {});
  }

  void _calculateRequiredSalary() {
    try {
      double roadTax =
          _parseDouble(_roadTaxController.text); // Get road tax from user input
      double insurance = _parseDouble(
          _insuranceController.text); // Get insurance from user input
      double wearAndTear = _parseDouble(
          _wearAndTearController.text); // Get wear & tear from user input
      double serviceCost = _parseDouble(
          _serviceCostController.text); // Get service cost from user input

      // Add yearly expenses and divide by 12 to get monthly values
      double yearlyExpenses = roadTax + insurance + wearAndTear + serviceCost;
      double monthlyExpenses = yearlyExpenses / 12;

      // Calculate Total Monthly Expenses (EMI + Monthly expenses from yearly expenses)
      double totalMonthlyExpenses = _emi + monthlyExpenses;

      // Calculate required salary for 20% and 30% income allocation
      double salaryRequired20 =
          totalMonthlyExpenses / 0.20; // Salary needed for 20% of income
      double salaryRequired30 =
          totalMonthlyExpenses / 0.30; // Salary needed for 30% of income

      // Set state to update UI with calculated values
      setState(() {
        _monthlyExpense =
            totalMonthlyExpenses; // Total monthly expense including EMI
        _salaryRequired20 =
            salaryRequired20; // Required salary for 20% income allocation
        _salaryRequired30 =
            salaryRequired30; // Required salary for 30% income allocation
        _monthlyIncomeRequired30 =
            salaryRequired30; // Required monthly income for 30%
        _monthlyIncomeRequired20 =
            salaryRequired20; // Required monthly income for 20%
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
                onPressed: _calculateLoan,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row with downpayment and remaining price
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
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
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_downPayment)}, ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Bold and black for the price
                                ),
                              ),
                              TextSpan(
                                text: "the remaining price of the car is ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_parseDouble(_carPriceController.text) - _downPayment)}.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Bold black for the remaining price
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Second row with monthly payment
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
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
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text: "RM${currencyFormat.format(_emi)} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Bold black for the monthly payment
                                ),
                              ),
                              TextSpan(
                                text:
                                    "based on the loan term and interest rate provided.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Third row with total payment
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
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
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_totalPayment)} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Bold black for the total payment
                                ),
                              ),
                              TextSpan(
                                text: "over the course of the loan.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                onPressed: _calculateUpfrontPayment,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row with total upfront cost
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
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
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
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
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
              ElevatedButton(
                onPressed: _calculateRequiredSalary,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row with total monthly expenses
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "Your total monthly expense will be approximately ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_monthlyExpense)} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Bold black for the monthly expense
                                ),
                              ),
                              TextSpan(
                                text:
                                    "including EMI and additional expenses (road tax, insurance, etc.).",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Second row with required salary for 20% and 30% income allocation
                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "To allocate 20% of your income to sustain this car, you would need a monthly income of approximately ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_salaryRequired20)} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.black, // Bold black for the salary
                                ),
                              ),
                              TextSpan(
                                text: "per month.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.arrow_right,
                          size: 18, color: Color.fromARGB(255, 128, 0, 32)),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "For 30% of your income, you would need approximately ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                              TextSpan(
                                text:
                                    "RM${currencyFormat.format(_salaryRequired30)} ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.black, // Bold black for the salary
                                ),
                              ),
                              TextSpan(
                                text: "per month.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(
                                      255, 128, 0, 32), // Normal text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
