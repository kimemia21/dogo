class Sessionbooking {
   int podId;
   String date; // Format: YYYY-MM-DD
   String startTime; // Format: HH:mm
   String hh; // Duration hours
   String mm; // Duration minutes
   String userPhone;
   String userName;
   String userEmail;

  Sessionbooking({
    required this.podId,
    required this.date,
    required this.startTime,
    required this.hh,
    required this.mm,
    required this.userPhone,
    required this.userName,
    required this.userEmail,
  });

  /// Factory to create an empty instance
  factory Sessionbooking.empty() {
    return Sessionbooking(
      podId: 0,
      date: '',
      startTime: '',
      hh: "0",
      mm: "0",
      userPhone: '',
      userName: '',
      userEmail: '',
    );
  }

  /// Optional: Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'podId': podId,
      'date': date,
      'startTime': startTime,
      'hh': hh,
      'mm': mm,
      'userPhone': userPhone,
      'userName': userName,
      'userEmail': userEmail,
    };
  }

/// Optional: Create from JSON
fromJson(Map<String, dynamic> json) {
 podId = json['podId'] ?? podId;
date = json['date'] ?? date;
startTime = json['startTime'] ?? startTime;
hh = json['hh'] ?? hh;
mm = json['mm'] ?? mm;
userPhone = json['userPhone'] ?? userPhone;
userName = json['userName'] ?? userName;
userEmail = json['userEmail'] ?? userEmail;
}
}
