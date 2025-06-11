import 'package:dogo/core/constants/initializer.dart';

class Localhost {
  static postToLocalhost(String path, Map<String, dynamic> data) async {
    print("Calling");
    final response = await comms.postRequest(
      isLocal: true,

      endpoint: path,
      data: data,
    );

    if (response["statuscode"] == 200) {
      return response["rsp"];
    } else {
      throw Exception('Failed to post data to localhost');
    }
  }

  static getFromLocalhost() async {
    final response = await comms.getRequests(
      isLocal: true,
      endpoint: "api/status",
    );

    if (response["statuscode"] == 200) {
      return response["rsp"];
    } else {
      throw Exception('Failed to post data to localhost');
    }
  }




  // static getFromLocalhost(String path) async {
  //   final url = Uri.parse('http://localhost:3000/$path');
  //   final response = await get(url);

  //   if (response.statusCode == 200) {
  //     return response.body;
  //   } else {
  //     throw Exception('Failed to get data from localhost');
  //   }
  // }
}


//  POST http://192.168.100.74:3000/api/start \
//   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" \
//   -H "Content-Type: application/json" \
//   -d '{"user":"John","duration":2,"interval":1,"startNow":true}'