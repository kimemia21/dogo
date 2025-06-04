// Future<bool?> _showPaymentConfirmationDialog(String phoneNumber) async {
//     return await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         final TextEditingController phoneEditController = TextEditingController(
//           text: phoneNumber,
//         );

//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primaryContainer,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.account_balance_wallet,
//                     color: Theme.of(context).colorScheme.primary,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Confirm Payment',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'M-Pesa Transaction',
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           content: Container(
//             width: MediaQuery.of(context).size.width * 0.75,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Payment summary card
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.surfaceVariant.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.outline.withOpacity(0.2),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Amount',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           Text(
//                             'KSh booking..toStringAsFixed(2)}',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Service',
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           Text(
//                             booking.sessionId,
//                             style: Theme.of(context).textTheme.bodyMedium
//                                 ?.copyWith(fontWeight: FontWeight.w500),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Phone number input
//                 TextField(
//                   controller: phoneEditController,
//                   decoration: InputDecoration(
//                     labelText: 'M-Pesa Phone Number',
//                     hintText: '0712345678 or +254712345678',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     prefixIcon: Icon(Icons.phone),
//                     //  Container(
//                     //   padding: const EdgeInsets.all(12),
//                     //   child: Image.network(
//                     //     'https://play-lh.googleusercontent.com/bRZF74-13jknePwUd1xam5ZCSdAJVuI_wqtkrisBgu7EEh1jobh2boZihlk-4ikY_S3V', // Add M-Pesa logo
//                     //     width: 24,
//                     //     height: 24,
//                     //   ),
//                     // ),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.contacts),
//                       onPressed: () {
//                         // TODO: Implement contact picker
//                       },
//                     ),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Information container
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(
//                       context,
//                     ).colorScheme.primaryContainer.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.primary.withOpacity(0.2),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Theme.of(context).colorScheme.primary,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Payment Process',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '• You will receive an M-Pesa STK push prompt\n'
//                         '• Enter your M-Pesa PIN to authorize payment\n'
//                         '• Payment confirmation will be sent via SMS\n'
//                         '• Transaction may take up to 2 minutes to process',
//                         style: Theme.of(
//                           context,
//                         ).textTheme.bodySmall?.copyWith(height: 1.4),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Security notice
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.security,
//                       color: Theme.of(context).colorScheme.tertiary,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Secured by M-Pesa. Your transaction is protected.',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurfaceVariant,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text(
//                 'CANCEL',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 elevation: 2,
//               ),
//               icon: const Icon(Icons.payment, size: 18),
//               label: const Text(
//                 'PAY NOW',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               onPressed: () {
//                 final phone = phoneEditController.text.trim();

//                 Navigator.of(context).pop(true);
//                 // }
//                 //  else {
//                 //   _showErrorSnackBar('Please enter a valid phone number');
//                 // }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _initiatePayment() async {
//     if (_selectedPaymentMethod != PaymentMethod.mpesa) return;

//     String phoneNumber = _phoneController.text.trim();

//     // Validate phone number format
//     // if (!_isValidKenyanPhoneNumber(phoneNumber)) {
//     //   _showErrorSnackBar('Please enter a valid Kenyan phone number');
//     //   return;
//     // }

//     // Show professional confirmation dialog
//     final bool? confirmed = await _showPaymentConfirmationDialog(phoneNumber);
//     if (confirmed != true) return;

//     // Show loading state with countdown
//     _showLoadingDialogWithTimer();

//     try {
//       final response = await comms.postRequest(
//         endpoint: "pods/pay",
//         data: {
//           "sessionId": booking.sessionId,
//           "payMethod": 1, // M-Pesa payment method
//           "mpesaNo": phoneNumber,
//           "cardName": "",
//         },
//       );

//       if (response["rsp"]?['success'] == true) {
//         _startPaymentStatusCheck();
//       } else {
//         Navigator.of(context).pop(); // Close loading dialog
//         final errorMessage =
//             response["rsp"]?['message'] ?? 'Payment initiation failed';
//         await _showErrorDialog('Payment Failed', errorMessage);
//       }
//     } catch (e) {
//       Navigator.of(context).pop(); // Close loading dialog
//       await _showErrorDialog(
//         'Connection Error',
//         'Unable to connect to payment service. Please check your internet connection and try again.',
//       );

//       // Log error for debugging
//       debugPrint('M-Pesa payment error: ${e.toString()}');
//     }
//   }

//   void _showLoadingDialogWithTimer() {
//     int countdown = 20;
//     bool dialogClosed = false;
//     String currentMessage = 'Initiating Payment...';
//     String currentSubMessage = 'Please wait while we process your request';

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               content: Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 20),
//                     Text(
//                       currentMessage,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       currentSubMessage,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primaryContainer.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         'Timeout in ${countdown}s',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context).colorScheme.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );

//     // Start countdown timer
//     Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (dialogClosed) {
//         timer.cancel();
//         return;
//       }

//       countdown--;

//       if (countdown <= 0) {
//         timer.cancel();
//         if (!dialogClosed) {
//           dialogClosed = true;
//           Navigator.of(context).pop(); // Close loading dialog
//           _showErrorDialog(
//             'Payment Timeout',
//             'Payment request timed out. Please try again.',
//           );
//         }
//         return;
//       }

//       // Update the dialog if it's still showing
//       if (Navigator.of(context).canPop()) {
//         // Find the dialog and update it
//         // Note: This is a simplified approach. In production, you might want to use a more robust state management solution.
//       }
//     });
//   }

//   void _startPaymentStatusCheck() {
//     int checkCount = 0;
//     const maxChecks = 60; // 5 minutes (5 second intervals)

//     Timer.periodic(const Duration(seconds: 10), (timer) async {
//       try {
//         final statusResponse = await comms.getRequests(
//           endpoint: "pod-sessions/${booking.sessionId}/status",
//         );

//         final paymentStatus =
//             statusResponse["rsp"]["data"]['sessPaymentStatus'];

//         if (paymentStatus == 'paid') {
//           timer.cancel();
//           Navigator.of(context).pop(); // Close loading dialog
//           await _showSuccessDialog();
//           _handlePaymentSuccess();
//         } else if (paymentStatus == 'failed') {
//           timer.cancel();
//           Navigator.of(context).pop(); // Close loading dialog
//           _handlePaymentFailure(statusResponse["rsp"]?['message']);
//         } else if (paymentStatus == 'pending') {
//           // Show PIN entry prompt if it's the first pending status
//           if (checkCount == 0) {
//             _showPinEntryPrompt();
//           }
//         }

//         checkCount++;

//         // Cancel after maximum checks
//         if (checkCount >= maxChecks) {
//           timer.cancel();
//           Navigator.of(context).pop(); // Close loading dialog
//           _handlePaymentFailure(
//             'Payment verification timed out. Please check your M-Pesa messages.',
//           );
//         }
//       } catch (e) {
//         debugPrint('Payment status check error: $e');
//         checkCount++;

//         if (checkCount >= maxChecks) {
//           timer.cancel();
//           Navigator.of(context).pop(); // Close loading dialog
//           _handlePaymentFailure(
//             'Unable to verify payment status. Please check your M-Pesa messages.',
//           );
//         }
//       }
//     });
//   }

//   void _showPinEntryPrompt() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.phone_android,
//                 color: Colors.orange,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'M-Pesa PIN Required',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     'Check your phone and enter PIN within 2 minutes',
//                     style: TextStyle(fontSize: 12, color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.orange,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   Future<void> _showSuccessDialog() async {
//     return await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           content: Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 48,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Payment Successful!',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Your M-Pesa payment has been processed successfully. You will receive a confirmation SMS shortly.',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('CONTINUE'),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _showErrorDialog(String title, String message) async {
//     return await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(
//                     'OK',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     _initiatePayment(); // Retry payment
//                   },
//                   child: const Text('RETRY'),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _handlePaymentSuccess() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             SizedBox(width: 8),
//             Text(
//               'Payment completed successfully! Your booking is confirmed.',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//       setState(() {
//         // _registrationStep = 3; // Move to success step
//         _isLoading = false;
//       });
//     });

//     // Navigate to success page or refresh booking status
//     // Navigator.pushReplacementNamed(context, '/payment-success');
//   }

//   void _handlePaymentFailure(String? reason) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.payment_outlined,
//                   color: Colors.red,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Payment Failed',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 reason ?? 'Payment was not completed successfully.',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.surfaceVariant.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Common Issues:',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '• Insufficient M-Pesa balance\n'
//                       '• Incorrect PIN entered\n'
//                       '• Transaction timeout\n'
//                       '• Network connectivity issues',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'CANCEL',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _initiatePayment(); // Retry payment
//               },
//               child: const Text('TRY AGAIN'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _generateTimeSlots(DateTime date) async {
//     try {
//       Map<String, dynamic> data = {
//         "podId": 1,
//         "date":
//             "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
//       };

//       final request = await comms.postRequest(
//         endpoint: "pods/slots",
//         data: data,
//       );
//       if (request["rsp"]['success']) {
//         List<dynamic> response = request["rsp"]['data'];
//         setState(() {
//           slots = response.map((item) => TimeSlot.fromJson(item)).toList();
//           print("Time slots: ${slots.length}");
//         });
//       } else {
//         setState(() {
//           _timeSelectionError = "Failed to fetch time slots";
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error fetching time slots: ${e.toString()}'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       setState(() {
//         _timeSelectionError = "An error occurred while fetching time slots";
//       });
//     }
//   }