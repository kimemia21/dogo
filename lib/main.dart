

import 'package:dogo/config/app_config.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/features/Pod/MyPod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
      home:   BookingConfirmedPage(
      podName: 'TechHub Nairobi',
      podType: 'Solo Pod',
      location: 'Westlands, Nairobi',
      startDate: DateTime(2024, 3, 15),
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
      podPosition: LatLng(-1.2921, 36.8219),
      duration: '8 hours',
      price: 'KSh 4,000',
      amenities: ['WiFi', 'Coffee', 'Meeting Rooms', 'Parking'],
    ),
      
      // getDevice(),
    );
  }
}
