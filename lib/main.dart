// pubspec.yaml dependencies needed:
// dependencies:
//   flutter:
//     sdk: flutter
//   go_router: ^14.2.7
//   shared_preferences: ^2.2.3

import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppTheme.dart';
import 'package:dogo/features/Pod/Maps.dart';
import 'package:dogo/features/Pod/otpPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dogo – Small and smart solutions for optimum privacy, comfort, productivity and focus',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
// Define your routes - FIXED ORDER
final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: <RouteBase>[

    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(wasBooked: false),
    ),
    GoRoute(
      path: '/pod/:podId',
      builder: (BuildContext context, GoRouterState state) {
        final podId = state.pathParameters['podId']!;
        debugPrint("Navigating to podId: $podId");
        return OTPForm();
      },
    ),
    // Wildcard route LAST (acts as catch-all for unmatched routes)
    GoRoute(
      path: '*',
      builder: (context, state) => NotFoundPage(), // Changed to NotFoundPage
    ),
  ],
  errorBuilder: (context, state) => NotFoundPage(),
);


// Base page widget with URL utilities
abstract class BasePage extends StatefulWidget {
  @override
  BasePageState createState();
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUrl();
    _saveCurrentUrl();
  }

  // Get current URL
  void _getCurrentUrl() {
    final router = GoRouter.of(context);
    setState(() {
      currentUrl = router.routeInformationProvider.value.uri.toString();
    });
  }

  // Save URL to local storage
  Future<void> _saveCurrentUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final fullUrl = Uri.base.toString();
    await prefs.setString('last_visited_url', fullUrl);
    await prefs.setString('last_route', currentUrl);
  }

  // Get saved URL
  Future<String?> getSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_visited_url');
  }

  // Navigate to a specific route
  void navigateToRoute(String route) {
    context.go(route);
  }

  // Navigate with parameters
  void navigateWithParams(String route, Map<String, String> params) {
    final uri = Uri(path: route, queryParameters: params);
    context.go(uri.toString());
  }
}

// LandingPage and OTPForm are imported from your existing files
// Add these only if you need URL functionality in your custom pages

// 404 Not Found Page
class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Not Found'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404',
              style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
            Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}