import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BookingConfirmedPage extends StatefulWidget {
  final String podName;
  final String podType;
  final String location;
  final DateTime startDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final LatLng podPosition;
  final String duration;
  final String price;
  final List<String> amenities;

  BookingConfirmedPage({
    required this.podName,
    required this.podType,
    required this.location,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.podPosition,
    required this.duration,
    required this.price,
    required this.amenities,
  });

  @override
  _BookingConfirmedPageState createState() => _BookingConfirmedPageState();
}

class _BookingConfirmedPageState extends State<BookingConfirmedPage>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      body: Stack(
        children: [
          // Premium gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white],
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: isMobile ? 40 : 60),
                _buildConfirmationHeader(theme, isDesktop, isTablet, isMobile),
                _buildBookingDetails(theme, isDesktop, isTablet, isMobile),
                _buildMapSection(theme, isDesktop, isTablet, isMobile),
                _buildActionButtons(theme, isDesktop, isTablet, isMobile),
                SizedBox(height: 40),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: isMobile ? 50 : 80,
            left: isMobile ? 20 : 40,
            child: _buildBackButton(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.arrow_back,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmationHeader(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
                vertical: isMobile ? 40 : 60,
              ),
              child: Column(
                children: [
                  // Success icon with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green,
                            Colors.green.withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 25,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isMobile ? 40 : 50,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 40),
                  Text(
                    'Booking Confirmed!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: isMobile ? 28 : (isTablet ? 36 : 42),
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Text(
                      'Your workspace session has been successfully booked. We\'ve sent confirmation details to your email.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        fontSize: isMobile ? 16 : 18,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookingDetails(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.08),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.1),
                          theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      size: 24,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Session Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontSize: isMobile ? 20 : 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Date and Time Section
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                _formatDate(widget.startDate),
                theme,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                Icons.access_time,
                'Time',
                '${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}',
                theme,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                Icons.timelapse,
                'Duration',
                widget.duration,
                theme,
              ),
              SizedBox(height: 20),
              
              Divider(color: Colors.grey[300], thickness: 1),
              SizedBox(height: 20),
              
              // Pod Details Section
              _buildDetailRow(
                Icons.work_outline,
                'Pod Type',
                widget.podType,
                theme,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                Icons.business,
                'Location',
                widget.podName,
                theme,
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                Icons.location_on,
                'Address',
                widget.location,
                theme,
              ),
              SizedBox(height: 20),
              
              Divider(color: Colors.grey[300], thickness: 1),
              SizedBox(height: 20),
              
              // Price Section
              _buildDetailRow(
                Icons.payment,
                'Total Cost',
                widget.price,
                theme,
                isPrice: true,
              ),
              SizedBox(height: 20),
              
              // Amenities Section
              Text(
                'Included Amenities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.amenities
                    .map(
                      (amenity) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              amenity,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool isPrice = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isPrice ? 18 : 16,
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.w600,
                  color: isPrice ? Colors.green[700] : theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.08),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.1),
                          theme.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 24,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your Pod Location',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        fontSize: isMobile ? 18 : 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: isMobile ? 300 : (isTablet ? 350 : 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: widget.podPosition,
                      initialZoom: 15.0,
                      minZoom: 10.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.workpod.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.podPosition,
                            width: 80,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Colors.green.withOpacity(0.8),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.work,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your booked pod is marked on the map',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Use the map to navigate to your workspace',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
          vertical: 20,
        ),
        child: Column(
          children: [
            if (isDesktop || isTablet)
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'View My Bookings',
                      Icons.event_note,
                      theme.primaryColor,
                      Colors.white,
                      () {
                        // Navigate to bookings page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating to your bookings...'),
                            backgroundColor: theme.primaryColor,
                          ),
                        );
                      },
                      isMobile,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      'Share Location',
                      Icons.share,
                      Colors.white,
                      theme.primaryColor,
                      () {
                        // Share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sharing pod location...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      isMobile,
                      isOutlined: true,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildActionButton(
                    'View My Bookings',
                    Icons.event_note,
                    theme.primaryColor,
                    Colors.white,
                    () {
                      // Navigate to bookings page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigating to your bookings...'),
                          backgroundColor: theme.primaryColor,
                        ),
                      );
                    },
                    isMobile,
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    'Share Location',
                    Icons.share,
                    Colors.white,
                    theme.primaryColor,
                    () {
                      // Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sharing pod location...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    isMobile,
                    isOutlined: true,
                  ),
                ],
              ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please arrive 5 minutes before your session starts. Check-in instructions will be sent to your phone.',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
    bool isMobile, {
    bool isOutlined = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
          side: isOutlined ? BorderSide(color: backgroundColor, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: isOutlined ? 0 : 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}