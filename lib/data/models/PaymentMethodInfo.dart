import 'package:flutter/material.dart';

enum PaymentMethod { card, bank, mpesa }

class PaymentMethodInfo {
  final int id;
  final String title;
  final String description;
  final int status;
  final IconData icon;
  final Color color;
  final PaymentMethod method;
  
  PaymentMethodInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
    required this.color,
    required this.method,
  });

  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      icon: _getIconForTitle(json['title']),
      color: _getColorForTitle(json['title']),
      method: _getPaymentMethod(json['title']),
    );
  }
}

PaymentMethod _getPaymentMethod(String title) {
  switch (title.toLowerCase()) {
    case 'm-pesa':
      return PaymentMethod.mpesa;
    case 'credit/debit card':
      return PaymentMethod.card;
    case 'bank transfer':
      return PaymentMethod.bank;
    default:
      return PaymentMethod.card;
  }
}

IconData _getIconForTitle(String title) {
  switch (title.toLowerCase()) {
    case 'm-pesa':
      return Icons.phone_android;
    case 'credit/debit card':
      return Icons.credit_card;
    case 'bank transfer':
      return Icons.account_balance;
    default:
      return Icons.payment;
  }
}

Color _getColorForTitle(String title) {
  switch (title.toLowerCase()) {
    case 'm-pesa':
      return Colors.deepPurple;
    case 'credit/debit card':
      return Colors.blue;
    case 'bank transfer':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

class PaymentMethodHelper {
  static List<PaymentMethodInfo> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PaymentMethodInfo.fromJson(json)).toList();
  }
}