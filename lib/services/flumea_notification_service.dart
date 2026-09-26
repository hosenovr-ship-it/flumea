import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlumeaNotificationService {
  FlumeaNotificationService._();

  static final FlumeaNotificationService instance =
      FlumeaNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'flumea_notifications',
    'FLUMEA',
    description: 'إشعارات تطبيق FLUMEA',
    importance: Importance.high,
    playSound: true,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_channel);

    await androidImplementation?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> show({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'flumea_notifications',
      'FLUMEA',
      channelDescription: 'إشعارات تطبيق FLUMEA',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
    );
  }

  Future<void> showSuccess({
    required String title,
    required String body,
    int id = 100,
  }) async {
    await show(
      id: id,
      title: title,
      body: body,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
