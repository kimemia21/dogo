import 'package:dogo/data/models/PaymentMethodInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Enum for payment methods
enum PaymentMethod { card, bank, mpesa }

// Time slot model
class TimeSlot {
  final String time;
  final bool isAvailable;
  final DateTime dateTime;

  TimeSlot({
    required this.time,
    required this.isAvailable,
    required this.dateTime,
  });
}

// Duration option model
class DurationOption {
  String label;
  Duration duration;

  DurationOption({required this.label, required this.duration});
}

class RegistrationForm extends StatefulWidget {
  final Function(String otp, Map<String, dynamic> sessionData)
  onRegistrationComplete;
  final VoidCallback onBackToOTP;

  const RegistrationForm({
    Key? key,
    required this.onRegistrationComplete,
    required this.onBackToOTP,
  }) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  // Registration form state
  int _registrationStep = 1;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  DurationOption? _selectedDuration;
  PaymentMethod? _selectedPaymentMethod;
  String? _bookingError;
  String _selectedMinutes = '00';
  String _selectedHours = '00';
  String? _timeSelectionError;

  // Duration options
  final List<DurationOption> _durationOptions = [
    DurationOption(label: '30 mins', duration: Duration(minutes: 30)),
    DurationOption(label: '1 hour', duration: Duration(hours: 1)),
    DurationOption(label: '2 hours', duration: Duration(hours: 2)),
    DurationOption(label: '3 hours', duration: Duration(hours: 3)),
    DurationOption(label: '4 hours', duration: Duration(hours: 4)),

  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Generate time slots for a given date (you'll replace this with API call)
  
  List<TimeSlot> _generateTimeSlots(DateTime date) {
    List<TimeSlot> slots = [];
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(
      date.year,
      date.month,
      date.day,
      6,
      0,
    ); // 6 AM
    DateTime endTime = DateTime(
      date.year,
      date.month,
      date.day,
      22,
      0,
    ); // 10 PM

    while (startTime.isBefore(endTime)) {
      bool isAvailable = startTime.isAfter(now.add(Duration(hours: 1)));

      slots.add(
        TimeSlot(
          time: _formatTime(startTime),
          isAvailable: isAvailable,
          dateTime: startTime,
        ),
      );

      startTime = startTime.add(Duration(minutes: 30));
    }

    return slots;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _registerPod() {
    if (_formKey.currentState!.validate() && _validateBookingSelection()) {
      // Generate a random 6-digit OTP for demo
      final otp =
          (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

      final sessionData = {
        "phone": _phoneController.text,
        "startTime": _selectedTimeSlot!.dateTime,
        "endTime": _selectedTimeSlot!.dateTime.add(_selectedDuration!.duration),
        "duration": _selectedDuration!.duration,
        "paymentMethod": _selectedPaymentMethod.toString(),
        "isValid": true,
      };

      widget.onRegistrationComplete(otp, sessionData);
    }
  }

  bool _validateBookingSelection() {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _bookingError = "Please enter your phone number";
      });
      return false;
    }
    if (_selectedTimeSlot == null || _selectedDuration == null) {
      setState(() {
        _bookingError = "Please select date, time, and duration";
      });
      return false;
    }
    setState(() {
      _bookingError = null;
    });
    return true;
  }

  Widget _buildTimeSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 24),

        // Duration Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pod Duration',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: _buildTimeWheelPicker(
                      label: 'Hours',
                      values: List.generate(
                        24,
                        (index) => index.toString().padLeft(2, '0'),
                      ),
                      selectedValue: _selectedHours,
                      onChanged: (value) {
                        setState(() {
                          _selectedHours = value;
                          _selectedDuration = DurationOption(
                            label: '${_selectedHours}h ${_selectedMinutes}m',
                            duration: Duration(
                              hours: int.parse(_selectedHours),
                              minutes: int.parse(_selectedMinutes),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  // Minutes
                  Expanded(
                    child: _buildTimeWheelPicker(
                      label: 'Minutes',
                      values: List.generate(
                        60,
                        (index) => index.toString().padLeft(2, '0'),
                      ),
                      selectedValue: _selectedMinutes,
                      onChanged: (value) {
                        setState(() {
                          _selectedMinutes = value;

                      _selectedDuration = DurationOption(
                            label: '${_selectedHours}h ${_selectedMinutes}m',
                            duration: Duration(
                              hours: int.parse(_selectedHours),
                              minutes: int.parse(_selectedMinutes),
                            ),
                          );
                        
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_timeSelectionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _timeSelectionError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeWheelPicker({
    required String label,
    required List<String> values,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Expanded(
          child: ListWheelScrollView(
            itemExtent: 40,
            diameterRatio: 1.5,
            physics: FixedExtentScrollPhysics(),
            children:
                values.map((value) {
                  final isSelected = value == selectedValue;
                  return Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration:
                        isSelected
                            ? BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            )
                            : null,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
            onSelectedItemChanged: (index) {
              onChanged(values[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Register for Pod',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Enter your details to get a Pod code',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),

          // Step indicator
          _buildStepIndicator(),
          SizedBox(height: 24),

          // Form steps
          if (_registrationStep == 1) _buildBookingDetailsStep(),
          if (_registrationStep == 2) _buildPaymentMethodStep(),

          SizedBox(height: 24),

          // Error message
          if (_bookingError != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _bookingError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Navigation buttons
          Row(
            children: [
              if (_registrationStep == 2)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _registrationStep = 1;
                        _bookingError = null;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 16),
                        SizedBox(width: 8),
                        Text('BACK'),
                      ],
                    ),
                  ),
                ),

              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      _registrationStep == 1
                          ? () {
                            if (_validateBookingSelection()) {
                              setState(() {
                                _registrationStep = 2;
                              });
                            }
                          }
                          : _registerPod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _registrationStep == 1 ? 'NEXT' : 'CONFIRM PAYMENT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Back to OTP
          TextButton(
            onPressed: widget.onBackToOTP,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Already have an OTP? Go back',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
                  _registrationStep == 2
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Number Input
        Text(
          'Phone Number',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: _getInputDecoration(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone,
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        SizedBox(height: 24),

        // Date Selection
        Text(
          'Select Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Show next 14 days
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected =
                  _selectedDate.day == date.day &&
                  _selectedDate.month == date.month &&
                  _selectedDate.year == date.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedTimeSlot = null; // Reset time selection
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                        ][date.weekday % 7],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ][date.month - 1],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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
        Text(
          'Available Time Slots',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Container(
          height: 200,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _generateTimeSlots(_selectedDate).length,
            itemBuilder: (context, index) {
              final slot = _generateTimeSlots(_selectedDate)[index];
              final isSelected = _selectedTimeSlot?.time == slot.time;

              return GestureDetector(
                onTap:
                    slot.isAvailable
                        ? () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        }
                        : null,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        !slot.isAvailable
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5)
                            : isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          !slot.isAvailable
                              ? Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3)
                              : isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot.time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            !slot.isAvailable
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.5)
                                : isSelected
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
        _buildTimeSelectionStep(),

        // Duration Selection
        Text(
          'Session Duration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _durationOptions.map((duration) {
                final isSelected = _selectedDuration?.label == duration.label;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      duration.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        // Booking Summary
        if (_selectedTimeSlot != null && _selectedDuration != null)
          Container(
            margin: EdgeInsets.only(top: 24),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('Date: ${_formatDate(_selectedDate)}'),
                Text('Start Time: ${_selectedTimeSlot!.time}'),
                Text('Duration: ${_selectedDuration!.label}'),
                Text(
                  'End Time: ${_formatTime(_selectedTimeSlot!.dateTime.add(_selectedDuration!.duration))}',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 16),

        // Payment options
        ...PaymentMethod.values.map((method) => _buildPaymentOption(method)),

        SizedBox(height: 24),

        // Payment details form based on selected method
        if (_selectedPaymentMethod != null)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _buildPaymentDetailsForm(_selectedPaymentMethod!),
          ),
      ],
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    final paymentInfo = _getPaymentMethodInfo(method);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(paymentInfo.icon, color: paymentInfo.color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentInfo.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    paymentInfo.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsForm(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivider('Card Details'),
            TextFormField(
              decoration: _getInputDecoration(
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                icon: Icons.credit_card,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: _getInputDecoration(
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      icon: Icons.calendar_today,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: _getInputDecoration(
                      label: 'CVV',
                      hint: '123',
                      icon: Icons.lock_outline,
                    ),
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: _getInputDecoration(
                label: 'Cardholder Name',
                hint: 'Name as it appears on card',
                icon: Icons.person_outline,
              ),
            ),
          ],
        );

      case PaymentMethod.bank:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivider('Bank Transfer Details'),
            DropdownButtonFormField<String>(
              decoration: _getInputDecoration(
                label: 'Select Bank',
                hint: 'Choose your bank',
                icon: Icons.account_balance,
              ),
              items:
                  [
                    'KCB Bank',
                    'Equity Bank',
                    'Standard Chartered',
                    'Cooperative Bank',
                    'NCBA Bank',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: _getInputDecoration(
                label: 'Account Number',
                hint: 'Enter your account number',
                icon: Icons.account_balance_wallet,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case PaymentMethod.mpesa:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDivider('M-Pesa Details'),
            TextFormField(
              controller: _phoneController,
              decoration: _getInputDecoration(
                label: 'M-Pesa Phone Number',
                hint: 'Enter phone number registered with M-Pesa',
                icon: Icons.phone_android,
              ),
              keyboardType: TextInputType.phone,
              enabled: false,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You will receive an M-Pesa prompt on your phone to complete the payment.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildDivider(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  PaymentMethodInfo _getPaymentMethodInfo(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return PaymentMethodInfo(
          name: 'Credit/Debit Card',
          description: 'Pay securely with your card',
          icon: Icons.credit_card,
          color: Colors.blue,
        );
      case PaymentMethod.bank:
        return PaymentMethodInfo(
          name: 'Bank Transfer',
          description: 'Pay directly from your bank account',
          icon: Icons.account_balance,
          color: Colors.green,
        );
      case PaymentMethod.mpesa:
        return PaymentMethodInfo(
          name: 'M-Pesa',
          description: 'Pay using M-Pesa mobile money',
          icon: Icons.phone_android,
          color: Colors.deepPurple,
        );
    }
  }
}
