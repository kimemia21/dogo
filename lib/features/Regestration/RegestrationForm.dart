import 'package:dogo/features/Regestration/payment_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/PaymentMethodInfo.dart';
import 'package:dogo/data/models/TimeSlots.dart';
import 'package:dogo/data/models/booking.dart';
import 'package:dogo/data/services/FetchGlobals.dart';
import 'package:dogo/main.dart';
import 'package:dogo/widgets/common_widgets.dart';

class PodBookingPage extends StatefulWidget {
  @override
  _PodBookingPageState createState() => _PodBookingPageState();
}

class _PodBookingPageState extends State<PodBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();

  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  String _charges = "ksh 0";
  String? _errorMessage;
  bool _isLoading = false;
  List<PaymentMethodInfo> _paymentMethods = [];

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  // Helper method to determine if we're on web/desktop
  bool get isWeb => MediaQuery.of(context).size.width > 768;

  // Responsive sizing helpers
  double get maxWidth => isWeb ? 600 : double.infinity;
  double get horizontalPadding => isWeb ? 32 : 24;
  double get verticalPadding => isWeb ? 40 : 24;
  double get fieldHeight => isWeb ? 64 : 56;
  double get buttonHeight => isWeb ? 64 : 56;
  double get fontSize => isWeb ? 16 : 14;
  double get titleFontSize => isWeb ? 32 : 24;

  // API Methods (keeping original functionality)
  Future<void> _fetchPaymentMethods() async {
    try {
      _paymentMethods = await fetchGlobal<PaymentMethodInfo>(
        getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
        fromJson: PaymentMethodInfo.fromJson,
        endpoint: "configs/pay-methods",
      );
      setState(() {});
    } catch (e) {
      setState(() => _errorMessage = "Failed to fetch payment methods");
    }
  }

  Future<void> _bookPod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _errorMessage = "Please fill in all required fields");
        return;
      }

      final Map<String, dynamic> sessionData = {
        "podId": 1,
        "userPhone": _phoneController.text.trim(),
        "userName": _userNameController.text.trim(),
        "userEmail": _emailController.text.trim(),
      };

       print("presession Data $sessionData");

      sessionData.addAll(sessionbooking.toJson());
      print("Session Data $sessionData");

      final request = await comms.postRequest(
        endpoint: "pods/book",
        data: sessionData,
      );

      if (request["rsp"]['success'] && request['statusCode'] == 200) {
        booking = Booking.fromJson(
          request["rsp"]['data'],
          _phoneController.text,
          _userNameController.text,
          _emailController.text,
          _charges,
        );
        print("mesh${booking.toJson()}");
        _fetchPaymentMethods();
        setState(() => _currentStep = 1);
      } else {
        setState(() => _errorMessage = "Booking failed: ${request['rsp']}");
      }
    } catch (e) {
      setState(() => _errorMessage = "An error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _validateUserDetails()) {
      _bookPod();
    }
    // else if (_currentStep == 1) {
    //   if (_selectedPaymentMethod != null) {
    //     // Handle payment confirmation
    //     if (_selectedPaymentMethod == PaymentMethod.mpesa) {
    //       showMpesaPaymentDialog(context);
    //     } else {
    //       setState(() => _errorMessage = "Only M-Pesa is available for now");
    //     }
    //   } else {
    //     setState(() => _errorMessage = "Please select a payment method");
    //   }
    // }
  }

  bool _validateUserDetails() {
    return _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _userNameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Book a Pod', style: TextStyle(fontSize: titleFontSize)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: isWeb ? 80 : 56,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  SizedBox(height: isWeb ? 32 : 24),
                  _buildStepIndicator(),
                  SizedBox(height: isWeb ? 32 : 24),
                  Expanded(
                    child: SingleChildScrollView(child: _buildCurrentStep()),
                  ),
                  SizedBox(height: isWeb ? 32 : 24),
                  _buildBottomSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepTitles = ['Your Details', 'Payment'];
    return Column(
      children: [
        Text(
          stepTitles[_currentStep],
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isWeb ? 16 : 8),
        Text(
          _getStepDescription(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Enter your contact information';
      case 1:
        return 'Choose payment method';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
      child: Row(
        children: List.generate(2, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: isWeb ? 6 : 4,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Theme.of(context).colorScheme.secondary
                        : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildUserDetailsStep();
      case 1:
        return _buildPaymentStep();
      default:
        return Container();
    }
  }

  Widget _buildUserDetailsStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: isWeb ? 24 : 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: isWeb ? 24 : 16),
        _buildTextField(
          controller: _userNameController,
          label: 'Full Name',
          icon: Icons.person_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children:
          _paymentMethods.map((method) => _buildPaymentOption(method)).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: fieldHeight,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          prefixIcon: Icon(icon, size: isWeb ? 24 : 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isWeb ? 20 : 16,
            vertical: isWeb ? 20 : 16,
          ),
        ),
        validator:
            (value) => value?.isEmpty == true ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethodInfo method) {
    final isSelected = _selectedPaymentMethod == method.method;

    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 16 : 12),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPaymentMethod = method.method);
          _selectedPaymentMethod == PaymentMethod.mpesa
              ? showMpesaPaymentDialog(context)
              : _errorMessage = "Only M-Pesa is available for now";
        },
        child: Container(
          padding: EdgeInsets.all(isWeb ? 24 : 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : AppColors.border,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(method.icon, color: method.color, size: isWeb ? 28 : 24),
              SizedBox(width: isWeb ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      method.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: fontSize - 2,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.secondary,
                  size: isWeb ? 28 : 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            padding: EdgeInsets.all(isWeb ? 20 : 16),
            margin: EdgeInsets.only(bottom: isWeb ? 24 : 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: isWeb ? 24 : 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Container(
          height: buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Text(
              _isLoading ? 'LOADING...' : _getButtonText(),
              style: TextStyle(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        if (_currentStep > 0) ...[
          SizedBox(height: isWeb ? 20 : 16),
          Container(
            height: isWeb ? 48 : 40,
            child: TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'BOOK POD';
      case 1:
        return 'CONFIRM PAYMENT';
      default:
        return 'NEXT';
    }
  }
}
