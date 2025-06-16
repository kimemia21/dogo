class PodSession {
  final String sessId;
  final String phone;
  final DateTime timeIn;
  final DateTime timeOut;
  final Duration duration;
  final bool isValid;

  PodSession({
    required this.sessId,
    required this.phone,
    required this.timeIn,
    required this.timeOut,
    required this.duration,
    required this.isValid,
  });

  factory PodSession.empty() {
    final now = DateTime.now();
    return PodSession(
      sessId: '',
      phone: '',
      timeIn: now,
      timeOut: now.add(Duration(minutes: 5)),
      duration: Duration(minutes: 5),
      isValid: true,
    );
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    final remaining = timeOut.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration get timeElapsed {
    final now = DateTime.now();
    final elapsed = now.difference(timeIn);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  bool get isExpired => timeRemaining == Duration.zero;

  bool get hasStarted => DateTime.now().isAfter(timeIn);

  bool get isActive => hasStarted && !isExpired && isValid;

  double get progressPercentage {
    if (!hasStarted) return 0.0;
    if (isExpired) return 1.0;
    
    final totalMinutes = duration.inMinutes;
    final elapsedMinutes = timeElapsed.inMinutes;
    
    if (totalMinutes == 0) return 0.0;
    final progress = elapsedMinutes / totalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  factory PodSession.fromMap(Map<String, dynamic> map) {
    // Parse date
    final date = DateTime.parse(map['sesDate']);
    
    // Parse start time (handle HH:mm:ss format)
    final startTimeParts = map['sessStart'].split(':');
    final timeIn = DateTime(
      date.year, 
      date.month, 
      date.day,
      int.parse(startTimeParts[0]), 
      int.parse(startTimeParts[1]),
      startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
    );
    
    // Parse end time (handle HH:mm:ss format)
    final endTimeParts = map['sessEnd'].split(':');
    final timeOut = DateTime(
      date.year, 
      date.month, 
      date.day,
      int.parse(endTimeParts[0]), 
      int.parse(endTimeParts[1]),
      endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
    );
    
    // Use sessDuration from the data if available, otherwise calculate from times
    Duration duration;
    if (map.containsKey('sessDuration') && map['sessDuration'] != null) {
      duration = Duration(minutes: map['sessDuration']);
    } else {
      duration = timeOut.difference(timeIn);
    }
    
    return PodSession(
      sessId: map['sessId'] ?? '',
      phone: map['phone'] ?? '', // Use phone from data or empty string
      timeIn: timeIn,
      timeOut: timeOut,
      duration: duration,
      isValid: !(map['isExpired'] ?? false),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessId': sessId,
      'phone': phone,
      'sesDate': '${timeIn.year.toString().padLeft(4, '0')}-${timeIn.month.toString().padLeft(2, '0')}-${timeIn.day.toString().padLeft(2, '0')}',
      'sessStart': '${timeIn.hour.toString().padLeft(2, '0')}:${timeIn.minute.toString().padLeft(2, '0')}:${timeIn.second.toString().padLeft(2, '0')}',
      'sessEnd': '${timeOut.hour.toString().padLeft(2, '0')}:${timeOut.minute.toString().padLeft(2, '0')}:${timeOut.second.toString().padLeft(2, '0')}',
      'sessDuration': duration.inMinutes,
      'isExpired': !isValid,
    };
  }

  @override
  String toString() {
    return 'PodSession(sessId: $sessId, phone: $phone, timeIn: $timeIn, timeOut: $timeOut, duration: ${duration.inMinutes}min, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PodSession &&
        other.sessId == sessId &&
        other.phone == phone &&
        other.timeIn == timeIn &&
        other.timeOut == timeOut &&
        other.duration == duration &&
        other.isValid == isValid;
  }

  @override
  int get hashCode {
    return Object.hash(sessId, phone, timeIn, timeOut, duration, isValid);
  }
}