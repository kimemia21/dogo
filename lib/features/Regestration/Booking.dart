import 'package:dogo/features/Pod/Maps.dart';
import 'package:flutter/material.dart';
import 'package:dogo/core/theme/AppColors.dart';
import 'package:dogo/data/models/TimeSlots.dart';
import 'package:dogo/core/constants/initializer.dart';

class TimeSlotDurationScreen extends StatefulWidget {
  final Function(TimeSlot, String, String)? onSelectionComplete;
  final int podId;

  const TimeSlotDurationScreen({
    Key? key,
    this.onSelectionComplete,
    this.podId = 1,
  }) : super(key: key);

  @override
  _TimeSlotDurationScreenState createState() => _TimeSlotDurationScreenState();
}

class _TimeSlotDurationScreenState extends State<TimeSlotDurationScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  String _selectedHours = '01';
  String _selectedMinutes = '00';
  String _charges = "ksh 0";
  String? _errorMessage;
  bool _isLoading = false;
  List<TimeSlot> _availableSlots = [];
  int _currentStep = 0; // 0: Date & Time, 1: Duration

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  String get formattedDate =>
      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

  Future<void> _fetchAvailableSlots() async {
    setState(() => _isLoading = true);

    setState(() {
      // _isLoading = false;
      // _availableSlots =
      //     [
      //           "08:00",
      //           "09:00",
      //           "10:00",
      //           "11:00",
      //           "12:00",
      //           "13:00",
      //           "14:00",
      //           "15:00",
      //           "16:00",
      //           "17:00",
      //           "18:00",
      //           "19:00",
      //         ]
      //         //  (req["rsp"]['data'] as List)
      //         .map((slot) => TimeSlot.fromJson(slot))
      //         .toList();
      _errorMessage = null;
    });

    try {
      final req = await comms.postRequest(
        endpoint: "pods/slots",
        data: {"podId": widget.podId, "date": formattedDate},
      );

      if (req["rsp"]['success']) {
        // EDITTED SERVER ERROR HARD CODED
        setState(() {
          _availableSlots =
              (req["rsp"]['data'] as List)
                  .map((slot) => TimeSlot.fromJson(slot))
                  .toList();
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = "Failed to fetch available slots");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchTariffs() async {
    print("=== fetchTariffs START ===");
    print("_selectedHours: $_selectedHours");
    print("_selectedMinutes: $_selectedMinutes");

    try {
      // Check if values can be parsed
      int hours = int.parse(_selectedHours);
      int minutes = int.parse(_selectedMinutes);
      print("Parsed - Hours: $hours, Minutes: $minutes");

      print("About to call comms.getRequests...");

      final req = await comms.getRequests(
        endpoint: "rates",
        queryParameters: {"hh": hours, "mm": minutes},
      );

      print("comms.getRequests completed!");
      print("Response: $req");

      if (req['success']) {
        print("Success response received");
        setState(() {
          _charges = req["rsp"]['data']['charges'];
          _errorMessage = null;
        });
      } else {
        print("Response indicates failure: $req");
        setState(() => _errorMessage = "Server returned error");
      }
    } catch (e) {
      print("ERROR in fetchTariffs: $e");
      print("Error type: ${e.runtimeType}");
      setState(() => _errorMessage = "Failed to fetch charges $e");
    }

    print("=== fetchTariffs END ===");
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedTimeSlot != null) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      Map<String, dynamic> _se = {
        'date': formattedDate,
        'startTime': _selectedTimeSlot?.timeSlot,
        'hh': _selectedHours,
        'mm': _selectedMinutes,
        'charges': _charges,
      };
      sessionbooking.fromJson(_se);
      print(sessionbooking.toJson());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingPage(wasBooked: true)),
      );

      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Select Time & Duration'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStepIndicator(),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child:
                    _currentStep == 0
                        ? _buildTimeSlotStep()
                        : _buildDurationStep(),
              ),
            ),
            SizedBox(height: 24),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color:
                  _currentStep >= 1
                      ? Theme.of(context).colorScheme.secondary
                      : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date & Time',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Choose your preferred date and time slot',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 24),

        // Date Selector
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected =
                  _selectedDate.day == date.day &&
                  _selectedDate.month == date.month;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null;
                  });
                  _fetchAvailableSlots();
                },
                child: Container(
                  width: 60,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][date.weekday % 7],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 24),

        // Time Slots
        if (_isLoading)
          Center(child: CircularProgressIndicator())
        else if (_availableSlots.isNotEmpty) ...[
          Text(
            'Available Time Slots',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _availableSlots
                    .map((slot) => _buildTimeSlotItem(slot))
                    .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSlotItem(TimeSlot slot) {
    final isSelected = _selectedTimeSlot?.timeSlot == slot.timeSlot;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeSlot = slot),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : AppColors.border,
          ),
        ),
        child: Text(
          slot.timeSlot,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Duration',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'How long do you need the pod?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 32),

        // Duration Pickers
        _buildDurationPicker('Hours', _selectedHours, (val) {
          setState(() {
            _selectedHours = val;
          });

          fetchTariffs();
        }),
        SizedBox(height: 16),
        _buildDurationPicker('Minutes', _selectedMinutes, (val) {
          setState(() => _selectedMinutes = val);
          print("Changed to $val");
          fetchTariffs();
        }),

        SizedBox(height: 32),

        // Charges Display
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                'Total Charges',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),
              Text(
                _charges,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker(
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: List.generate(
                label == 'Hours' ? 24 : 60,
                (index) => DropdownMenuItem(
                  value: index.toString().padLeft(2, '0'),
                  child: Text(index.toString().padLeft(2, '0')),
                ),
              ),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isLoading
                  ? 'LOADING...'
                  : (_currentStep == 0
                      ? 'SELECT DURATION'
                      : 'CONFIRM SELECTION'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (_currentStep > 0) ...[
          SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentStep--),
            child: Text(
              'Go Back',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
