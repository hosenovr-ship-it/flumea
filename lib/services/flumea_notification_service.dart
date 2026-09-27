import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FlumeaNotificationType {
  general,
  habit,
  task,
  achievement,
  water,
}

class FlumeaNotificationService {
  FlumeaNotificationService._();

  static final FlumeaNotificationService instance =
      FlumeaNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initializing;
  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'flumea_notifications',
    'إشعارات FLUMEA',
    description: 'تنبيهات المهام والعادات والإنجازات في FLUMEA.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await android?.createNotificationChannel(_channel);
      _initialized = true;
    } catch (_) {
      // لا نوقف التطبيق إذا تعذر تشغيل الإشعارات.
    }
  }

  @pragma('vm:entry-point')
  static void _onNotificationResponse(NotificationResponse response) {}

  Future<bool> show({
    required String title,
    required String body,
    FlumeaNotificationType type = FlumeaNotificationType.general,
    bool requestPermission = true,
    String? payload,
  }) async {
    if (!await _isEnabled(type)) return false;

    await initialize();
    if (!_initialized) return false;

    if (Platform.isAndroid && requestPermission) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      if (granted == false) return false;
    }

    final details = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
      onlyAlertOnce: false,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
      ),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: details),
      payload: payload,
    );

    return true;
  }

  Future<bool> _isEnabled(FlumeaNotificationType type) async {
    if (type == FlumeaNotificationType.general) return true;

    final prefs = await SharedPreferences.getInstance();

    switch (type) {
      case FlumeaNotificationType.habit:
        return prefs.getBool('flumea_notify_habits') ?? true;
      case FlumeaNotificationType.task:
        return prefs.getBool('flumea_notify_tasks') ?? true;
      case FlumeaNotificationType.achievement:
        return prefs.getBool('flumea_notify_achievements') ?? true;
      case FlumeaNotificationType.water:
        return prefs.getBool('flumea_notify_water') ?? true;
      case FlumeaNotificationType.general:
        return true;
    }
  }
}
