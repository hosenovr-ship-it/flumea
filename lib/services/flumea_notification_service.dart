import 'dart:io';

import 'package:flutter/material.dart';
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
    importance: Importance.high,
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
    // لا نرسل إشعارات عامة من نوع general؛ الإشعار الخارجي يجب أن يكون
    // مرتبطًا بنوع واضح ومفيد للمستخدم.
    if (type == FlumeaNotificationType.general) return false;

    if (!await _isEnabled(type)) return false;

    // منع تكرار نفس الإشعار خلال فترة قصيرة حتى لا يتحول التنبيه إلى إزعاج.
    final prefs = await SharedPreferences.getInstance();
    final dedupeKey = _dedupeKey(title, body, type);
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastShown = prefs.getInt(dedupeKey);
    if (lastShown != null &&
        now - lastShown < const Duration(minutes: 10).inMilliseconds) {
      return false;
    }

    await initialize();
    if (!_initialized) return false;

    if (Platform.isAndroid && requestPermission) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final alreadyAsked =
          prefs.getBool('flumea_notifications_permission_requested') ?? false;

      if (!alreadyAsked) {
        final granted = await android?.requestNotificationsPermission();
        await prefs.setBool(
          'flumea_notifications_permission_requested',
          true,
        );
        if (granted == false) return false;
      } else {
        final enabled = await android?.areNotificationsEnabled();
        if (enabled == false) return false;
      }
    }

    final details = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
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

    await prefs.setInt(dedupeKey, now);
    return true;
  }



  /// يعرض رسالة أنيقة من أعلى الصفحة داخل التطبيق بدل SnackBar السفلي.
  static void showTopMessage(
    BuildContext context,
    String message, {
    bool? success,
  }) {
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final isError = message.contains('تعذر') ||
        message.contains('خطأ') ||
        message.contains('فشل');
    final isSuccess = success ?? !isError;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _FlumeaTopMessage(
        message: message,
        success: isSuccess,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  String _dedupeKey(
    String title,
    String body,
    FlumeaNotificationType type,
  ) {
    final raw = '${type.name}|$title|$body';
    final hash = raw.codeUnits.fold<int>(
      17,
      (value, code) => (value * 31 + code) & 0x7fffffff,
    );
    return 'flumea_notification_last_$hash';
  }

  Future<bool> _isEnabled(FlumeaNotificationType type) async {
    if (type == FlumeaNotificationType.general) return true;

    final prefs = await SharedPreferences.getInstance();

    switch (type) {
      case FlumeaNotificationType.habit:
        return prefs.getBool('flumea_notify_habits') ?? false;
      case FlumeaNotificationType.task:
        return prefs.getBool('flumea_notify_tasks') ?? true;
      case FlumeaNotificationType.achievement:
        return prefs.getBool('flumea_notify_achievements') ?? true;
      case FlumeaNotificationType.water:
        return prefs.getBool('flumea_notify_water') ?? false;
      case FlumeaNotificationType.general:
        return true;
    }
  }
}


class _FlumeaTopMessage extends StatefulWidget {
  const _FlumeaTopMessage({
    required this.message,
    required this.success,
    required this.onDismiss,
  });

  final String message;
  final bool success;
  final VoidCallback onDismiss;

  @override
  State<_FlumeaTopMessage> createState() => _FlumeaTopMessageState();
}

class _FlumeaTopMessageState extends State<_FlumeaTopMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF171C23)
        : const Color(0xFFFFFFFF);
    final foreground = isDark
        ? const Color(0xFFF4F7FA)
        : const Color(0xFF15263B);
    final accent = widget.success
        ? const Color(0xFF19B77A)
        : const Color(0xFFE85D5D);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 18,
      right: 18,
      child: IgnorePointer(
        ignoring: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.success
                                ? Icons.check_rounded
                                : Icons.error_outline_rounded,
                            color: accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: foreground.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
