class Sessionbooking {

   String date; 
   String startTime;
   String hh; 
   String mm; 
   

  Sessionbooking({
  
    required this.date,
    required this.startTime,
    required this.hh,
    required this.mm,
    
  });

  /// Factory to create an empty instance
  factory Sessionbooking.empty() {
    return Sessionbooking(
     
      date: '',
      startTime: '',
      hh: "0",
      mm: "0",
      
    );
  }

  /// Optional: Convert to JSON
  Map<String, dynamic> toJson() {
    return {

      'date': date,
      'startTime': startTime,
      'hh': hh,
      'mm': mm,
      
    };
  }

/// Optional: Create from JSON
fromJson(Map<String, dynamic> json) {

date = json['date'] ?? date;
startTime = json['startTime'] ?? startTime;
hh = json['hh'] ?? hh;
mm = json['mm'] ?? mm;}
}
