import 'dart:async';
import 'dart:math';

import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/data/models/PaymentMethodInfo.dart';
import 'package:dogo/data/models/TimeSlots.dart';
import 'package:dogo/data/models/booking.dart';
import 'package:dogo/data/services/FetchGlobals.dart';
import 'package:dogo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// // Time slot model
// class TimeSlot {
//   final String time;
//   final bool isAvailable;
//   final DateTime dateTime;

//   TimeSlot({
//     required this.time,
//     required this.isAvailable,
//     required this.dateTime,
//   });
// }

// Duration option model
class DurationOption {
  String label;
  Duration duration;

  DurationOption({required this.label, required this.duration});
}

class RegistrationForm extends StatefulWidget {
  final Function(String otp, Map<String, dynamic> sessionData)
  onRegistrationComplete;
  final VoidCallback onBackToOTP;

  const RegistrationForm({
    Key? key,
    required this.onRegistrationComplete,
    required this.onBackToOTP,
  }) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // Registration form state
  int _registrationStep = 1;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  DurationOption? _selectedDuration;
  PaymentMethod? _selectedPaymentMethod;
  String? _bookingError;
  String _selectedMinutes = '00';
  String _selectedHours = '00';
  String? _timeSelectionError;
  bool _isLoading = false;
  String Charges = "ksh 1000";
  List<PaymentMethodInfo> payments = [];
  List<TimeSlot> slots = [];

  // Duration options
  final List<DurationOption> _durationOptions = [
    DurationOption(label: '30 mins', duration: Duration(minutes: 30)),
    DurationOption(label: '1 hour', duration: Duration(hours: 1)),
    DurationOption(label: '2 hours', duration: Duration(hours: 2)),
    DurationOption(label: '3 hours', duration: Duration(hours: 3)),
    DurationOption(label: '4 hours', duration: Duration(hours: 4)),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void getTarrifs() async {
    final req = await comms.getRequests(
      endpoint: "rates",
      queryParameters: {
        "hh": int.parse(_selectedHours),
        "mm": int.parse(_selectedMinutes),
      },
    );
    print("this is $req");
    if (req["rsp"]['success']) {
      setState(() {
        Charges = req["rsp"]['data']['charges'];
      });
    } else {
      setState(() {
        _timeSelectionError = "Failed to fetch charges";
      });
    }
  }

  void getPayments() async {
    try {
      payments = await fetchGlobal<PaymentMethodInfo>(
        getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
        fromJson: PaymentMethodInfo.fromJson,
        endpoint: "configs/pay-methods",
      );
    } catch (e) {
      print("Error fetching payment methods: $e");
      setState(() {
        _bookingError = "Failed to fetch payment methods";
      });
    }
  }

  // Generate time slots for a given _selectedDate (you'll replace this with API call)

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // void _registerPod() {
  //   if (_formKey.currentState!.validate() && _validateBookingSelection()) {
  //     // Generate a random 6-digit OTP for demo
  //     final otp =
  //         (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

  //     final sessionData = {
  //       "phone": _phoneController.text,
  //       "startTime": _selectedTimeSlot!.timeSlot,
  //       // "endTime": _selectedTimeSlot!.timeSlot.add(_selectedDuration!.duration),
  //       "duration": _selectedDuration!.duration,
  //       "paymentMethod": _selectedPaymentMethod.toString(),
  //       "isValid": true,
  //     };

  //     widget.onRegistrationComplete(otp, sessionData);
  //   }
  // }

  void _bookPod() async {
    if (!_formKey.currentState!.validate() || !_validateBookingSelection()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _bookingError = null;
    });

    try {
      DateTime date = _selectedDate;
      final sessionData = {
        "podId": 1,
        "date":
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}", //YYYY-MM-DD
        "startTime": _selectedTimeSlot!.timeSlot,
        "hh": _selectedHours, //duration hours
        "mm": _selectedMinutes, // duration minutes
        "userPhone": _phoneController.text,
        "userName": _userNameController.text,
        "userEmail": _userNameController.text,
      };

      final request = await comms.postRequest(
        endpoint: "pods/book",
        data: sessionData,
      );
      print("Booking request: $request");

      if (!mounted) return;

      if (request["rsp"]['success']) {
        final response = request['message'];
        final statusCode = request['statusCode'];
        //  save the booking data to memory
        booking = Booking.fromJson(
          request["rsp"]['data'],
          _phoneController.text,
          _userNameController.text,
          _emailController.text,
        );
        getPayments();

        if (statusCode == 200) {
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _registrationStep = 2;
              _isLoading = false;
              _bookingError = null;
            });
          });
        } else {
          setState(() {
            _isLoading = false;
            _bookingError = "Booking failed: ${response['message']}";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _bookingError = "Booking failed: ${request['rsp']}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _bookingError = "An error occurred: ${e.toString()}";
      });
    }
  }

  Future<bool?> _showPaymentConfirmationDialog(String phoneNumber) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController phoneEditController = TextEditingController(
          text: phoneNumber,
        );

        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirm Payment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'M-Pesa Transaction',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'KSh booking..toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            booking.sessionId,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Phone number input
                TextField(
                  controller: phoneEditController,
                  decoration: InputDecoration(
                    labelText: 'M-Pesa Phone Number',
                    hintText: '0712345678 or +254712345678',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.phone),
                    //  Container(
                    //   padding: const EdgeInsets.all(12),
                    //   child: Image.network(
                    //     'https://play-lh.googleusercontent.com/bRZF74-13jknePwUd1xam5ZCSdAJVuI_wqtkrisBgu7EEh1jobh2boZihlk-4ikY_S3V', // Add M-Pesa logo
                    //     width: 24,
                    //     height: 24,
                    //   ),
                    // ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.contacts),
                      onPressed: () {
                        // TODO: Implement contact picker
                      },
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),

                const SizedBox(height: 16),

                // Information container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Process',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• You will receive an M-Pesa STK push prompt\n'
                        '• Enter your M-Pesa PIN to authorize payment\n'
                        '• Payment confirmation will be sent via SMS\n'
                        '• Transaction may take up to 2 minutes to process',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Security notice
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secured by M-Pesa. Your transaction is protected.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.payment, size: 18),
              label: const Text(
                'PAY NOW',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final phone = phoneEditController.text.trim();
              

   
                Navigator.of(context).pop(true);
                // }
                //  else {
                //   _showErrorSnackBar('Please enter a valid phone number');
                // }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiatePayment() async {
    if (_selectedPaymentMethod != PaymentMethod.mpesa) return;

    String phoneNumber = _phoneController.text.trim();

    // Validate phone number format
    // if (!_isValidKenyanPhoneNumber(phoneNumber)) {
    //   _showErrorSnackBar('Please enter a valid Kenyan phone number');
    //   return;
    // }

    // Show professional confirmation dialog
    final bool? confirmed = await _showPaymentConfirmationDialog(phoneNumber);
    if (confirmed != true) return;

    // Show loading state with countdown
    _showLoadingDialogWithTimer();

    try {
      final response = await comms.postRequest(
        endpoint: "pods/pay",
        data: {
          "sessionId": booking.sessionId,
          "payMethod": 1, // M-Pesa payment method
          "mpesaNo": phoneNumber,
          "cardName": "",
        },
      );

      if (response["rsp"]?['success'] == true) {
        _startPaymentStatusCheck();
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        final errorMessage =
            response["rsp"]?['message'] ?? 'Payment initiation failed';
        await _showErrorDialog('Payment Failed', errorMessage);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      await _showErrorDialog(
        'Connection Error',
        'Unable to connect to payment service. Please check your internet connection and try again.',
      );

      // Log error for debugging
      debugPrint('M-Pesa payment error: ${e.toString()}');
    }
  }

  void _showLoadingDialogWithTimer() {
    int countdown = 20;
    bool dialogClosed = false;
    String currentMessage = 'Initiating Payment...';
    String currentSubMessage = 'Please wait while we process your request';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      currentMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSubMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Timeout in ${countdown}s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Start countdown timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (dialogClosed) {
        timer.cancel();
        return;
      }

      countdown--;

      if (countdown <= 0) {
        timer.cancel();
        if (!dialogClosed) {
          dialogClosed = true;
          Navigator.of(context).pop(); // Close loading dialog
          _showErrorDialog(
            'Payment Timeout',
            'Payment request timed out. Please try again.',
          );
        }
        return;
      }

      // Update the dialog if it's still showing
      if (Navigator.of(context).canPop()) {
        // Find the dialog and update it
        // Note: This is a simplified approach. In production, you might want to use a more robust state management solution.
      }
    });
  }

  void _startPaymentStatusCheck() {
    int checkCount = 0;
    const maxChecks = 60; // 5 minutes (5 second intervals)

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final statusResponse = await comms.getRequests(
          endpoint: "pod-sessions/${booking.sessionId}/status",
        );

        final paymentStatus =
            statusResponse["rsp"]["data"]['sessPaymentStatus'];

        if (paymentStatus == 'paid') {
          timer.cancel();
          Navigator.of(context).pop(); // Close loading dialog
          await _showSuccessDialog();
          _handlePaymentSuccess();
        } else if (paymentStatus == 'failed') {
          timer.cancel();
          Navigator.of(context).pop(); // Close loading dialog
          _handlePaymentFailure(statusResponse["rsp"]?['message']);
        } else if (paymentStatus == 'pending') {
          // Show PIN entry prompt if it's the first pending status
          if (checkCount == 0) {
            _showPinEntryPrompt();
          }
        }

        checkCount++;

        // Cancel after maximum checks
        if (checkCount >= maxChecks) {
          timer.cancel();
          Navigator.of(context).pop(); // Close loading dialog
          _handlePaymentFailure(
            'Payment verification timed out. Please check your M-Pesa messages.',
          );
        }
      } catch (e) {
        debugPrint('Payment status check error: $e');
        checkCount++;

        if (checkCount >= maxChecks) {
          timer.cancel();
          Navigator.of(context).pop(); // Close loading dialog
          _handlePaymentFailure(
            'Unable to verify payment status. Please check your M-Pesa messages.',
          );
        }
      }
    });
  }

  void _showPinEntryPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'M-Pesa PIN Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Check your phone and enter PIN within 2 minutes',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment Successful!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your M-Pesa payment has been processed successfully. You will receive a confirmation SMS shortly.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _initiatePayment(); // Retry payment
                  },
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handlePaymentSuccess() {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Payment completed successfully! Your booking is confirmed.',
              style: TextStyle(color: Colors.white))
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
     Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) =>HomePage(),
    ));
      setState(() {
        // _registrationStep = 3; // Move to success step
        _isLoading = false;
      });
    });


    // Navigate to success page or refresh booking status
    // Navigator.pushReplacementNamed(context, '/payment-success');
  }

  void _handlePaymentFailure(String? reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_outlined,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Failed',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason ?? 'Payment was not completed successfully.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common Issues:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Insufficient M-Pesa balance\n'
                      '• Incorrect PIN entered\n'
                      '• Transaction timeout\n'
                      '• Network connectivity issues',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _initiatePayment(); // Retry payment
              },
              child: const Text('TRY AGAIN'),
            ),
          ],
        );
      },
    );
  }

  void _generateTimeSlots(DateTime date) async {
    try {
      Map<String, dynamic> data = {
        "podId": 1,
        "date":
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      };

      final request = await comms.postRequest(
        endpoint: "pods/slots",
        data: data,
      );
      if (request["rsp"]['success']) {
        List<dynamic> response = request["rsp"]['data'];
        setState(() {
          slots = response.map((item) => TimeSlot.fromJson(item)).toList();
          print("Time slots: ${slots.length}");
        });
      } else {
        setState(() {
          _timeSelectionError = "Failed to fetch time slots";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching time slots: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _timeSelectionError = "An error occurred while fetching time slots";
      });
    }
  }

  bool _validateBookingSelection() {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _bookingError = "Please enter your phone number";
      });
      return false;
    }
    if (_selectedTimeSlot == null || _selectedDuration == null) {
      setState(() {
        _bookingError = "Please select date, time, and duration";
      });
      return false;
    }
    setState(() {
      _bookingError = null;
    });
    return true;
  }

  Widget _buildTimeSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 24),

        // Duration Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pod Duration',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: _buildTimeWheelPicker(
                      label: 'Hours',
                      values: List.generate(
                        24,
                        (index) => index.toString().padLeft(2, '0'),
                      ),
                      selectedValue: _selectedHours,
                      onChanged: (value) async {
                        setState(() {
                          _selectedHours = value;
                          _selectedDuration = DurationOption(
                            label: '${_selectedHours}h ${_selectedMinutes}m',
                            duration: Duration(
                              hours: int.parse(_selectedHours),
                              minutes: int.parse(_selectedMinutes),
                            ),
                          );
                        });
                        getTarrifs();
                      },
                    ),
                  ),

                  // Minutes
                  Expanded(
                    child: _buildTimeWheelPicker(
                      label: 'Minutes',
                      values: List.generate(
                        60,
                        (index) => index.toString().padLeft(2, '0'),
                      ),
                      selectedValue: _selectedMinutes,
                      onChanged: (value) {
                        setState(() {
                          _selectedMinutes = value;
                          _selectedDuration = DurationOption(
                            label: '${_selectedHours}h ${_selectedMinutes}m',
                            duration: Duration(
                              hours: int.parse(_selectedHours),
                              minutes: int.parse(_selectedMinutes),
                            ),
                          );
                        });
                        getTarrifs();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (_timeSelectionError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _timeSelectionError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeWheelPicker({
    required String label,
    required List<String> values,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Expanded(
          child: ListWheelScrollView(
            itemExtent: 40,
            diameterRatio: 1.5,
            physics: FixedExtentScrollPhysics(),
            children:
                values.map((value) {
                  final isSelected = value == selectedValue;
                  return Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration:
                        isSelected
                            ? BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            )
                            : null,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
            onSelectedItemChanged: (index) {
              onChanged(values[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Register for Pod',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Enter your details to get a Pod code',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // Step indicator
          _buildStepIndicator(),
          SizedBox(height: 24),

          // Form steps
          if (_registrationStep == 1) _buildBookingDetailsStep(),
          if (_registrationStep == 2) _buildPaymentMethodStep(),

          SizedBox(height: 24),

          // Error message
          if (_bookingError != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _bookingError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Navigation buttons
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
              : Row(
                children: [
                  if (_registrationStep == 2)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _registrationStep = 1;
                            _bookingError = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 16),
                            SizedBox(width: 8),
                            Text('BACK'),
                          ],
                        ),
                      ),
                    ),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          _registrationStep == 1 ? _bookPod : _initiatePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _registrationStep == 1 ? 'NEXT' : 'CONFIRM PAYMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          SizedBox(height: 16),

          // Back to OTP
          TextButton(
            onPressed: widget.onBackToOTP,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Already have an OTP? Go back',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color:
                  _registrationStep == 2
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Number Input
        Text(
          'Phone Number',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: _getInputDecoration(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        SizedBox(height: 24),
        Text(
          'User Email',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: _getInputDecoration(
            label: 'User Email',
            hint: 'Enter your Email',
            icon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your Email';
            }
            return null;
          },
        ),
        SizedBox(height: 24),
        Text(
          'UserName',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _userNameController,
          decoration: _getInputDecoration(
            label: 'UserName',
            hint: 'Enter your UserName',
            icon: Icons.person_outline,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your UserName';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Date Selection
        Text(
          'Select Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Show next 14 days
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected =
                  _selectedDate.day == date.day &&
                  _selectedDate.month == date.month &&
                  _selectedDate.year == date.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null; // Reset time selection
                  });

                  _generateTimeSlots(_selectedDate);
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                        ][date.weekday % 7],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ][date.month - 1],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 12),
        Visibility(
          visible: slots.isNotEmpty,
          child: Column(
            children: [
              SizedBox(height: 24),

              // Time Slots
              Text(
                'Available Time Slots',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Container(
                height: 200,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected =
                        _selectedTimeSlot?.timeSlot == slot.timeSlot;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimeSlot = slot;
                        });
                      },

                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            slot.timeSlot,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.surface
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        _buildTimeSelectionStep(),

        // Duration Selection
        Text(
          'Session Duration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _durationOptions.map((duration) {
                final isSelected = _selectedDuration?.label == duration.label;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      duration.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        // Booking Summary
        if (_selectedTimeSlot != null && _selectedDuration != null)
          Container(
            margin: EdgeInsets.only(top: 24),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Date: ${_formatDate(_selectedDate)}'),
                Text('Start Time: ${_selectedTimeSlot!.timeSlot}'),
                Text('Duration: ${_selectedDuration!.label}'),
                Text(
                  'End Time:',
                  //  ${_formatTime(_selectedTimeSlot!.timeSlot.add(_selectedDuration!.duration))}',
                ),
                Text("Charges: kshs $Charges"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Display session details
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session ID',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          booking.sessionId,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          booking.duration,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    booking.phoneNumber,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'UserName',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    booking.username,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'User Email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    booking.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Text(
          'Select Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),

        // Payment options
        ...payments.map((method) => _buildPaymentOption(method)),

        SizedBox(height: 24),

        // Payment details form based on selected method
        if (_selectedPaymentMethod != null)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildPaymentDetailsForm(_selectedPaymentMethod!),
          ),
      ],
    );
  }

  Widget _buildPaymentOption(PaymentMethodInfo paymentInfo) {
    final isSelected = _selectedPaymentMethod == paymentInfo.method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = paymentInfo.method;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(paymentInfo.icon, color: paymentInfo.color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentInfo.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    paymentInfo.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsForm(PaymentMethod method) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider('M-Pesa Details'),
        TextFormField(
          controller: _phoneController,
          decoration: _getInputDecoration(
            label: 'M-Pesa Phone Number',
            hint: 'Enter phone number registered with M-Pesa',
            icon: Icons.phone_android,
          ),
          keyboardType: TextInputType.phone,
          enabled: true,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will receive an M-Pesa prompt on your phone to complete the payment.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    // switch (method) {
    //   // case PaymentMethod.card:
    //   //   return Column(
    //   //     crossAxisAlignment: CrossAxisAlignment.start,
    //   //     children: [
    //   //       _buildDivider('Card Details'),
    //   //       TextFormField(
    //   //         decoration: _getInputDecoration(
    //   //           label: 'Card Number',
    //   //           hint: '1234 5678 9012 3456',
    //   //           icon: Icons.credit_card,
    //   //         ),
    //   //         keyboardType: TextInputType.number,
    //   //         inputFormatters: [
    //   //           FilteringTextInputFormatter.digitsOnly,
    //   //           LengthLimitingTextInputFormatter(16),
    //   //         ],
    //   //       ),
    //   //       SizedBox(height: 16),
    //   //       Row(
    //   //         children: [
    //   //           Expanded(
    //   //             child: TextFormField(
    //   //               decoration: _getInputDecoration(
    //   //                 label: 'Expiry Date',
    //   //                 hint: 'MM/YY',
    //   //                 icon: Icons.calendar_today,
    //   //               ),
    //   //               inputFormatters: [
    //   //                 FilteringTextInputFormatter.digitsOnly,
    //   //                 LengthLimitingTextInputFormatter(4),
    //   //               ],
    //   //             ),
    //   //           ),
    //   //           SizedBox(width: 16),
    //   //           Expanded(
    //   //             child: TextFormField(
    //   //               decoration: _getInputDecoration(
    //   //                 label: 'CVV',
    //   //                 hint: '123',
    //   //                 icon: Icons.lock_outline,
    //   //               ),
    //   //               obscureText: true,
    //   //               inputFormatters: [
    //   //                 FilteringTextInputFormatter.digitsOnly,
    //   //                 LengthLimitingTextInputFormatter(3),
    //   //               ],
    //   //             ),
    //   //           ),
    //   //         ],
    //   //       ),
    //   //       SizedBox(height: 16),
    //   //       TextFormField(
    //   //         decoration: _getInputDecoration(
    //   //           label: 'Cardholder Name',
    //   //           hint: 'Name as it appears on card',
    //   //           icon: Icons.person_outline,
    //   //         ),
    //   //       ),
    //   //     ],
    //   //   );

    //   // case PaymentMethod.bank:
    //   //   return Column(
    //   //     crossAxisAlignment: CrossAxisAlignment.start,
    //   //     children: [
    //   //       _buildDivider('Bank Transfer Details'),
    //   //       DropdownButtonFormField<String>(
    //   //         decoration: _getInputDecoration(
    //   //           label: 'Select Bank',
    //   //           hint: 'Choose your bank',
    //   //           icon: Icons.account_balance,
    //   //         ),
    //   //         items:
    //   //             [
    //   //               'KCB Bank',
    //   //               'Equity Bank',
    //   //               'Standard Chartered',
    //   //               'Cooperative Bank',
    //   //               'NCBA Bank',
    //   //             ].map((String value) {
    //   //               return DropdownMenuItem<String>(
    //   //                 value: value,
    //   //                 child: Text(value),
    //   //               );
    //   //             }).toList(),
    //   //         onChanged: (value) {},
    //   //       ),
    //   //       SizedBox(height: 16),
    //   //       TextFormField(
    //   //         decoration: _getInputDecoration(
    //   //           label: 'Account Number',
    //   //           hint: 'Enter your account number',
    //   //           icon: Icons.account_balance_wallet,
    //   //         ),
    //   //         keyboardType: TextInputType.number,
    //   //       ),
    //   //     ],
    //   //   );

    //   case PaymentMethod.mpesa:
    //     return Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         _buildDivider('M-Pesa Details'),
    //         TextFormField(
    //           controller: _phoneController,
    //           decoration: _getInputDecoration(
    //             label: 'M-Pesa Phone Number',
    //             hint: 'Enter phone number registered with M-Pesa',
    //             icon: Icons.phone_android,
    //           ),
    //           keyboardType: TextInputType.phone,
    //           enabled: false,
    //         ),
    //         SizedBox(height: 16),
    //         Container(
    //           padding: EdgeInsets.all(16),
    //           decoration: BoxDecoration(
    //             color: Theme.of(context).colorScheme.primaryContainer,
    //             borderRadius: BorderRadius.circular(12),
    //             border: Border.all(
    //               color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
    //             ),
    //           ),
    //           child: Row(
    //             children: [
    //               Icon(
    //                 Icons.info_outline,
    //                 color: Theme.of(context).colorScheme.primary,
    //               ),
    //               SizedBox(width: 12),
    //               Expanded(
    //                 child: Text(
    //                   'You will receive an M-Pesa prompt on your phone to complete the payment.',
    //                   style: Theme.of(context).textTheme.bodyMedium,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     );
    // }
  }

  Widget _buildDivider(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
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
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }
}
