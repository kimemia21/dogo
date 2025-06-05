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
  DateTime _selectedDate = DateTime.now();
  String get formattedDate =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  TimeSlot? _selectedTimeSlot;
  PaymentMethod? _selectedPaymentMethod;
  String _selectedHours = '01';
  String _selectedMinutes = '00';
  String _charges = "ksh 0";
  String? _errorMessage;
  bool _isLoading = false;
  List<PaymentMethodInfo> _paymentMethods = [];
  List<TimeSlot> _availableSlots = [];

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
  Future<void> _fetchTariffs() async {
    try {
      final req = await comms.getRequests(
        endpoint: "rates",
        queryParameters: {
          "hh": int.parse(_selectedHours),
          "mm": int.parse(_selectedMinutes),
        },
      );
      if (req["rsp"]['success']) {
        setState(() {
          _charges = req["rsp"]['data']['charges'];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Failed to fetch charges");
    }
  }

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

  Future<void> _fetchAvailableSlots() async {
    setState(() => _isLoading = true);
    try {
      final req = await comms.postRequest(
        endpoint: "pods/slots",
        data: {"podId": 1, "date": formattedDate},
      );

      if (req["rsp"]['success']) {
        setState(() {
          _availableSlots =
              (req["rsp"]['data'] as List)
                  .map((slot) => TimeSlot.fromJson(slot))
                  .toList();
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Failed to fetch available slots");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookPod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessionData = {
        "podId": 1,
        "date": formattedDate,
        "startTime": _selectedTimeSlot!.timeSlot,
        "hh": _selectedHours,
        "mm": _selectedMinutes,
        "userPhone": _phoneController.text,
        "userName": _userNameController.text,
        "userEmail": _emailController.text,
      };

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
        setState(() => _currentStep = 3);
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
      setState(() => _currentStep = 1);
      _fetchAvailableSlots();
    } else if (_currentStep == 1 && _selectedTimeSlot != null) {
      setState(() => _currentStep = 2);
      _fetchTariffs();
    } else if (_currentStep == 2) {
      _bookPod();
    }
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
    final stepTitles = ['Your Details', 'Select Time', 'Duration', 'Payment'];
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
        return 'Choose your preferred date and time';
      case 2:
        return 'Select booking duration';
      case 3:
        return 'Choose payment method';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20),
      child: Row(
        children: List.generate(4, (index) {
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
        return _buildSlotsStep();
      case 2:
        return _buildDurationStep();
      case 3:
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

  Widget _buildSlotsStep() {
    return Column(
      children: [
        _buildCompactDateSelector(),
        SizedBox(height: isWeb ? 32 : 20),
        if (_isLoading)
          Center(child: CircularProgressIndicator(strokeWidth: isWeb ? 4 : 3))
        else if (_availableSlots.isNotEmpty)
          _buildCompactTimeSlots(),
      ],
    );
  }

  Widget _buildDurationStep() {
    return Column(
      children: [
        isWeb
            ? Row(
              children: [
                Expanded(
                  child: _buildDurationPicker('Hours', _selectedHours, (val) {
                    setState(() => _selectedHours = val);
                    _fetchTariffs();
                  }),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _buildDurationPicker('Minutes', _selectedMinutes, (
                    val,
                  ) {
                    setState(() => _selectedMinutes = val);
                    _fetchTariffs();
                  }),
                ),
              ],
            )
            : Column(
              children: [
                _buildDurationPicker('Hours', _selectedHours, (val) {
                  setState(() => _selectedHours = val);
                  _fetchTariffs();
                }),
                SizedBox(height: 16),
                _buildDurationPicker('Minutes', _selectedMinutes, (val) {
                  setState(() => _selectedMinutes = val);
                  _fetchTariffs();
                }),
              ],
            ),
        SizedBox(height: isWeb ? 32 : 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isWeb ? 24 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                'Total Charges',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: fontSize),
              ),
              SizedBox(height: 8),
              Text(
                _charges,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: isWeb ? 28 : 20,
                ),
              ),
            ],
          ),
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

  Widget _buildCompactDateSelector() {
    return Container(
      height: isWeb ? 100 : 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              _selectedDate.day == date.day &&
              _selectedDate.month == date.month;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTimeSlot = null;
              });
              _fetchAvailableSlots();
            },
            child: Container(
              width: isWeb ? 80 : 60,
              margin: EdgeInsets.only(right: isWeb ? 12 : 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.secondary
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['S', 'M', 'T', 'W', 'T', 'F', 'S'][date.weekday % 7],
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 12,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: isWeb ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactTimeSlots() {
    return isWeb
        ? GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _availableSlots.length,
          itemBuilder: (context, index) {
            final slot = _availableSlots[index];
            return _buildTimeSlotItem(slot);
          },
        )
        : Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _availableSlots.map((slot) => _buildTimeSlotItem(slot)).toList(),
        );
  }

  Widget _buildTimeSlotItem(TimeSlot slot) {
    final isSelected = _selectedTimeSlot?.timeSlot == slot.timeSlot;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeSlot = slot),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 20 : 16,
          vertical: isWeb ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.secondary
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
        child: Text(
          slot.timeSlot,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDurationPicker(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(fontSize: fontSize, color: Colors.black),
              items: List.generate(
                label == 'Hours' ? 24 : 60,
                (index) => DropdownMenuItem(
                  value: index.toString().padLeft(2, '0'),
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
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
        return 'CONTINUE';
      case 1:
        return 'SELECT TIME';
      case 2:
        return 'BOOK POD';
      case 3:
        return 'CONFIRM PAYMENT';
      default:
        return 'NEXT';
    }
  }
}
