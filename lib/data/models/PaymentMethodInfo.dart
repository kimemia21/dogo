import 'package:flutter/material.dart';

enum PaymentMethod {
  card,
  bank,
  mpesa,
}

class PaymentMethodInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  
  PaymentMethodInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PaymentMethodHelper {
  static PaymentMethodInfo getPaymentMethodInfo(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return PaymentMethodInfo(
          name: 'Credit/Debit Card',
          description: 'Pay securely with your card',
          icon: Icons.credit_card,
          color: Colors.blue,
        );
      case PaymentMethod.bank:
        return PaymentMethodInfo(
          name: 'Bank Transfer',
          description: 'Pay directly from your bank account',
          icon: Icons.account_balance,
          color: Colors.green,
        );
      case PaymentMethod.mpesa:
        return PaymentMethodInfo(
          name: 'M-Pesa',
          description: 'Pay using M-Pesa mobile money',
          icon: Icons.phone_android,
          color: Colors.deepPurple,
        );
    }
  }
}