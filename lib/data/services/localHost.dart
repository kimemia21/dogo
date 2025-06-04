import 'package:dogo/core/constants/initializer.dart';

class Localhost {

 static postToLocalhost(String path, Map<String, dynamic> data) async {
    // final url = Uri.parse('http://localhost:3000/$path');
    final response = await comms.postRequest(isLocal: true,

      endpoint:'http://localhost:3000',
      data: data,
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