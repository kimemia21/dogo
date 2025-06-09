class Session {
  final String sessId;
  final String sessPaymentStatus;
  final int sessDuration;
  final String sessStart;
  final String sessEnd;

  Session({
    required this.sessId,
    required this.sessPaymentStatus,
    required this.sessDuration,
    required this.sessStart,
    required this.sessEnd,
  });

  factory Session.empty() {
    return Session(
      sessId: "notInitialized",
      sessPaymentStatus: "notInitialized",
      sessDuration: 000000,
      sessStart: "15:00:00",
      sessEnd: "15:35:00",
    );
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessId: json['sessId'] as String,
      sessPaymentStatus: json['sessPaymentStatus'] as String,
      sessDuration: json['sessDuration'] as int,
      sessStart: json['sessStart'] as String,
      sessEnd: json['sessEnd'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessId': sessId,
      'sessPaymentStatus': sessPaymentStatus,
      'sessDuration': sessDuration,
      'sessStart': sessStart,
      'sessEnd': sessEnd,
    };
  }
}