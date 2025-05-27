class PodSession {
  final String phone;
  final DateTime timeIn;
  final Duration duration;
  final bool isValid;

  PodSession({
    required this.phone,
    required this.timeIn,
    required this.duration,
    required this.isValid,
  });

  DateTime get timeOut => timeIn.add(duration);
  
  Duration get timeRemaining {
    final now = DateTime.now();
    final remaining = timeOut.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  bool get isExpired => timeRemaining == Duration.zero;

  factory PodSession.fromMap(Map<String, dynamic> map) {
    return PodSession(
      phone: map['phone'] as String,
      timeIn: map['timeIn'] as DateTime,
      duration: map['duration'] as Duration,
      isValid: map['isValid'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'timeIn': timeIn,
      'duration': duration,
      'isValid': isValid,
    };
  }
}