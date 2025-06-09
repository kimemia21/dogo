import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/Pod_sessions.dart';
import 'package:dogo/features/Pod/PodSession.dart';
import 'package:dogo/features/Regestration/RegestrationForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPForm extends StatefulWidget {
  const OTPForm({Key? key}) : super(key: key);

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _validateOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await comms.postRequest(
        endpoint: "pod-sessions/otp",
        data: {"otp": otpController.text.toUpperCase()},
      );

      setState(() {
        _isLoading = false;
      });
      print(response);

      if (response["success"]) {
        print(response["rsp"]["data"]);
        final PodSession session = PodSession.fromMap(response["rsp"]["data"]);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PodSessionHomepage(session: session)),
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              response["data"]["message"],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWeb = screenWidth > 600;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    // Responsive dimensions
    double getFormWidth() {
      if (screenWidth > 1200) return 400; // Desktop large
      if (screenWidth > 800) return screenWidth * 0.4; // Desktop/tablet
      if (screenWidth > 600) return screenWidth * 0.6; // Small tablet
      return screenWidth * 0.9; // Mobile
    }

    double getHorizontalPadding() {
      if (screenWidth > 1200) return 24;
      if (screenWidth > 600) return 20;
      return 16;
    }

    double getVerticalSpacing() {
      if (screenHeight < 600) return 16; // Compact screens
      if (isWeb) return 32;
      return 24;
    }

    double getFontSize() {
      if (screenWidth > 1200) return 22;
      if (isWeb) return 20;
      return 18;
    }

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPadding(),
          vertical: isWeb ? 40 : 20,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: getFormWidth(),
            minHeight: isWeb ? 500 : 0,
          ),
          child: Card(
            elevation: isWeb ? 8 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
            ),
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 32 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header section
                    Column(
                      children: [
                        Text(
                          'Enter Your OTP',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontSize: isWeb ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Please enter the 6-digit code provided during registration',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: isWeb ? 16 : 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: getVerticalSpacing()),

                    // OTP Input Field
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return TextFormField(
                          controller: otpController,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length != 6) {
                              return 'OTP must be 6 digits';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'OTP Code',
                            hintText: '6-digit code',
                            prefixIcon: Icon(
                              Icons.vpn_key_outlined,
                              size: isWeb ? 24 : 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isWeb ? 20 : 16,
                              horizontal: 16,
                            ),
                          ),
                          // keyboardType: TextInputType.number,
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.digitsOnly,
                          //   LengthLimitingTextInputFormatter(6),
                          // ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: getFontSize(),
                            fontWeight: FontWeight.w500,
                            letterSpacing: isWeb ? 8 : 6,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: getVerticalSpacing()),

                    // Validate Button
                    _isLoading
                        ? Center(
                          child: SizedBox(
                            height: isWeb ? 56 : 48,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        )
                        : SizedBox(
                          height: isWeb ? 56 : 48,
                          child: ElevatedButton(
                            onPressed: _validateOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isWeb ? 4 : 2,
                            ),
                            child: Text(
                              'VALIDATE',
                              style: TextStyle(
                                fontSize: isWeb ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                    SizedBox(height: isWeb ? 24 : 16),

                    // Registration Link
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PodBookingPage(),
                                  ),
                                );
                              },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 16 : 12,
                        ),
                      ),
                      child: Text(
                        'Need to register? Tap here',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: isWeb ? 16 : 14,
                        ),
                      ),
                    ),

                    // Additional spacing for web
                    if (isWeb) SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
