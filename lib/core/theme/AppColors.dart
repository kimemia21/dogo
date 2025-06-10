import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - Dogo's signature magenta/pink
  static const Color primary = Color(0xFFE91E63); // Bright magenta (Dogo's main color)
  static const Color primaryDark = Color(0xFFAD1457); // Darker magenta
  static const Color primaryLight = Color(0xFFF48FB1); // Lighter magenta
  
  // Secondary colors - Charcoal/Dark Gray from footer
  static const Color secondary = Color(0xFF424242); // Dark charcoal gray
  static const Color secondaryDark = Color(0xFF212121); // Darker charcoal
  static const Color secondaryLight = Color(0xFF616161); // Lighter charcoal
  
  // Background colors - Clean whites and grays from website
  static const Color background = Color(0xFFFAFAFA); // Very light gray background
  static const Color backgroundDark = Color(0xFF212121); // Dark charcoal background
  static const Color surface = Color(0xFFFFFFFF); // Pure white surface
  static const Color surfaceDark = Color(0xFF424242); // Dark surface
  
  // Text colors - Following website's text hierarchy
  static const Color textPrimary = Color(0xFF212121); // Dark charcoal for primary text
  static const Color textSecondary = Color(0xFF757575); // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray for tertiary text
  static const Color textLight = Color(0xFFBDBDBD); // Very light gray
  
  // Text colors for dark theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text on dark
  static const Color textSecondaryDark = Color(0xFFE0E0E0); // Light gray on dark
  static const Color textTertiaryDark = Color(0xFFBDBDBD); // Medium light gray on dark
  
  // Border colors - Subtle grays
  static const Color border = Color(0xFFE0E0E0); // Light gray border
  static const Color borderLight = Color(0xFFF5F5F5); // Very light border
  static const Color borderDark = Color(0xFF616161); // Dark border
  
  // Status colors - Keeping functional colors while matching theme
  static const Color success = Color(0xFF4CAF50); // Green success
  static const Color successLight = Color(0xFFC8E6C9); // Light green
  static const Color error = Color(0xFFF44336); // Red error
  static const Color errorLight = Color(0xFFFFCDD2); // Light red
  static const Color warning = Color(0xFFFF9800); // Orange warning
  static const Color warningLight = Color(0xFFFFE0B2); // Light orange
  static const Color info = Color(0xFFE91E63); // Magenta info (matches primary)
  static const Color infoLight = Color(0xFFF8BBD9); // Light magenta
  
  // Neutral colors - Dogo's gray palette
  static const Color neutral50 = Color(0xFFFAFAFA); // Lightest gray
  static const Color neutral100 = Color(0xFFF5F5F5); // Very light gray
  static const Color neutral200 = Color(0xFFEEEEEE); // Light gray
  static const Color neutral300 = Color(0xFFE0E0E0); // Medium light gray
  static const Color neutral400 = Color(0xFFBDBDBD); // Medium gray
  static const Color neutral500 = Color(0xFF9E9E9E); // Medium gray
  static const Color neutral600 = Color(0xFF757575); // Medium dark gray
  static const Color neutral700 = Color(0xFF616161); // Dark gray
  static const Color neutral800 = Color(0xFF424242); // Very dark gray
  static const Color neutral900 = Color(0xFF212121); // Darkest gray
  
  // Accent colors - Dogo's magenta variations
  static const Color accent = Color(0xFFE91E63); // Main magenta accent
  static const Color accentLight = Color(0xFFF48FB1); // Light magenta accent
  static const Color accentDark = Color(0xFFAD1457); // Dark magenta accent
  
  // Dogo specific brand colors
  static const Color dogoMagenta = Color(0xFFE91E63); // Main brand color
  static const Color dogoCharcoal = Color(0xFF424242); // Footer/dark sections
  static const Color dogoLightGray = Color(0xFFF5F5F5); // Background sections
  static const Color dogoWhite = Color(0xFFFFFFFF); // Clean white areas
}