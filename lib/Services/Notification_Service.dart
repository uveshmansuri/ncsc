import 'dart:io';

import 'package:NCSC/splash.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:universal_html/js.dart';

class Notification_Service{
  static FirebaseMessaging messaging=FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void get_permission() async{
    NotificationSettings setings=await messaging.requestPermission(
      alert: true,
      announcement: true,
      carPlay: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if(setings.authorizationStatus==AuthorizationStatus.authorized){
      print("Authorized");
    }
    else if(setings.authorizationStatus==AuthorizationStatus.provisional){
      print("Provisional");
    }
    else{
      Get.snackbar(
        "Permission Not given",
        "Grant Notification Permission",
        snackPosition: SnackPosition.BOTTOM
      );
      Future.delayed(Duration(seconds: 2),(){
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  static Future<String> getDeviceToken() async{
    NotificationSettings settings=await messaging.requestPermission(
      alert: true,
      announcement: true,
      carPlay: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    String? token= await messaging.getToken();
    print(token);
    return token!;
  }

  //init notifications
  void initLocalNotifications(BuildContext context, RemoteMessage message) async{
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          handleMsg(context, message);
        });
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((msg){
      RemoteNotification? notification=msg.notification;
      AndroidNotification? android=msg.notification!.android;

      if(kDebugMode){
        print(notification!.title);
        print(notification.body);
      }
      if(Platform.isIOS){
        iosForgroundMsg();
      }

      if(Platform.isAndroid){
        initLocalNotifications(context, msg);
        //handleMsg(context,msg);
        showNotification(msg);
      }
    });
  }

  Future<void> showNotification(RemoteMessage msg) async{
    AndroidNotificationChannel channel=AndroidNotificationChannel(
        msg.notification!.android!.channelId.toString(),
        msg.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androd_noti_details=AndroidNotificationDetails(
        channel.id, channel.name,
      channelDescription: "Desc",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: channel.sound,
    );

    DarwinNotificationDetails darwinNotificationDetails=const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails=NotificationDetails(
      android: androd_noti_details,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
        0,
        msg.notification!.title.toString(),
        msg.notification!.body.toString(),
        notificationDetails,
        payload: "my Data",
      );
    });
  }


  // background and terminated
  Future<void> setupInteractMsg(BuildContext ctx) async{

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((msg){
      handleMsg(ctx,msg);
    },);

    //terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? msg){
      if(msg!=null && msg.data.isNotEmpty){
        handleMsg(ctx,msg);
      }
    });
  }

  Future<void> handleMsg(BuildContext ctx,RemoteMessage msg) async{
    Navigator.push(ctx, MaterialPageRoute(builder: (ctx)=>splash()));
  }

  Future iosForgroundMsg() async{
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}