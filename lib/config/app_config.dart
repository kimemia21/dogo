import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/data/models/Pod.dart';
import 'package:dogo/features/Pod/Homepage.dart';
import 'package:dogo/features/Pod/Maps.dart';
import 'package:dogo/features/Pod/otpPage.dart';
import 'package:dogo/main.dart';
import 'package:dogo/features/Pod/select_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

// URL helper class
class UrlHelper {
  static int? _cachedPodId;
  
  // Get pod ID from URL with caching
  static int? getPodId() {
    if (_cachedPodId != null) return _cachedPodId;
    
    if (!kIsWeb) return null;
    
    try {
      final uri = Uri.parse(web.window.location.href);
      final segments = uri.pathSegments;
      _cachedPodId = segments.isNotEmpty ? int.tryParse(segments.last) : null;
      return _cachedPodId;
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      return null;
    }
  }
  
  // Clear cache
  static void clearCache() {
    _cachedPodId = null;
  }
}

// Main responsive widget
class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const mobileBreakpoint = 600.0;
        final isMobile = screenWidth < mobileBreakpoint;
        final podId = UrlHelper.getPodId();
        
        // Debug info (remove in production)
        debugPrint('Screen width: $screenWidth');
        debugPrint('Is mobile: $isMobile');
        debugPrint('Pod ID: $podId');
        
        if (isMobile) {
          // Mobile: ALWAYS show LandingPage (regardless of URL)
          return LandingPage(
          
            wasBooked: false,
          );
        } else {
          // Desktop: ALWAYS show OTPForm (regardless of URL)
          return OTPForm(
            key: const ValueKey('desktop_otp'),
          );
        }
      },
    );
  }
}

// Main method
Widget getDevice() {
  return MaterialApp(
    title: 'Dogo App',
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    home: const ResponsiveHomePage(),
    builder: (context, child) {
      // Ensure consistent text scaling
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: child!,
      );
    },
  );
}
