import 'dart:ui';

import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/data/models/Session.dart';
import 'package:dogo/features/Pod/otpPage.dart';
import 'package:dogo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

void showPaymentSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;
          bool isMediumScreen = constraints.maxWidth > 400;

          double dialogWidth =
              isLargeScreen
                  ? 400
                  : (isMediumScreen ? 350 : constraints.maxWidth * 0.9);
          double padding = isLargeScreen ? 32 : (isMediumScreen ? 24 : 20);
          double iconSize = isLargeScreen ? 80 : (isMediumScreen ? 70 : 60);
          double iconInnerSize =
              isLargeScreen ? 40 : (isMediumScreen ? 35 : 30);
          double titleFontSize =
              isLargeScreen ? 22 : (isMediumScreen ? 20 : 18);
          double bodyFontSize = isLargeScreen ? 16 : (isMediumScreen ? 15 : 14);
          double buttonHeight = isLargeScreen ? 56 : (isMediumScreen ? 52 : 48);
          double spacing = isLargeScreen ? 24 : (isMediumScreen ? 20 : 16);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: dialogWidth,
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: iconInnerSize,
                    ),
                  ),

                  SizedBox(height: spacing),

                  Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Your pod has been booked successfully. You will receive a confirmation OTP via SMS shortly.\n\nYou are being redirected to the OTP page...',
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: spacing + 8),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close success dialog

                        navigateToOTPScreen(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontSize: bodyFontSize + 2,
                          fontWeight: FontWeight.bold,
                        ),
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
}

void showMpesaPaymentConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Move state variables outside the builder function
      bool isLoading = false;
      String statusMessage = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isLargeScreen = constraints.maxWidth > 600;
                  bool isMediumScreen = constraints.maxWidth > 400;

                  double dialogWidth =
                      isLargeScreen
                          ? 400
                          : (isMediumScreen ? 350 : constraints.maxWidth * 0.9);
                  double padding =
                      isLargeScreen ? 32 : (isMediumScreen ? 24 : 20);
                  double iconSize =
                      isLargeScreen ? 80 : (isMediumScreen ? 70 : 60);
                  double iconInnerSize =
                      isLargeScreen ? 40 : (isMediumScreen ? 35 : 30);
                  double titleFontSize =
                      isLargeScreen ? 22 : (isMediumScreen ? 20 : 18);
                  double bodyFontSize =
                      isLargeScreen ? 16 : (isMediumScreen ? 15 : 14);
                  double buttonHeight =
                      isLargeScreen ? 56 : (isMediumScreen ? 52 : 48);
                  double spacing =
                      isLargeScreen ? 24 : (isMediumScreen ? 20 : 16);

                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    child: Container(
                      width: dialogWidth,
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child:
                                isLoading
                                    ? CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    )
                                    : Icon(
                                      Icons.payment,
                                      color: Colors.white,
                                      size: iconInnerSize,
                                    ),
                          ),

                          SizedBox(height: spacing),

                          Text(
                            isLoading ? 'Verifying Payment' : 'M-Pesa Payment',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 12),

                          Text(
                            isLoading
                                ? 'Please wait while we verify your payment...'
                                : 'Please check your phone for a notification and enter your PIN to complete the payment.',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          if (statusMessage.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Text(
                              statusMessage,
                              style: TextStyle(
                                fontSize: bodyFontSize - 1,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          if (!isLoading) ...[
                            SizedBox(height: 16),
                            Text(
                              'Have you completed the payment on your phone?',
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          SizedBox(height: spacing + 8),

                          if (!isLoading)
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close dialog
                                        // Handle payment cancellation or retry logic here
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                        side: BorderSide(
                                          color: Colors.grey[400]!,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Not Yet',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  child: SizedBox(
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                          statusMessage =
                                              'Verifying your payment...';
                                        });

                                        try {
                                          final response = await comms.getRequests(
                                            endpoint:
                                                "pod-sessions/${booking.sessionId}/status",
                                          );

                                          await Future.delayed(
                                            Duration(seconds: 2),
                                          );

                                          if (response["rsp"]["success"] &&
                                              response["rsp"]["data"]["sessPaymentStatus"] ==
                                                  "paid") {
                                            sess = Session.fromJson(
                                              response["rsp"]["data"],
                                            );
                                            setState(() {
                                              isLoading = false;
                                              statusMessage = 'Success';
                                            });

                                            Navigator.of(context).pop();
                                            showPaymentSuccessDialog(context);
                                          } else if (response["rsp"]["success"] &&
                                              response["rsp"]["data"]["sessPaymentStatus"] ==
                                                  "pending") {
                                            setState(() {
                                              isLoading = false;
                                              statusMessage =
                                                  'Please enter your M-PESA PIN to complete payment.';
                                            });
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                              statusMessage =
                                                  'Payments Failed Try Again.';
                                            });
                                          }
                                        } catch (e) {
                                          setState(() {
                                            isLoading = false;
                                            statusMessage =
                                                'Error verifying payment. Please try again.';
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 3,
                                        shadowColor: Colors.green.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      child: Text(
                                        'Yes, Paid',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}

// You'll need to implement this function based on your payment verification logic
// Future<bool> verifyMpesaPayment() async {
//   // Replace with your actual M-Pesa payment verification API call
//   // This is just a placeholder that randomly returns true/false
//   await Future.delayed(Duration(seconds: 1));
//   return DateTime.now().millisecond % 2 == 0;
// }

// Keep your original success dialog for when payment is confirmed
void showMpesaConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 600;
              bool isMediumScreen = constraints.maxWidth > 400;

              double dialogWidth =
                  isLargeScreen
                      ? 400
                      : (isMediumScreen ? 350 : constraints.maxWidth * 0.9);
              double padding = isLargeScreen ? 32 : (isMediumScreen ? 24 : 20);
              double iconSize = isLargeScreen ? 80 : (isMediumScreen ? 70 : 60);
              double iconInnerSize =
                  isLargeScreen ? 40 : (isMediumScreen ? 35 : 30);
              double titleFontSize =
                  isLargeScreen ? 22 : (isMediumScreen ? 20 : 18);
              double bodyFontSize =
                  isLargeScreen ? 16 : (isMediumScreen ? 15 : 14);
              double buttonHeight =
                  isLargeScreen ? 56 : (isMediumScreen ? 52 : 48);
              double spacing = isLargeScreen ? 24 : (isMediumScreen ? 20 : 16);

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: dialogWidth,
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: iconInnerSize,
                        ),
                      ),

                      SizedBox(height: spacing),

                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Your pod has been booked successfully. You will receive a confirmation SMS shortly.',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: spacing + 8),

                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close success dialog
                            Navigator.of(
                              context,
                            ).pop(); // Go back to previous screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontSize: bodyFontSize + 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
