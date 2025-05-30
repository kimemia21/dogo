class TimeSlot {
  final String timeSlot;

  TimeSlot({required this.timeSlot});

  factory TimeSlot.fromJson(String time) {
    return TimeSlot(timeSlot: time);
  }

  static List<TimeSlot> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((time) => TimeSlot(timeSlot: time.toString())).toList();
  }
}
