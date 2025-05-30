class Booking {
  final String sessionId;
  final String duration;
  final String phoneNumber;
  final String username;
  final String email;

  Booking({
    required this.sessionId,
    required this.duration,
    required this.phoneNumber,
   required this.username,
   required this.email,

  });

  factory Booking.empty() {
    return Booking(
      sessionId: 'notIntialized',
      duration: 'notIntialized',
      phoneNumber: 'notIntialized',
      username: 'notIntialized',
      email: 'notIntialized',
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json, String phoneNumber, String username, String email) {
    return Booking(
      sessionId: json['sessionId'] as String,
      duration: json['duration'] as String,
      phoneNumber: phoneNumber,
      username: username,
      email: email,

    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'duration': duration,
    'phoneNumber': phoneNumber,
    'username': username,
    'email': email,
  };

  @override
  String toString() =>
      'Booking(sessionId: $sessionId, duration: $duration, phoneNumber: $phoneNumber )';
}
