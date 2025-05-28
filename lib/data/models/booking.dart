class Booking {
  final String sessionId;
  final String duration;
  final String phoneNumber;

  Booking({
    required this.sessionId,
    required this.duration,
    required this.phoneNumber,
  });


  factory Booking.empty() {
    return Booking(
      sessionId: 'notIntialized',
      duration: 'notIntialized',
      phoneNumber: 'notIntialized',
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json, String phoneNumber) {
    return Booking(
      sessionId: json['sessionId'] as String,
      duration: json['duration'] as String,
      phoneNumber: phoneNumber,
    );
  }


  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'duration': duration,
        'phoneNumber': phoneNumber,
      };

  @override
  String toString() => 'Booking(sessionId: $sessionId, duration: $duration, phoneNumber: $phoneNumber)';
}