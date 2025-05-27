import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OTPForm extends StatelessWidget {
  final TextEditingController otpController;
  final VoidCallback onValidate;
  final VoidCallback onRegister;

  const OTPForm({
    Key? key,
    required this.otpController,
    required this.onValidate,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter Your OTP',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Please enter the 6-digit code provided during registration',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        
        _buildOTPInput(context),
        SizedBox(height: 24),
        
        CustomButton(
          text: 'VALIDATE',
          onPressed: onValidate,
        ),
        SizedBox(height: 16),
        
        TextButton(
          onPressed: onRegister,
          child: Text(
            'Need to register? Tap here',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPInput(BuildContext context) {
    return TextFormField(
      controller: otpController,
      decoration: InputDecoration(
        labelText: 'OTP Code',
        hintText: '6-digit code',
        prefixIcon: Icon(Icons.vpn_key_outlined),
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 8,
      ),
    );
  }
}