import 'dart:ui';

import 'package:dogo/config/app_config.dart';
import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/data/models/PaymentMethodInfo.dart';
import 'package:dogo/widgets/RegestrationForm.dart';
import 'package:dogo/widgets/otp_form.dart';
import 'package:dogo/widgets/select_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



// Class to store payment method information
// class PaymentMethodInfo {
//   final String name;
//   final String description;
//   final IconData icon;
//   final Color color;

//   PaymentMethodInfo({
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.color,
//   });
// }

void main() {
  getPodId();

  runApp(PodApp());
}

class PodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Pod',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: getDevice(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  bool _isRegistering = false;
  bool _showValidationResult = false;
  String _validationMessage = '';
  late TabController _tabController;

  // Registration form state
  int _registrationStep = 1;
  String _selectedHours = "00";
  String _selectedMinutes = "00";
  String? _timeSelectionError;
  PaymentMethod? _selectedPaymentMethod;

  // Sample data for demo
  Map<String, Map<String, dynamic>> _PodSessions = {
    "123456": {
      "phone": "+1234567890",
      "timeIn": DateTime.now().subtract(Duration(hours: 1)),
      "duration": Duration(hours: 3),
      "isValid": true,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _validateOTP() {
    final otp = _otpController.text.trim();
    setState(() {
      if (_PodSessions.containsKey(otp) && _PodSessions[otp]!["isValid"]) {
        _showValidationResult = true;
        _validationMessage = 'Valid OTP';
      } else {
        _showValidationResult = true;
        _validationMessage = 'Invalid OTP';
      }
    });
  }

  void _registerPod() {
    if (_formKey.currentState!.validate()) {
      // Generate a random 6-digit OTP for demo
      final otp =
          (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      setState(() {
        _PodSessions[otp] = {
          "phone": _phoneController.text,
          "timeIn": DateTime.now(),
          "duration": Duration(hours: int.parse(_hoursController.text)),
          "isValid": true,
        };

        _otpController.text = otp;
        _showValidationResult = true;
        _validationMessage = 'Registration successful! Your OTP is: $otp';
        _isRegistering = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _showValidationResult = false;
      _otpController.clear();
      _phoneController.clear();
      _hoursController.clear();
      _validationMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Header
                    _buildHeader(),
                    SizedBox(height: 30),

                    // Main Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width > 600
                                ? 500
                                : MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_showValidationResult) _buildMainContent(),
                            if (_showValidationResult) _buildValidationResult(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Footer
                    Text(
                      '© ${DateTime.now().year} Premium Pod Services',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_parking_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(width: 12),
            Text(
              'PREMIUM Pod',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Quick, Secure, Convenient',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isRegistering) {
      return RegistrationForm(
        onRegistrationComplete: (p0, p1) {},
        onBackToOTP: () {},
      );
    } else {
      return OTPForm(
        otpController: _otpController,
        onValidate: _validateOTP,
        onRegister: () {
          setState(() {
            _isRegistering = true;
          });
        },
      );
    }
  }

  // Widget _buildOTPForm() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Text(
  //         'Enter Your OTP',
  //         style: Theme.of(context).textTheme.headlineMedium,
  //         textAlign: TextAlign.center,
  //       ),
  //       SizedBox(height: 8),
  //       Text(
  //         'Please enter the 6-digit code provided during registration',
  //         style: Theme.of(context).textTheme.bodyMedium,
  //         textAlign: TextAlign.center,
  //       ),
  //       SizedBox(height: 24),

  //       // OTP Input
  //       TextFormField(
  //         controller: _otpController,
  //         decoration: InputDecoration(
  //           labelText: 'OTP Code',
  //           hintText: '6-digit code',
  //           prefixIcon: Icon(Icons.vpn_key_outlined),
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Color(0xFFCBD5E1)),
  //           ),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Color(0xFFCBD5E1)),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
  //           ),
  //           filled: true,
  //           fillColor: Colors.white,
  //         ),
  //         keyboardType: TextInputType.number,
  //         inputFormatters: [
  //           FilteringTextInputFormatter.digitsOnly,
  //           LengthLimitingTextInputFormatter(6),
  //         ],
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.w500,
  //           letterSpacing: 8,
  //         ),
  //       ),
  //       SizedBox(height: 24),

  //       // Validate Button
  //       ElevatedButton(
  //         onPressed: _validateOTP,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Theme.of(context).colorScheme.secondary,
  //           foregroundColor: Colors.white,
  //           padding: EdgeInsets.symmetric(vertical: 16),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           elevation: 2,
  //         ),
  //         child: Text(
  //           'VALIDATE',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       SizedBox(height: 16),

  //       // Register Option
  //       TextButton(
  //         onPressed: () {
  //           setState(() {
  //             _isRegistering = true;
  //           });
  //         },
  //         child: Text(
  //           'Need to register? Tap here',
  //           style: TextStyle(
  //             color: Theme.of(context).colorScheme.secondary,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildRegistrationForm() {
  //   return Form(
  //     key: _formKey,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Text(
  //           'Register for Pod',
  //           style: Theme.of(context).textTheme.headlineMedium,
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 8),
  //         Text(
  //           'Enter your details to get a Pod code',
  //           style: Theme.of(context).textTheme.bodyMedium,
  //           textAlign: TextAlign.center,
  //         ),
  //         SizedBox(height: 24),

  //         // Step indicator
  //         _buildStepIndicator(),
  //         SizedBox(height: 24),

  //         // Form steps
  //         _registrationStep == 1
  //             ? _buildTimeSelectionStep()
  //             : _buildPaymentMethodStep(),

  //         SizedBox(height: 24),

  //         // Navigation buttons
  //         Row(
  //           children: [
  //             if (_registrationStep == 2)
  //               Expanded(
  //                 child: TextButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       _registrationStep = 1;
  //                     });
  //                   },
  //                   style: TextButton.styleFrom(
  //                     padding: EdgeInsets.symmetric(vertical: 16),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(Icons.arrow_back, size: 16),
  //                       SizedBox(width: 8),
  //                       Text('BACK'),
  //                     ],
  //                   ),
  //                 ),
  //               ),

  //             Expanded(
  //               flex: 2,
  //               child: ElevatedButton(
  //                 onPressed:
  //                     _registrationStep == 1
  //                         ? () {
  //                           if (_validateTimeSelection()) {
  //                             setState(() {
  //                               _registrationStep = 2;
  //                             });
  //                           }
  //                         }
  //                         : _registerPod,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Theme.of(context).colorScheme.secondary,
  //                   foregroundColor: Colors.white,
  //                   padding: EdgeInsets.symmetric(vertical: 16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   elevation: 2,
  //                 ),
  //                 child: Text(
  //                   _registrationStep == 1 ? 'NEXT' : 'CONFIRM PAYMENT',
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 16),

  //         // Back to OTP
  //         TextButton(
  //           onPressed: () {
  //             setState(() {
  //               _isRegistering = false;
  //               _registrationStep = 1;
  //             });
  //           },
  //           child: Text(
  //             'Already have an OTP? Go back',
  //             style: TextStyle(
  //               color: Theme.of(context).colorScheme.secondary,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStepIndicator() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Container(
  //           height: 4,
  //           decoration: BoxDecoration(
  //             color: Theme.of(context).colorScheme.secondary,
  //             borderRadius: BorderRadius.circular(2),
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 8),
  //       Expanded(
  //         child: Container(
  //           height: 4,
  //           decoration: BoxDecoration(
  //             color:
  //                 _registrationStep == 2
  //                     ? Theme.of(context).colorScheme.secondary
  //                     : Color(0xFFE2E8F0),
  //             borderRadius: BorderRadius.circular(2),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTimeSelectionStep() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       // Phone Number
  //       SizedBox(height: 24),

  //       // Duration Selector
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Select Pod Duration',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //               color: Color(0xFF334155),
  //             ),
  //           ),
  //           SizedBox(height: 12),
  //           Container(
  //             height: 150,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Color(0xFFCBD5E1)),
  //             ),
  //             child: Row(
  //               children: [
  //                 // Hours
  //                 Expanded(
  //                   child: _buildTimeWheelPicker(
  //                     label: 'Hours',
  //                     values: List.generate(
  //                       24,
  //                       (index) => index.toString().padLeft(2, '0'),
  //                     ),
  //                     selectedValue: _selectedHours,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _selectedHours = value;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 // Minutes
  //                 Expanded(
  //                   child: _buildTimeWheelPicker(
  //                     label: 'Minutes',
  //                     values: List.generate(
  //                       60,
  //                       (index) => index.toString().padLeft(2, '0'),
  //                     ),
  //                     selectedValue: _selectedMinutes,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _selectedMinutes = value;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (_timeSelectionError != null)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Text(
  //                 _timeSelectionError!,
  //                 style: TextStyle(color: Colors.red, fontSize: 12),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildTimeWheelPicker({
  //   required String label,
  //   required List<String> values,
  //   required String selectedValue,
  //   required Function(String) onChanged,
  // }) {
  //   return Column(
  //     children: [
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: Color(0xFF64748B),
  //         ),
  //       ),
  //       SizedBox(height: 4),
  //       Expanded(
  //         child: ListWheelScrollView(
  //           itemExtent: 40,
  //           diameterRatio: 1.5,
  //           physics: FixedExtentScrollPhysics(),
  //           children:
  //               values.map((value) {
  //                 final isSelected = value == selectedValue;
  //                 return Container(
  //                   width: double.infinity,
  //                   alignment: Alignment.center,
  //                   decoration:
  //                       isSelected
  //                           ? BoxDecoration(
  //                             color: Theme.of(
  //                               context,
  //                             ).colorScheme.secondary.withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(8),
  //                           )
  //                           : null,
  //                   child: Text(
  //                     value,
  //                     style: TextStyle(
  //                       fontSize: isSelected ? 20 : 16,
  //                       fontWeight:
  //                           isSelected ? FontWeight.bold : FontWeight.normal,
  //                       color:
  //                           isSelected
  //                               ? Theme.of(context).colorScheme.secondary
  //                               : Color(0xFF64748B),
  //                     ),
  //                   ),
  //                 );
  //               }).toList(),
  //           onSelectedItemChanged: (index) {
  //             onChanged(values[index]);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildPaymentMethodStep() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Text(
  //         'Select Payment Method',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.w500,
  //           color: Color(0xFF334155),
  //         ),
  //       ),
  //       SizedBox(height: 16),

  //       // Payment options
  //       ...PaymentMethod.values.map((method) => _buildPaymentOption(method)),

  //       SizedBox(height: 24),

  //       // Payment details form based on selected method
  //       if (_selectedPaymentMethod != null)
  //         AnimatedContainer(
  //           duration: Duration(milliseconds: 300),
  //           curve: Curves.easeInOut,
  //           child: _buildPaymentDetailsForm(_selectedPaymentMethod!),
  //         ),
  //     ],
  //   );
  // }

  // Widget _buildPaymentOption(PaymentMethod method) {
  //   final isSelected = _selectedPaymentMethod == method;
  //   final paymentInfo = _getPaymentMethodInfo(method);

  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedPaymentMethod = method;
  //       });
  //     },
  //     child: Container(
  //       margin: EdgeInsets.only(bottom: 12),
  //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Color(0xFFEFF6FF) : Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color:
  //               isSelected
  //                   ? Theme.of(context).colorScheme.secondary
  //                   : Color(0xFFCBD5E1),
  //           width: isSelected ? 2 : 1,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 24,
  //             height: 24,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(
  //                 color:
  //                     isSelected
  //                         ? Theme.of(context).colorScheme.secondary
  //                         : Color(0xFF94A3B8),
  //                 width: 2,
  //               ),
  //             ),
  //             child:
  //                 isSelected
  //                     ? Center(
  //                       child: Container(
  //                         width: 12,
  //                         height: 12,
  //                         decoration: BoxDecoration(
  //                           shape: BoxShape.circle,
  //                           color: Theme.of(context).colorScheme.secondary,
  //                         ),
  //                       ),
  //                     )
  //                     : null,
  //           ),
  //           SizedBox(width: 12),
  //           Container(
  //             padding: EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFF1F5F9),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Icon(paymentInfo.icon, color: paymentInfo.color),
  //           ),
  //           SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   paymentInfo.name,
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //                 ),
  //                 Text(
  //                   paymentInfo.description,
  //                   style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPaymentDetailsForm(PaymentMethod method) {
  //   switch (method) {
  //     case PaymentMethod.card:
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildDivider('Card Details'),
  //           TextFormField(
  //             decoration: _getInputDecoration(
  //               label: 'Card Number',
  //               hint: '1234 5678 9012 3456',
  //               icon: Icons.credit_card,
  //             ),
  //             keyboardType: TextInputType.number,
  //             inputFormatters: [
  //               FilteringTextInputFormatter.digitsOnly,
  //               LengthLimitingTextInputFormatter(16),
  //             ],
  //           ),
  //           SizedBox(height: 16),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextFormField(
  //                   decoration: _getInputDecoration(
  //                     label: 'Expiry Date',
  //                     hint: 'MM/YY',
  //                     icon: Icons.calendar_today,
  //                   ),
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.digitsOnly,
  //                     LengthLimitingTextInputFormatter(4),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(width: 16),
  //               Expanded(
  //                 child: TextFormField(
  //                   decoration: _getInputDecoration(
  //                     label: 'CVV',
  //                     hint: '123',
  //                     icon: Icons.lock_outline,
  //                   ),
  //                   obscureText: true,
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter.digitsOnly,
  //                     LengthLimitingTextInputFormatter(3),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 16),
  //           TextFormField(
  //             decoration: _getInputDecoration(
  //               label: 'Cardholder Name',
  //               hint: 'Name as it appears on card',
  //               icon: Icons.person_outline,
  //             ),
  //           ),
  //         ],
  //       );

  //     case PaymentMethod.bank:
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildDivider('Bank Transfer Details'),
  //           DropdownButtonFormField<String>(
  //             decoration: _getInputDecoration(
  //               label: 'Select Bank',
  //               hint: 'Choose your bank',
  //               icon: Icons.account_balance,
  //             ),
  //             items:
  //                 [
  //                   'KCB Bank',
  //                   'Equity Bank',
  //                   'Standard Chartered',
  //                   'Cooperative Bank',
  //                   'NCBA Bank',
  //                 ].map((String value) {
  //                   return DropdownMenuItem<String>(
  //                     value: value,
  //                     child: Text(value),
  //                   );
  //                 }).toList(),
  //             onChanged: (value) {},
  //           ),
  //           SizedBox(height: 16),
  //           TextFormField(
  //             decoration: _getInputDecoration(
  //               label: 'Account Number',
  //               hint: 'Enter your account number',
  //               icon: Icons.account_balance_wallet,
  //             ),
  //             keyboardType: TextInputType.number,
  //           ),
  //         ],
  //       );

  //     case PaymentMethod.mpesa:
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildDivider('M-Pesa Details'),
  //           TextFormField(
  //             controller: _phoneController,
  //             decoration: _getInputDecoration(
  //               label: 'M-Pesa Phone Number',
  //               hint: 'Enter phone number registered with M-Pesa',
  //               icon: Icons.phone_android,
  //             ),
  //             keyboardType: TextInputType.phone,
  //             enabled: false,
  //           ),
  //           SizedBox(height: 16),
  //           Container(
  //             padding: EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFEFF6FF),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Color(0xFFBFDBFE)),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
  //                 SizedBox(width: 12),
  //                 Expanded(
  //                   child: Text(
  //                     'You will receive an M-Pesa prompt on your phone to complete the payment.',
  //                     style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //   }
  // }

  Widget _buildDivider(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Color(0xFFE2E8F0))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: Color(0xFFE2E8F0))),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // PaymentMethodInfo _getPaymentMethodInfo(PaymentMethod method) {
  //   switch (method) {
  //     case PaymentMethod.card:
  //       return PaymentMethodInfo(
  //         name: 'Credit/Debit Card',
  //         description: 'Pay securely with your card',
  //         icon: Icons.credit_card,
  //         color: Colors.blue,
  //       );
  //     case PaymentMethod.bank:
  //       return PaymentMethodInfo(
  //         name: 'Bank Transfer',
  //         description: 'Pay directly from your bank account',
  //         icon: Icons.account_balance,
  //         color: Colors.green,
  //       );
  //     case PaymentMethod.mpesa:
  //       return PaymentMethodInfo(
  //         name: 'M-Pesa',
  //         description: 'Pay using M-Pesa mobile money',
  //         icon: Icons.phone_android,
  //         color: Colors.deepPurple,
  //       );
  //   }
  // }

  bool _validateTimeSelection() {
    if (_selectedHours == "00" && _selectedMinutes == "00") {
      setState(() {
        _timeSelectionError = "Please select a duration greater than 0";
      });
      return false;
    }
    setState(() {
      _timeSelectionError = null;
      // Convert selected time to hours for the existing logic
      _hoursController.text =
          (int.parse(_selectedHours) +
                  (int.parse(_selectedMinutes) > 0 ? 1 : 0))
              .toString();
    });
    return true;
  }

  Widget _buildValidationResult() {
    final otp = _otpController.text;
    bool isValidOTP =
        _PodSessions.containsKey(otp) && _PodSessions[otp]!["isValid"];

    if (!isValidOTP && !_validationMessage.contains('successful')) {
      return Column(
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Invalid OTP',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'The OTP you entered is not valid. Please check and try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('TRY AGAIN'),
          ),
        ],
      );
    } else if (_validationMessage.contains('successful')) {
      return Column(
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Registration Successful',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Your OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  otp,
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Please save this code. You will need it to verify your Pod session.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('DONE'),
          ),
        ],
      );
    } else {
      // Show Pod details for valid OTP
      final session = _PodSessions[otp]!;
      final timeIn = session["timeIn"] as DateTime;
      final duration = session["duration"] as Duration;
      final timeOut = timeIn.add(duration);
      final now = DateTime.now();
      final remaining = timeOut.difference(now);

      return Column(
        children: [
          Icon(Icons.check_circle_outline, size: 70, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Valid Pod Session',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 24),

          _buildPodInfoCard('Time In', '${_formatTime(timeIn)}', Icons.login),

          _buildPodInfoCard(
            'Time Out',
            '${_formatTime(timeOut)}',
            Icons.logout,
          ),

          _buildPodInfoCard(
            'Time Remaining',
            remaining.isNegative
                ? 'Expired'
                : '${remaining.inHours}h ${remaining.inMinutes % 60}m',
            Icons.timer,
            isHighlighted: true,
          ),

          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('DONE'),
          ),
        ],
      );
    }
  }

  Widget _buildPodInfoCard(
    String title,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isHighlighted ? Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? Color(0xFFBFDBFE) : Color(0xFFE2E8F0),
        ),
        boxShadow:
            isHighlighted
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlighted ? Color(0xFFDBEAFE) : Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isHighlighted ? Color(0xFF3B82F6) : Color(0xFF64748B),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        isHighlighted ? Color(0xFF1E40AF) : Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}';
  }
}
