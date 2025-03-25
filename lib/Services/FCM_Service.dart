import 'package:firebase_messaging/firebase_messaging.dart';

class FCM_Service{
  static void firebaseInit(){
    FirebaseMessaging.onMessage.listen((msg){
      msg.notification!.title;
    });
  }
}