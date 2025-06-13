

import 'package:dogo/config/app_config.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:flutter/material.dart';

void main() {
  getPodId();
  runApp(
   PodApp());
}

class PodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dogo Pods - Find Your Perfect Workspace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: getDevice(),
    );
  }
}
