import 'package:dogo/data/models/Session.dart';
import 'package:dogo/data/models/booking.dart';
import 'package:dogo/data/models/sessionBooking.dart';
import 'package:dogo/data/services/Comms.dart';

Comms comms = Comms();
Booking booking = Booking.empty();
Sessionbooking sessionbooking = Sessionbooking.empty();
String fullUrl = "";
var podId;

Session sess = Session.empty();
