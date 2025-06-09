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
                            OTPForm(),

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
}
