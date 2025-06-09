import 'package:dogo/data/models/Pod_sessions.dart';
import 'package:dogo/data/services/localHost.dart';
import 'package:flutter/material.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'dart:async';

// Updated PodSession class

class PodSessionHomepage extends StatefulWidget {
  final PodSession session;

  const PodSessionHomepage({super.key, required this.session});

  @override
  _PodSessionHomepageState createState() => _PodSessionHomepageState();
}

class _PodSessionHomepageState extends State<PodSessionHomepage> {
  late Timer _timer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _validateSession();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _validateSession() {
    if (!widget.session.isValid) {
      setState(() {
        _errorMessage = 'Session is invalid';
      });
      return;
    }

    if (!widget.session.hasStarted) {
      setState(() {
        _errorMessage = 'Session has not started yet';
      });
      return;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (widget.session.isExpired) {
            _showSessionEndedAlert();
          }
        });
      }
    });
  }

  void _showSessionEndedAlert() {
    if (!mounted) return;

    Localhost.postToLocalhost("api/start", {});

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
            'Your pod session has ended at ${_formatTime24Hour(widget.session.timeOut)}.\n\nThank you for using our service!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth > 1200;
        final isTablet = screenWidth > 768;
        final isMobile = screenWidth <= 768;

        // Show error state if session is invalid
        if (!widget.session.isValid || _errorMessage.isNotEmpty) {
          return _buildErrorState();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(_getPadding(screenWidth)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(screenWidth),
                  SizedBox(height: _getSpacing(screenWidth, large: true)),

                  if (isDesktop)
                    _buildDesktopLayout(screenWidth)
                  else if (isTablet)
                    _buildTabletLayout(screenWidth)
                  else
                    _buildMobileLayout(screenWidth),

                  SizedBox(height: _getSpacing(screenWidth)),
                  _buildFooter(screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                  _errorMessage.isEmpty
                      ? 'Unknown error occurred'
                      : _errorMessage,
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

  Widget _buildHeader(double screenWidth) {
    final isLarge = screenWidth > 600;

    return Column(
      children: [
        Text(
          widget.session.isExpired
              ? 'Pod Session Ended'
              : widget.session.isActive
              ? 'Pod Session Active'
              : 'Pod Session Waiting',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: isLarge ? 36 : 28,
            fontWeight: FontWeight.bold,
            color:
                widget.session.isExpired
                    ? Colors.red
                    : widget.session.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Session ID: ${widget.session.sessId}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLarge ? 18 : 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTimeCard(
                      'Time Remaining',
                      _formatDurationWithSeconds(widget.session.timeRemaining),
                      widget.session.isExpired
                          ? Colors.red
                          : Theme.of(context).colorScheme.secondary,
                      Icons.timer_outlined,
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: _buildTimeCard(
                      'Time Used',
                      _formatDuration(widget.session.timeElapsed),
                      Theme.of(context).colorScheme.primary,
                      Icons.access_time,
                      screenWidth,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),
              _buildSessionInfo(screenWidth),
            ],
          ),
        ),
        SizedBox(width: 64),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildProgressBar(screenWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(double screenWidth) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                'Time Remaining',
                _formatDurationWithSeconds(widget.session.timeRemaining),
                widget.session.isExpired
                    ? Colors.red
                    : Theme.of(context).colorScheme.secondary,
                Icons.timer_outlined,
                screenWidth,
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: _buildTimeCard(
                'Time Used',
                _formatDuration(widget.session.timeElapsed),
                Theme.of(context).colorScheme.primary,
                Icons.access_time,
                screenWidth,
              ),
            ),
          ],
        ),
        SizedBox(height: 32),
        _buildProgressBar(screenWidth),
        SizedBox(height: 32),
        _buildSessionInfo(screenWidth),
      ],
    );
  }

  Widget _buildMobileLayout(double screenWidth) {
    return Column(
      children: [
        _buildTimeCard(
          'Time Remaining',
          _formatDurationWithSeconds(widget.session.timeRemaining),
          widget.session.isExpired
              ? Colors.red
              : Theme.of(context).colorScheme.secondary,
          Icons.timer_outlined,
          screenWidth,
        ),
        SizedBox(height: 16),
        _buildTimeCard(
          'Time Used',
          _formatDuration(widget.session.timeElapsed),
          Theme.of(context).colorScheme.primary,
          Icons.access_time,
          screenWidth,
        ),
        SizedBox(height: 24),
        _buildProgressBar(screenWidth),
        SizedBox(height: 24),
        _buildSessionInfo(screenWidth),
      ],
    );
  }

  Widget _buildTimeCard(
    String label,
    String time,
    Color color,
    IconData icon,
    double screenWidth,
  ) {
    final isLarge = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 20),
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
          Icon(icon, size: isLarge ? 40 : 32, color: color),
          SizedBox(height: isLarge ? 12 : 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: isLarge ? 16 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isLarge ? 8 : 6),
          FittedBox(
            child: Text(
              time,
              style: TextStyle(
                fontSize: isLarge ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double screenWidth) {
    final isLarge = screenWidth > 600;
    final progress = widget.session.progressPercentage;

    return Column(
      children: [
        Text(
          'Session Progress',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLarge ? 18 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isLarge ? 16 : 12),
        Container(
          height: isLarge ? 12 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.session.isExpired
                    ? Colors.red
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
        SizedBox(height: isLarge ? 12 : 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isLarge ? 14 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(double screenWidth) {
    final isLarge = screenWidth > 600;
    final isMobile = screenWidth <= 480;

    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child:
          isMobile
              ? Column(
                children: [
                  _buildInfoItem(
                    'Start Time',
                    _formatTime24Hour(widget.session.timeIn),
                    Icons.play_circle_outline,
                    screenWidth,
                  ),
                  SizedBox(height: 16),
                  _buildInfoItem(
                    'End Time',
                    _formatTime24Hour(widget.session.timeOut),
                    Icons.stop_circle_outlined,
                    screenWidth,
                  ),
                  SizedBox(height: 16),
                  _buildInfoItem(
                    'Duration',
                    '${widget.session.duration.inMinutes} min',
                    Icons.schedule,
                    screenWidth,
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    'Start Time',
                    _formatTime24Hour(widget.session.timeIn),
                    Icons.play_circle_outline,
                    screenWidth,
                  ),
                  _buildInfoItem(
                    'End Time',
                    _formatTime24Hour(widget.session.timeOut),
                    Icons.stop_circle_outlined,
                    screenWidth,
                  ),
                  _buildInfoItem(
                    'Duration',
                    '${widget.session.duration.inMinutes} min',
                    Icons.schedule,
                    screenWidth,
                  ),
                ],
              ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    double screenWidth,
  ) {
    final isLarge = screenWidth > 600;

    return Column(
      children: [
        Icon(
          icon,
          size: isLarge ? 24 : 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: isLarge ? 8 : 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: isLarge ? 12 : 10,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isLarge ? 14 : 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(double screenWidth) {
    final isLarge = screenWidth > 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLarge ? 16 : 12,
        horizontal: isLarge ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color:
            widget.session.isExpired
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.session.isExpired ? Icons.check_circle : Icons.info_outline,
            size: isLarge ? 20 : 18,
            color:
                widget.session.isExpired
                    ? Colors.red
                    : Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.session.isExpired
                  ? 'Session ended at ${_formatTime24Hour(widget.session.timeOut)}'
                  : 'Session will end automatically at ${_formatTime24Hour(widget.session.timeOut)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isLarge ? 14 : 12,
                color:
                    widget.session.isExpired
                        ? Colors.red
                        : Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for responsive design
  double _getPadding(double screenWidth) {
    if (screenWidth > 1200) return 48.0;
    if (screenWidth > 768) return 32.0;
    return 20.0;
  }

  double _getSpacing(double screenWidth, {bool large = false}) {
    final base = large ? 2.0 : 1.0;
    if (screenWidth > 1200) return 32.0 * base;
    if (screenWidth > 768) return 24.0 * base;
    return 16.0 * base;
  }

  // Time formatting methods
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}h ${minutes.toString().padLeft(2, '0')}m';
    } else {
      return '${minutes.toString().padLeft(2, '0')}m';
    }
  }

  String _formatDurationWithSeconds(Duration duration) {
    if (duration == Duration.zero) return '00:00';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime24Hour(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
