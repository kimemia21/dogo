import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/Pod_sessions.dart';
import 'package:dogo/data/services/localHost.dart';
import 'package:dogo/features/Pod/PodSession.dart';
import 'package:dogo/features/Pod/playerr.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _isNumberMode = false;

  @override
  void initState() {
    super.initState();
    // Disable system keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // void _onKeyboardTap(String value) {
  //   if (value == 'backspace') {
  //     if (otpController.text.isNotEmpty) {
  //       otpController.text = otpController.text.substring(0, otpController.text.length - 1);
  //     }
  //   } else if (value == 'clear') {
  //     otpController.clear();
  //   } else if (otpController.text.length < 6) {
  //     otpController.text += value;
  //   }
  //   setState(() {});
  // }

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

      if (response["rsp"]["success"]) {
        

        // print(response["rsp"]["data"]);

        final PodSession session = PodSession.fromMap(response["rsp"]["data"]);

        // comms.setAuthToken(response["AuthToken"]);
        print(session.toMap());

        Localhost.postToLocalhost("/api/start", session.toMap());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
   
            PodSessionHomepage(session: session),
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
                  response["rsp"]["message"],
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
    }
  }



 Widget _buildKeyboardButton(String value, {bool isSpecial = false, double? flex}) {
  return Expanded(
    flex: flex?.round() ?? 1,
    child: Container(
      margin: EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _onKeyboardTap(value),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSpecial 
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
              : Colors.white,
          foregroundColor: isSpecial 
              ? Theme.of(context).colorScheme.secondary
              : Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.border),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
          minimumSize: Size(0, 45),
        ),
        child: isSpecial && value == 'backspace'
            ? Icon(Icons.backspace_outlined, size: 20)
            : isSpecial && value == 'clear'
                ? Icon(Icons.clear, size: 20)
                : isSpecial && value == 'space'
                    ? Icon(Icons.space_bar, size: 20)
                    : Text(
                        value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
      ),
    ),
  );
}Widget _buildKeyboard() {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        if (!_isNumberMode) ...[
          // Letter mode - Row 1: Q W E R T Y U I O P
          Row(
            children: [
              _buildKeyboardButton('Q'),
              _buildKeyboardButton('W'),
              _buildKeyboardButton('E'),
              _buildKeyboardButton('R'),
              _buildKeyboardButton('T'),
              _buildKeyboardButton('Y'),
              _buildKeyboardButton('U'),
              _buildKeyboardButton('I'),
              _buildKeyboardButton('O'),
              _buildKeyboardButton('P'),
            ],
          ),
          SizedBox(height: 4),
          // Row 2: A S D F G H J K L
          Row(
            children: [
              SizedBox(width: 15),
              _buildKeyboardButton('A'),
              _buildKeyboardButton('S'),
              _buildKeyboardButton('D'),
              _buildKeyboardButton('F'),
              _buildKeyboardButton('G'),
              _buildKeyboardButton('H'),
              _buildKeyboardButton('J'),
              _buildKeyboardButton('K'),
              _buildKeyboardButton('L'),
              SizedBox(width: 15),
            ],
          ),
          SizedBox(height: 4),
          // Row 3: Z X C V B N M + Backspace
          Row(
            children: [
              SizedBox(width: 30),
              _buildKeyboardButton('Z'),
              _buildKeyboardButton('X'),
              _buildKeyboardButton('C'),
              _buildKeyboardButton('V'),
              _buildKeyboardButton('B'),
              _buildKeyboardButton('N'),
              _buildKeyboardButton('M'),
              _buildKeyboardButton('backspace', isSpecial: true, flex: 1.5),
            ],
          ),
        ] else ...[
          // Number mode - Numbers in 3x3 grid + 0
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox()),
              _buildKeyboardButton('1'),
              _buildKeyboardButton('2'),
              _buildKeyboardButton('3'),
              Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox()),
              _buildKeyboardButton('4'),
              _buildKeyboardButton('5'),
              _buildKeyboardButton('6'),
              Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox()),
              _buildKeyboardButton('7'),
              _buildKeyboardButton('8'),
              _buildKeyboardButton('9'),
              Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(flex: 2, child: SizedBox()),
              Expanded(child: SizedBox()),
              _buildKeyboardButton('0'),
              Expanded(child: SizedBox()),
              _buildKeyboardButton('backspace', isSpecial: true),
              Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ],
        SizedBox(height: 4),
        // Bottom row: Mode Switch + Clear + Space
        Row(
          children: [
            _buildKeyboardButton(_isNumberMode ? 'ABC' : '123', isSpecial: true, flex: 2),
            _buildKeyboardButton('clear', isSpecial: true, flex: 2),
            _buildKeyboardButton('space', isSpecial: true, flex: 4),
          ],
        ),
      ],
    ),
  );
}

// Updated _onKeyboardTap method
void _onKeyboardTap(String value) {
  if (value == 'backspace') {
    if (otpController.text.isNotEmpty) {
      otpController.text = otpController.text.substring(0, otpController.text.length - 1);
    }
  } else if (value == 'clear') {
    otpController.clear();
  } else if (value == 'space') {
    if (otpController.text.length < 6) {
      otpController.text += ' ';
    }
  } else if (value == '123') {
    setState(() {
      _isNumberMode = true;
    });
    return;
  } else if (value == 'ABC') {
    setState(() {
      _isNumberMode = false;
    });
    return;
  } else if (otpController.text.length < 6) {
    otpController.text += value;
  }
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate ideal dimensions for 6:9 aspect ratio
    final double idealWidth = screenHeight * (6 / 9);
    final double idealHeight = screenWidth * (9 / 6);
    
    // Determine which dimension to use based on screen constraints
    final bool useWidthConstraint = idealHeight <= screenHeight;
    final double containerWidth = useWidthConstraint ? screenWidth : idealWidth;
    final double containerHeight = useWidthConstraint ? idealHeight : screenHeight;
    
    // Responsive sizing based on container dimensions
    final bool isCompact = containerHeight < 600;
    
    double getFormWidth() {
      return containerWidth * 0.9;
    }

    double getHorizontalPadding() {
      return containerWidth * 0.05;
    }

    double getVerticalSpacing() {
      return isCompact ? 12 : 20;
    }

    double getFontSize() {
      return isCompact ? 16 : 18;
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: getHorizontalPadding(),
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: getFormWidth(),
              maxHeight: containerHeight - 32,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
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
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: isCompact ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please enter the 6-digit code provided during registration',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: isCompact ? 12 : 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      SizedBox(height: getVerticalSpacing()),

                      // OTP Display Field
                      Container(
                        height: isCompact ? 50 : 60,
                        child: TextFormField(
                          controller: otpController,
                          focusNode: _focusNode,
                          readOnly: true,
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
                              size: isCompact ? 20 : 24,
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
                              vertical: isCompact ? 12 : 16,
                              horizontal: 16,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: getFontSize(),
                            fontWeight: FontWeight.w500,
                            letterSpacing: isCompact ? 4 : 6,
                          ),
                        ),
                      ),

                      SizedBox(height: getVerticalSpacing()),

                      // Custom Keyboard
                      Flexible(
                        child: _buildKeyboard(),
                      ),

                      SizedBox(height: getVerticalSpacing()),

                      // Validate Button
                      _isLoading
                          ? Center(
                              child: SizedBox(
                                height: isCompact ? 40 : 48,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                            )
                          : SizedBox(
                              height: isCompact ? 40 : 48,
                              child: ElevatedButton(
                                onPressed: _validateOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  'VALIDATE',
                                  style: TextStyle(
                                    fontSize: isCompact ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),

                      SizedBox(height: getVerticalSpacing()),

                      // Registration Link
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
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
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Scan to Register',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
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
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image.asset(
                                                'assets/images/qrcode.png',
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
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(
                                            'Close',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
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
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Need to register? Tap here',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: isCompact ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}