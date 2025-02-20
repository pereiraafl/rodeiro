import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  static Future<void> onDidReceiveNotification(NotificationResponse notificationResponse) async {
    print("Notification receive");
  }

  static late String API_URL;

  static Future<void> init(String URL) async {
    API_URL = URL;
    print("API_URL: $API_URL");
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "rodeiro_id", // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high, // importance must be at low or higher level
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();
    await service.configure(
        androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId: "rodeiro_id", // this must match with notification channel you created above.
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
    ), iosConfiguration: IosConfiguration(
      onBackground: null,
      autoStart: false,
      onForeground: null
    ));

    service.startService();
    service.invoke("set_api_url", {"url": API_URL});
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          'rodeiro_id',
          'Rodeiro Notification',
          importance: Importance.max,
          priority: Priority.high,
        ));

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'rodeiro_notification',
    );
  }
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String url = "";
  service.on("set_api_url").listen((event) {
    url = event?["url"] ?? "";
  });
  print("Using URL: $url");
  // bring to foreground
  Timer.periodic(const Duration(seconds: 60), (timer) async {

    final response = await http.get(Uri.parse('$url/continuous/last'));
    final response_json = json.decode(response.body);
    int cycle = response_json["cycle"].toInt();
    double temp = response_json["current_temp"].toDouble();

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'Atualização - Rodeiro',
          'Temperatura: ${temp} - Ciclo: ${cycle}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'rodeiro_id',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}