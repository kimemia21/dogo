class DateTimeFormatter {
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} - ${time.day}/${time.month}/${time.year}';
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return 'Expired';
    }
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }
}

class TimePickerHelper {
  static List<String> generateHours() {
    return List.generate(24, (index) => index.toString().padLeft(2, '0'));
  }

  static List<String> generateMinutes() {
    return List.generate(60, (index) => index.toString().padLeft(2, '0'));
  }
}