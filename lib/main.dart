import 'dart:ui';

import 'package:dogo/config/app_config.dart';
import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/data/models/PaymentMethodInfo.dart';
import 'package:dogo/features/Regestration/RegestrationForm.dart';
import 'package:dogo/features/Pod/select_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  getPodId();
  runApp(PodApp());
}

class PodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: getDevice(),
    );
  }
}

