// Pod model to match your endpoint data
class Pod {
  final int id;
  final String stationName;
  final String location;
  final DateTime createdOn;
  final String? ipAddress;
  final String? cmdEndpoint;

  Pod({
    required this.id,
    required this.stationName,
    required this.location,
    required this.createdOn,
    this.ipAddress,
    this.cmdEndpoint,
  });

  factory Pod.fromJson(Map<String, dynamic> json) {
    return Pod(
      id: json['id'],
      stationName: json['station_name'],
      location: json['location'],
      createdOn: DateTime.parse(json['created_on']),
      ipAddress: json['ip_address'],
      cmdEndpoint: json['cmd_endpoint'],
    );
  }
}