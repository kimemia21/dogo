import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/Pod_sessions.dart';
import 'package:dogo/data/services/localHost.dart';
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
    // TESTING BYPASS
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => PodSessionHomepage(session: PodSession.empty()),

    //   ),
    // );
    //  Map<String, dynamic> data = {
    //       "user": "John",
    //       "duration": 2,
    //       "interval": 1,
    //       "startNow": true,
    //        "sessionid":"232112"
    //     };

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
        comms.setAuthToken(response["AuthToken"]);
        // Map<String, dynamic> data = {
        //   "user": "John",
        //   "duration": 2,
        //   "interval": 1,
        //   "startNow": true,
        //    "sessionid":"232112"
        // };
        print(session.toMap());

        Localhost.postToLocalhost("/api/start", session.toMap());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PodSessionHomepage(session: session),
          ),
        );
      } else {


        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    SizedBox(width: 12),
                    Text('Error'),
                  ],
                ),
                content: Text(
                  response["data"]["message"],
                  style: TextStyle(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("$e"), backgroundColor: Colors.red),
      // );
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
                              : () async {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    // Auto dismiss after 30 seconds
                                    Future.delayed(Duration(seconds: 30), () {
                                      Navigator.of(context).pop();
                                    });

                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      title: Column(
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            size: 40,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Scan to Register',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Container(
                                        width: 300,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Image.network(
                                                'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=YourDataHere',
                                                width: 250,
                                                height: 250,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Text(
                                              'Scan this QR code with your phone\'s camera to register for a new account',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Dialog will close in 30 seconds',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: Text(
                                            'Close',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
