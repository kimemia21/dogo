import 'package:dogo/config/app_config.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/features/Pod/MyPod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

void main() {
  getPodId();
  runApp(PodApp());
}

class PodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return getDevice();
  }
}
