import 'dart:convert';

import 'package:NCSC/Services/Get_Server_key.dart';
import 'package:http/http.dart' as http;

class SendNotification{
  static Future<int> sendNotificationbyAPI({
    required String token,
    required String title,
    required String body,
    Map<String,dynamic>? data,
}) async{
    String serverKey=await get_server_key().get_ServerKeyToken();
    String url =
        "https://fcm.googleapis.com/v1/projects/ncsc-db/messages:send";

    var headers=<String,String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    Map<String,dynamic> msg={
      "message": {
        "token": "$token",
        "notification": {
          "title": "$title",
          "body": "$body",
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(msg),
    );

    print(response.body.toString());

    int res=0;

    if(response.statusCode==200){
      print("Notification Send");
      res++;
    }else{
      print(response.body);
    }

    return res;
  }
}