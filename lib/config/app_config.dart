import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/features/Pod/Maps.dart';
import 'package:dogo/features/Pod/otpPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define your routes
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>  LandingPage(wasBooked: false),
    ),
    GoRoute(
      path: '/pod/:podId',
      builder: (context, state) {
        final podIdStr = state.pathParameters['podId'];
        final podId = int.tryParse(podIdStr ?? '');
        
        if (podId != null) {
          return OTPForm();
        } else {
          return  LandingPage(wasBooked: false);
        }
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OTPForm(),
    ),
  ],
  errorBuilder: (context, state) =>  LandingPage(wasBooked: false),
);

Widget getDevice() {
  return MaterialApp.router(
    theme: AppTheme.lightTheme,
    routerConfig: _router,
  );
}