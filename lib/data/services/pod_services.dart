// import 'package:dogo/data/models/Pod_sessions.dart';



// class PodService {
//   static final PodService _instance = PodService._internal();
//   factory PodService() => _instance;
//   PodService._internal();

//   // Sample data for demo
//   final Map<String, PodSession> _podSessions = {
//     "123456": PodSession(
//       phone: "+1234567890",
//       timeIn: DateTime.now().subtract(Duration(hours: 1)),
//       duration: Duration(hours: 3),
//       isValid: true,
//     ),
//   };

//   bool isValidOTP(String otp) {
//     return _podSessions.containsKey(otp) && _podSessions[otp]!.isValid;
//   }

//   PodSession? getPodSession(String otp) {
//     return _podSessions[otp];
//   }

//   String registerPodSession({
//     required String phone,
//     required int hours,
//     required int minutes,
//   }) {
//     // Generate a random 6-digit OTP for demo
//     final otp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    
//     // Calculate total duration
//     final totalMinutes = (hours * 60) + minutes;
//     final duration = Duration(minutes: totalMinutes);
    
//     _podSessions[otp] = PodSession(
//       phone: phone,
//       timeIn: DateTime.now(),
//       duration: duration,
//       isValid: true,
//     );

//     return otp;
//   }

//   List<String> getSampleBanks() {
//     return [
//       'KCB Bank',
//       'Equity Bank',
//       'Standard Chartered',
//       'Cooperative Bank',
//       'NCBA Bank',
//     ];
//   }
// }