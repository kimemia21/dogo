import 'dart:ui';

import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/features/Regestration/Alerts.dart';
import 'package:flutter/material.dart';

void showMpesaPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(
      0.7,
    ), // Add blur effect to background

    builder: (BuildContext context) {
        bool isLoading = false;
          String? errorMessage;
          final TextEditingController phoneController = TextEditingController(
            text: booking.phoneNumber,
          );
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> processMpesaPayment(
            BuildContext context,
            StateSetter setState,
            String phoneNumber,
            String charges,
          ) async {
            try {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              final response = await comms.postRequest(
                endpoint: "pods/pay",
                data: {
                  "sessionId": booking.sessionId,
                  "payMethod": 1,
                  "mpesaNo": booking.phoneNumber,
                  "cardName": "",
                },
              );

              if (response["rsp"]['success']) {
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  isLoading = false;
                  errorMessage = null;
                });
                // Navigator.of(context).pop();
                showMpesaPaymentConfirmationDialog(context);
              } else {
                setState(() {
                  isLoading = false;
                  errorMessage =
                      "Payment failed: ${response['message']}";
                });
              }
            } catch (e) {
              setState(() {
                isLoading = false;
                errorMessage = "Payment failed: ${e.toString()}";
              });
            }
          }

          // Responsive design helper
          Widget buildResponsiveDialog() {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we're on a large screen
                bool isLargeScreen = constraints.maxWidth > 600;
                bool isMediumScreen = constraints.maxWidth > 400;

                // Responsive values
                double dialogWidth =
                    isLargeScreen
                        ? 450
                        : (isMediumScreen ? 380 : constraints.maxWidth * 0.9);
                double horizontalPadding =
                    isLargeScreen ? 32 : (isMediumScreen ? 24 : 16);
                double verticalPadding =
                    isLargeScreen ? 32 : (isMediumScreen ? 24 : 20);
                double iconSize =
                    isLargeScreen ? 80 : (isMediumScreen ? 70 : 60);
                double imageSize =
                    isLargeScreen ? 100 : (isMediumScreen ? 80 : 70);
                double iconInnerSize =
                    isLargeScreen ? 40 : (isMediumScreen ? 35 : 30);
                double titleFontSize =
                    isLargeScreen ? 24 : (isMediumScreen ? 22 : 20);
                double bodyFontSize =
                    isLargeScreen ? 16 : (isMediumScreen ? 15 : 14);
                double buttonHeight =
                    isLargeScreen ? 56 : (isMediumScreen ? 52 : 48);
                double spacing =
                    isLargeScreen ? 24 : (isMediumScreen ? 20 : 16);
                double smallSpacing =
                    isLargeScreen ? 16 : (isMediumScreen ? 14 : 12);

                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: dialogWidth,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      // gradient: LinearGradient(
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   colors: [
                      //     Colors.green.shade50,
                      //     Colors.white,
                      //   ],
                      // ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // M-Pesa Logo/Icon
                          Container(
                            width: imageSize,
                            height: imageSize,

                            child: Image.asset("assets/images/mpesa_logo.png"),
                          ),

                          SizedBox(height: spacing),

                          // Title
                          Text(
                            'M-Pesa Payment',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: smallSpacing),

                          // Error Message (if any)
                          if (errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(smallSpacing),
                              margin: EdgeInsets.only(bottom: smallSpacing),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: bodyFontSize + 4,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: TextStyle(
                                        fontSize: bodyFontSize - 1,
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Payment Details Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(smallSpacing + 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Phone Number
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Phone Number:',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: TextField(
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                        fontSize: bodyFontSize,
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                Divider(color: Colors.green.shade200),

                                SizedBox(height: 12),

                                // Amount
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Amount:',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        booking.charges,
                                        style: TextStyle(
                                          fontSize: bodyFontSize + 2,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacing),

                          // Instructions
                          Container(
                            padding: EdgeInsets.all(smallSpacing),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: bodyFontSize + 4,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'You will receive a notification on your phone to complete the payment.',
                                    style: TextStyle(
                                      fontSize: bodyFontSize - 1,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: spacing + 8),

                          // Action Buttons
                          isLargeScreen || isMediumScreen
                              ? Row(
                                children: [
                                  // Cancel Button
                                  Expanded(
                                    child: SizedBox(
                                      height: buttonHeight,
                                      child: OutlinedButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () =>
                                                    Navigator.of(context).pop(),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 16),

                                  // Pay Button
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: buttonHeight,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () => processMpesaPayment(
                                                  context,
                                                  setState,
                                                  phoneController.text,
                                                  booking.charges,
                                                ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade600,
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
                                        child:
                                            isLoading
                                                ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.payment,
                                                      size: bodyFontSize + 4,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Pay Now',
                                                      style: TextStyle(
                                                        fontSize: bodyFontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                children: [
                                  // Pay Button (full width on small screens)
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading
                                              ? null
                                              : () => processMpesaPayment(
                                                context,
                                                setState,
                                                phoneController.text,
                                                booking.charges,
                                              ),
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
                                      child:
                                          isLoading
                                              ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.payment,
                                                    size: bodyFontSize + 4,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Pay Now',
                                                    style: TextStyle(
                                                      fontSize: bodyFontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  // Cancel Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: OutlinedButton(
                                      onPressed:
                                          isLoading
                                              ? null
                                              : () =>
                                                  Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.1), 
              child: Center(child: buildResponsiveDialog()),
            ),
          );
        },
      );
    },
  );
}

// Success dialog
