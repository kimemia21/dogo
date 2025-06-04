import 'package:dogo/features/Pod/otpPage.dart';
import 'package:flutter/material.dart';
import 'package:dogo/features/Regestration/RegestrationForm.dart';

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

  // Sample data for demo - Consider moving this to a service/repository class
  Map<String, Map<String, dynamic>> _podSessions = {
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

  // void _validateOTP() {
  //   final otp = _otpController.text.trim();
  //   setState(() {
  //     if (_podSessions.containsKey(otp) && _podSessions[otp]!["isValid"]) {
  //       _showValidationResult = true;
  //       _validationMessage = 'Valid OTP';
  //     } else {
  //       _showValidationResult = true;
  //       _validationMessage = 'Invalid OTP';
  //     }
  //   });
  // }

  // void _resetForm() {
  //   setState(() {
  //     _showValidationResult = false;
  //     _otpController.clear();
  //     _phoneController.clear();
  //     _hoursController.clear();
  //     _validationMessage = '';
  //     _isRegistering = false;
  //   });
  // }

  // void _handleRegistrationComplete(String phone, String otp) {
  //   setState(() {
  //     _validationMessage = 'Registration successful';
  //     _showValidationResult = true;
  //     _isRegistering = false;
  //     // Update the OTP controller to show the generated OTP
  //     _otpController.text = otp;
  //   });
  // }

  // void _handleBackToOTP() {
  //   print("Back to OTP pressed");
  //   setState(() {
  //     _isRegistering = false;
  //   });
  // }

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
                            OTPForm(
                            
                            ),

                            // if (_showValidationResult) _buildValidationResult(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Footer
                    Text(
                      '© ${DateTime.now().year} DOGO Services',
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
              'DOGO',
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


  // Widget _buildValidationResult() {
  //   final otp = _otpController.text; 
  //   bool isValidOTP =
  //       _podSessions.containsKey(otp) && _podSessions[otp]!["isValid"];

  //   if (!isValidOTP && !_validationMessage.contains('successful')) {
  //     return _buildInvalidOTPResult();
  //   } else if (_validationMessage.contains('successful')) {
  //     return _buildRegistrationSuccessResult(otp);
  //   } else {
  //     return _buildValidPodSessionResult(otp);
  //   }
  // }



  // Widget _buildRegistrationSuccessResult(String otp) {
  //   return Column(
  //     children: [
  //       Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
  //       SizedBox(height: 16),
  //       Text(
  //         'Registration Successful',
  //         style: Theme.of(context).textTheme.headlineMedium,
  //       ),
  //       SizedBox(height: 16),
  //       Container(
  //         padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
  //         decoration: BoxDecoration(
  //           color: Colors.blue.shade50,
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: Colors.blue.shade200),
  //         ),
  //         child: Column(
  //           children: [
  //             Text(
  //               'Your OTP',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.blue.shade800,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               otp,
  //               style: TextStyle(
  //                 fontSize: 28,
  //                 letterSpacing: 8,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.blue.shade800,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 24),
  //       Text(
  //         'Please save this code. You will need it to verify your Pod session.',
  //         textAlign: TextAlign.center,
  //         style: Theme.of(context).textTheme.bodyMedium,
  //       ),
  //       SizedBox(height: 24),
  //       ElevatedButton(
  //         onPressed: _resetForm,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Theme.of(context).colorScheme.secondary,
  //           foregroundColor: Colors.white,
  //           padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         child: Text('DONE'),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildValidPodSessionResult(String otp) {
  //   final session = _podSessions[otp]!;
  //   final timeIn = session["timeIn"] as DateTime;
  //   final duration = session["duration"] as Duration;
  //   final timeOut = timeIn.add(duration);
  //   final now = DateTime.now();
  //   final remaining = timeOut.difference(now);

  //   return Column(
  //     children: [
  //       Icon(Icons.check_circle_outline, size: 70, color: Colors.green),
  //       SizedBox(height: 16),
  //       Text(
  //         'Valid Pod Session',
  //         style: Theme.of(context).textTheme.headlineMedium,
  //       ),
  //       SizedBox(height: 24),

  //       _buildPodInfoCard('Time In', '${_formatTime(timeIn)}', Icons.login),

  //       _buildPodInfoCard('Time Out', '${_formatTime(timeOut)}', Icons.logout),

  //       _buildPodInfoCard(
  //         'Time Remaining',
  //         remaining.isNegative
  //             ? 'Expired'
  //             : '${remaining.inHours}h ${remaining.inMinutes % 60}m',
  //         Icons.timer,
  //         isHighlighted: true,
  //       ),

  //       SizedBox(height: 24),
  //       ElevatedButton(
  //         onPressed: _resetForm,
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Theme.of(context).colorScheme.secondary,
  //           foregroundColor: Colors.white,
  //           padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //         child: Text('DONE'),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildPodInfoCard(
  //   String title,
  //   String value,
  //   IconData icon, {
  //   bool isHighlighted = false,
  // }) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 8),
  //     padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  //     decoration: BoxDecoration(
  //       color: isHighlighted ? Color(0xFFEFF6FF) : Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: isHighlighted ? Color(0xFFBFDBFE) : Color(0xFFE2E8F0),
  //       ),
  //       boxShadow:
  //           isHighlighted
  //               ? [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 4,
  //                   offset: Offset(0, 2),
  //                 ),
  //               ]
  //               : null,
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: isHighlighted ? Color(0xFFDBEAFE) : Color(0xFFF1F5F9),
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Icon(
  //             icon,
  //             color: isHighlighted ? Color(0xFF3B82F6) : Color(0xFF64748B),
  //             size: 24,
  //           ),
  //         ),
  //         SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
  //               ),
  //               SizedBox(height: 4),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w600,
  //                   color:
  //                       isHighlighted ? Color(0xFF1E40AF) : Color(0xFF334155),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // String _formatTime(DateTime time) {
  //   return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}';
  // }
}
