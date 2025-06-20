import 'package:dogo/features/Pod/Homepage.dart';
import 'package:dogo/features/Regestration/Booking.dart';
import 'package:dogo/features/Regestration/RegestrationForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LandingPage extends StatefulWidget {
  final bool wasBooked;
  LandingPage({required this.wasBooked});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _isMapInteractive = false;
  bool _hasActiveBooking = false; // Simulate user booking state

  // Sample work pod locations in Nairobi
  final List<WorkPodLocation> workPods = [
    WorkPodLocation(
      name: 'TechHub Nairobi',
      position: LatLng(-1.2921, 36.8219),
      amenities: ['WiFi', 'Coffee', 'Meeting Rooms', 'Parking'],
      rating: 4.8,
      reviews: 324,
      price: 'KSh 500/hour',
      image: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
      description:
          'Premium co-working space in the heart of Nairobi with state-of-the-art facilities.',
      hours: '24/7',
      phone: '+254 700 123 456',
    ),
    WorkPodLocation(
      name: 'Creative Space Westlands',
      position: LatLng(-1.2676, 36.8108),
      amenities: ['WiFi', 'Printer', 'Quiet Zone', 'Kitchen'],
      rating: 4.6,
      reviews: 189,
      price: 'KSh 400/hour',
      image: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36',
      description:
          'Inspiring creative workspace designed for designers, artists, and freelancers.',
      hours: '6AM - 10PM',
      phone: '+254 700 789 012',
    ),
    WorkPodLocation(
      name: 'Startup Hub Karen',
      position: LatLng(-1.3197, 36.7086),
      amenities: ['WiFi', 'Kitchen', 'Parking', 'Meeting Rooms'],
      rating: 4.9,
      reviews: 256,
      price: 'KSh 600/hour',
      image: 'https://images.unsplash.com/photo-1556761175-b413da4baf72',
      description:
          'Exclusive premium workspace for startups, entrepreneurs, and established businesses.',
      hours: '24/7',
      phone: '+254 700 345 678',
    ),
  ];

  final List<String> imgList = [
    'https://corsproxy.io/?https://dogo.co.ke/wp-content/uploads/2025/02/Duo-768x1089.png',
    'https://corsproxy.io/?https://dogo.co.ke/wp-content/uploads/2025/02/Solo-pod-768x1089.png',
    'https://corsproxy.io/?https://dogo.co.ke/wp-content/uploads/2025/02/Mini-Pod-768x1089.png',
    'https://corsproxy.io/?https://dogo.co.ke/wp-content/uploads/2024/12/LLC-6-768x960.jpg',
    'https://corsproxy.io/?https://dogo.co.ke/wp-content/uploads/2025/02/Nap-Pod-2-768x1089.png',
  ];

final List<Map<String, dynamic>> podDesc = [
  {
    "name": "Dogo Solo",
    "description":
        "For private calls and online meetings in the workplace, home, school and public spaces",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Dogo Duo",
    "description":
        "For private calls and online meetings in the workplace, home, school and public spaces",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Lactation Room",
    "description":
        "Does your workplace support moms by providing pumping or nursing spaces? Dogo lactation room is a lactation solution for moms in the workplace.",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Nap Pod",
    "description": "Ideal for short rest and recovery sessions in workspaces or schools.",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Prayer Pod",
    "description": "A quiet space for personal devotion, prayer, or meditation.",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Homework Pod",
    "description": "Designed for focused learning and study sessions in schools and libraries.",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
  {
    "name": "Gaming Pod",
    "description": "Equipped for immersive gaming experiences with sound isolation.",
    "features": [
      "50 sq ft",
      "Exterior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H",
      "Interior Dimensions: 9’3″ W x 5’6″ D x 7’7″ H"
    ]
  },
];

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
    _animationController.forward();

    // Simulate checking if user has active booking
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _hasActiveBooking = true; // This would come from your backend
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
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
                _buildHeroSection(theme, isDesktop, isTablet, isMobile),
                if (widget.wasBooked)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You are viewing filtered pods that are available at your selected time',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildMapSection(theme, isDesktop, isTablet, isMobile),
                widget.wasBooked
                    ? SizedBox()
                    : _buildFeaturesSection(
                      theme,
                      isDesktop,
                      isTablet,
                      isMobile,
                    ),
              ],
            ),
          ),
          // Floating action button for active bookings
          if (_hasActiveBooking)
            Positioned(
              top: isMobile ? 50 : 80,
              right: isMobile ? 20 : 40,
              child: _buildActiveBookingButton(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingButton(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => _showActiveBookingDetails(theme),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.access_time, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Active Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(
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
                  // Logo and title with premium styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 10 : 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: isMobile ? 28 : 36,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Dogo Pod',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: isMobile ? 28 : (isTablet ? 32 : 36),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 40 : 50),
                  Text(
                    'Find Your Perfect Workspace',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: isMobile ? 32 : (isTablet ? 42 : 52),
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Text(
                      'Discover premium workspaces across Kenya with verified amenities, flexible booking, and professional environments designed for your success.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.8,
                        ),
                        fontSize: isMobile ? 16 : 18,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapSection(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      height: isMobile ? 400 : (isTablet ? 500 : 600),
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isTablet ? 32 : 60),
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isMapInteractive = true;
                });
                // Auto-disable interaction after 5 seconds
                Future.delayed(Duration(seconds: 5), () {
                  if (mounted) {
                    setState(() {
                      _isMapInteractive = false;
                    });
                  }
                });
              },
              child: AbsorbPointer(
                absorbing: !_isMapInteractive,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(-1.2921, 36.8219),
                    initialZoom: 11.0,
                    minZoom: 8.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.workpod.app',
                    ),
                    MarkerLayer(
                      markers:
                          workPods
                              .map(
                                (pod) => Marker(
                                  point: pod.position,
                                  width: 60,
                                  height: 60,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.wasBooked) {
                                        _showPodDetails(pod, theme);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TimeSlotDurationScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    //  _showPodDetails(pod, theme),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.primaryColor,
                                            theme.primaryColor.withOpacity(0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.primaryColor
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.work,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Enhanced map overlay
            if (!_isMapInteractive)
              Positioned(
                top: 30,
                left: 30,
                right: 30,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.touch_app,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap to interact with map and explore locations',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Map interaction indicator
            if (_isMapInteractive)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Interactive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
        vertical: isMobile ? 60 : 80,
      ),
      child: Column(
        children: [
          Text(
            'Premium Features',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: isMobile ? 28 : (isTablet ? 32 : 36),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Everything you need for productive work sessions',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 50 : 60),
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    Icons.search,
                    'Smart Search',
                    'AI-powered location matching based on your preferences and work style',
                    theme,
                    false,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: _buildFeatureCard(
                    Icons.verified_user,
                    'Verified Spaces',
                    'All workspaces are professionally verified with quality assurance',
                    theme,
                    false,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: _buildFeatureCard(
                    Icons.star,
                    'Premium Quality',
                    'Curated selection of high-end amenities and professional environments',
                    theme,
                    false,
                  ),
                ),
              ],
            )
          else if (isTablet)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        Icons.search,
                        'Smart Search',
                        'AI-powered location matching based on your preferences and work style',
                        theme,
                        true,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildFeatureCard(
                        Icons.verified_user,
                        'Verified Spaces',
                        'All workspaces are professionally verified with quality assurance',
                        theme,
                        true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  child: _buildFeatureCard(
                    Icons.star,
                    'Premium Quality',
                    'Curated selection of high-end amenities and professional environments',
                    theme,
                    true,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildFeatureCard(
                  Icons.search,
                  'Smart Search',
                  'AI-powered location matching based on your preferences and work style',
                  theme,
                  true,
                ),
                SizedBox(height: 20),
                _buildFeatureCard(
                  Icons.verified_user,
                  'Verified Spaces',
                  'All workspaces are professionally verified with quality assurance',
                  theme,
                  true,
                ),
                SizedBox(height: 20),
                _buildFeatureCard(
                  Icons.star,
                  'Premium Quality',
                  'Curated selection of high-end amenities and professional environments',
                  theme,
                  true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    ThemeData theme,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: isMobile ? 32 : 40,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: isMobile ? 20 : 22,
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.6,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color color) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showPodDetails(WorkPodLocation pod, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.6,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Header with image and basic info
                          Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(pod.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pod.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                '${pod.rating}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${pod.reviews} reviews',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Available',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      pod.price,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Pod Gallery Section
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: theme.primaryColor,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Available Pods',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tap any image to see pod details',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imgList.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder:
                                                (context) => Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  insetPadding: EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    padding: EdgeInsets.all(16),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: Image.network(
                                                            imgList[index],
                                                            height:
                                                                MediaQuery.of(
                                                                  context,
                                                                ).size.height *
                                                                0.3,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(

                                                          '${podDesc[index]["name"]}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                theme
                                                                    .primaryColor,
                                                          ),
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text('${podDesc[index]["description"]}',
                                                         textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        SizedBox(height: 12),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  // Select this pod
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      theme
                                                                          .primaryColor,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Select Pod',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: OutlinedButton(
                                                                onPressed:
                                                                    () => Navigator.pop(
                                                                      context,
                                                                    ),
                                                                style: OutlinedButton.styleFrom(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  'Close',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          );
                                        },

                                        child: Container(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.45,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.65,
                                          margin: EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  imgList[index],

                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.65,
                                                  fit: BoxFit.cover,
                                                ),

                                                Positioned(
                                                  bottom: 4,
                                                  left: 4,
                                                  right: 4,
                                                  child: Text(
                                                    '${podDesc[index]["name"]}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          // Description
                          Text(
                            'About This Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            pod.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Perfect for focused work, meetings, or creative projects.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Amenities
                          Text(
                            'What\'s Included',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                pod.amenities
                                    .map(
                                      (amenity) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          border: Border.all(
                                            color: theme.primaryColor
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: theme.primaryColor,
                                              size: 12,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              amenity,
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SizedBox(height: 16),

                          // Location & Contact info
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: theme.primaryColor,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Hours',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            pod.hours,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                color: theme.primaryColor,
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Contact',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            pod.phone,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue[600],
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Book early to secure your preferred pod',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontSize: 11,
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
                          SizedBox(height: 20),

                          // Book button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PodBookingPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Book This Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  void _showBookingDialog(WorkPodLocation pod, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Book ${pod.name}'),
            content: Text(
              'Booking functionality would be implemented here with date/time selection and payment integration.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking confirmed for ${pod.name}!'),
                      backgroundColor: theme.primaryColor,
                    ),
                  );
                },
                child: Text('Confirm Booking'),
              ),
            ],
          ),
    );
  }

  void _showActiveBookingDetails(ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Text('Active Session'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TechHub Nairobi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text('Started: 2:30 PM'),
                Text('Duration: 2 hours'),
                Text('Ends: 4:30 PM'),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
                SizedBox(height: 8),
                Text(
                  '60% complete',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Session extended by 1 hour'),
                      backgroundColor: theme.primaryColor,
                    ),
                  );
                },
                child: Text('Extend Session'),
              ),
            ],
          ),
    );
  }
}

class WorkPodLocation {
  final String name;
  final LatLng position;
  final List<String> amenities;
  final double rating;
  final int reviews;
  final String price;
  final String image;
  final String description;
  final String hours;
  final String phone;

  WorkPodLocation({
    required this.name,
    required this.position,
    required this.amenities,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
    required this.description,
    required this.hours,
    required this.phone,
  });
}
