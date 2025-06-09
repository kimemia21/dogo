import 'package:flutter/material.dart';
import 'package:dogo/core/constants/initializer.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'dart:async';

class PodSessionHomepage extends StatefulWidget {
  @override
  _PodSessionHomepageState createState() => _PodSessionHomepageState();
}

class _PodSessionHomepageState extends State<PodSessionHomepage> {
  late Timer _timer;
  bool _sessionEnded = false;
  bool _sessionValid = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _validateSession();
    // Update every second for real-time display
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _checkSessionEnd();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _validateSession() {
    final now = DateTime.now();
    final startTime = _parseTimeString(sess.sessStart);
    final endTime = _parseTimeString(sess.sessEnd);
    
    // Check if session times are valid
    if (startTime.isAfter(endTime)) {
      setState(() {
        _sessionValid = false;
        _errorMessage = 'Session start time cannot be after end time';
      });
      return;
    }
    
    // Check if session has already ended
    if (now.isAfter(endTime)) {
      setState(() {
        _sessionEnded = true;
      });
      _showSessionEndedAlert();
      return;
    }
    
    // Check if session hasn't started yet
    if (now.isBefore(startTime)) {
      setState(() {
        _sessionValid = false;
        _errorMessage = 'Session has not started yet';
      });
      return;
    }
  }

  void _checkSessionEnd() {
    if (!_sessionEnded && !_sessionValid) return;
    
    final now = DateTime.now();
    final endTime = _parseTimeString(sess.sessEnd);
    
    if (now.isAfter(endTime) && !_sessionEnded) {
      setState(() {
        _sessionEnded = true;
      });
      _showSessionEndedAlert();
    }
  }

  void _showSessionEndedAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.access_time_filled, color: Colors.red),
              SizedBox(width: 8),
              Text('Session Ended'),
            ],
          ),
          content: Text(
            'Your pod session has ended at ${sess.sessEnd.substring(0, 5)}.\n\nThank you for using our service!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back or to home screen
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Calculate elapsed time in minutes
  int getElapsedMinutes() {
    if (!_sessionValid || _sessionEnded) return 0;
    
    final now = DateTime.now();
    final startTime = _parseTimeString(sess.sessStart);
    final difference = now.difference(startTime).inMinutes;
    return difference > 0 ? difference : 0;
  }

  // Calculate remaining time in minutes
  int getRemainingMinutes() {
    if (!_sessionValid) return 0;
    if (_sessionEnded) return 0;
    
    final now = DateTime.now();
    final endTime = _parseTimeString(sess.sessEnd);
    final difference = endTime.difference(now).inMinutes;
    return difference > 0 ? difference : 0;
  }

  // Get remaining time in seconds for more precise countdown
  int getRemainingSeconds() {
    if (!_sessionValid) return 0;
    if (_sessionEnded) return 0;
    
    final now = DateTime.now();
    final endTime = _parseTimeString(sess.sessEnd);
    final difference = endTime.difference(now).inSeconds;
    return difference > 0 ? difference : 0;
  }

  // Helper method to parse time string to DateTime
  DateTime _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    var sessionTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
    
    // Handle case where session crosses midnight
    // If the parsed time is significantly in the past, it might be tomorrow
    if (sessionTime.isBefore(now.subtract(Duration(hours: 12)))) {
      sessionTime = sessionTime.add(Duration(days: 1));
    }
    
    return sessionTime;
  }

  // Get session progress percentage
  double getProgressPercentage() {
    if (!_sessionValid) return 0.0;
    if (_sessionEnded) return 1.0;
    
    final startTime = _parseTimeString(sess.sessStart);
    final endTime = _parseTimeString(sess.sessEnd);
    final now = DateTime.now();
    
    final totalDuration = endTime.difference(startTime).inMinutes;
    final elapsed = now.difference(startTime).inMinutes;
    
    if (totalDuration == 0) return 0.0;
    final progress = elapsed / totalDuration;
    return progress > 1.0 ? 1.0 : (progress < 0.0 ? 0.0 : progress);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 768;
    final isLargeScreen = screenSize.width > 600;
    
    // Show error state if session is invalid
    if (!_sessionValid) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Session Error',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 48.0 : (isTablet ? 36.0 : 24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, isLargeScreen),
              
              SizedBox(height: isDesktop ? 64 : (isTablet ? 48 : 32)),
              
              // Main content
              Expanded(
                child: isDesktop 
                  ? _buildDesktopContent(context)
                  : _buildMobileContent(context, isLargeScreen),
              ),
              
              // Footer
              _buildFooter(context, isLargeScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLargeScreen) {
    return Column(
      children: [
        Text(
          _sessionEnded ? 'Pod Session Ended' : 'Pod Session Active',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: isLargeScreen ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: _sessionEnded ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Session ID: ${sess.sessId}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLargeScreen ? 18 : 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    final remainingMinutes = getRemainingMinutes();
    final usedMinutes = getElapsedMinutes();
    final progress = getProgressPercentage();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Time cards and session info
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTimeCard(
                      context, 'Time Remaining', _formatTimeWithSeconds(getRemainingSeconds()),
                      _sessionEnded ? Colors.red : Theme.of(context).colorScheme.secondary, 
                      Icons.timer_outlined, true,
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: _buildTimeCard(
                      context, 'Time Used', _formatTime(usedMinutes),
                      Theme.of(context).colorScheme.primary, Icons.access_time, true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),
              _buildSessionInfo(context, true),
            ],
          ),
        ),
        SizedBox(width: 64),
        // Right side - Progress
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildProgressBar(context, progress, true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context, bool isLargeScreen) {
    final remainingMinutes = getRemainingMinutes();
    final usedMinutes = getElapsedMinutes();
    final progress = getProgressPercentage();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Time containers - original mobile layout
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                context, 'Time Remaining', _formatTimeWithSeconds(getRemainingSeconds()),
                _sessionEnded ? Colors.red : Theme.of(context).colorScheme.secondary, 
                Icons.timer_outlined, isLargeScreen,
              ),
            ),
            SizedBox(width: isLargeScreen ? 32 : 24),
            Expanded(
              child: _buildTimeCard(
                context, 'Time Used', _formatTime(usedMinutes),
                Theme.of(context).colorScheme.primary, Icons.access_time, isLargeScreen,
              ),
            ),
          ],
        ),
        
        SizedBox(height: isLargeScreen ? 48 : 32),
        
        // Progress bar
        _buildProgressBar(context, progress, isLargeScreen),
        
        SizedBox(height: isLargeScreen ? 32 : 24),
        
        // Session info
        _buildSessionInfo(context, isLargeScreen),
      ],
    );
  }

  Widget _buildTimeCard(BuildContext context, String label, String time, 
                       Color color, IconData icon, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isLargeScreen ? 48 : 36,
            color: color,
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: isLargeScreen ? 18 : 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLargeScreen ? 12 : 8),
          Text(
            time,
            style: TextStyle(
              fontSize: isLargeScreen ? 48 : 36,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress, bool isLargeScreen) {
    return Column(
      children: [
        Text(
          'Session Progress',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLargeScreen ? 18 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isLargeScreen ? 16 : 12),
        Container(
          height: isLargeScreen ? 16 : 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _sessionEnded ? Colors.red : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
        SizedBox(height: isLargeScreen ? 12 : 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isLargeScreen ? 16 : 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context, 'Start Time', sess.sessStart.substring(0, 5),
            Icons.play_circle_outline, isLargeScreen,
          ),
          _buildInfoItem(
            context, 'End Time', sess.sessEnd.substring(0, 5),
            Icons.stop_circle_outlined, isLargeScreen,
          ),
          _buildInfoItem(
            context, 'Duration', '${sess.sessDuration} min',
            Icons.schedule, isLargeScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, 
                       IconData icon, bool isLargeScreen) {
    return Column(
      children: [
        Icon(
          icon,
          size: isLargeScreen ? 28 : 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: isLargeScreen ? 8 : 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: isLargeScreen ? 14 : 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLargeScreen ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 16 : 12,
        horizontal: isLargeScreen ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: _sessionEnded 
          ? Colors.red.withOpacity(0.1)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _sessionEnded ? Icons.check_circle : Icons.info_outline,
            size: isLargeScreen ? 24 : 20,
            color: _sessionEnded 
              ? Colors.red
              : Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: 8),
          Text(
            _sessionEnded 
              ? 'Session ended at ${sess.sessEnd.substring(0, 5)}'
              : 'Session will end automatically at ${sess.sessEnd.substring(0, 5)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isLargeScreen ? 16 : 14,
              color: _sessionEnded 
                ? Colors.red
                : Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
    } else {
      return '${mins.toString().padLeft(2, '0')}m';
    }
  }

  String _formatTimeWithSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00';
    
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}