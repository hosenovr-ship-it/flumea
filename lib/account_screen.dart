import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation.dart';
import 'theme_controller.dart';
import 'services/flumea_notification_service.dart';
import 'privacy_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFEAF3FF);

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  String _fullName = 'حسين';
  String? _avatarUrl;
  bool _loading = true;
  bool _uploadingAvatar = false;

  bool _habitNotifications = true;
  bool _taskNotifications = true;
  bool _achievementNotifications = true;
  bool _waterNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        final name = data?['full_name'] as String?;
        _fullName = (name != null && name.trim().isNotEmpty) ? name : 'حسين';
        _avatarUrl = data?['avatar_url'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAvatar() async {
    if (_uploadingAvatar) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E0E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'اختيار صورة الحساب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.photo_library, color: blue),
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.camera_alt, color: navy),
                  ),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) return;

      await _uploadAvatar(picked);
    } catch (e) {
      if (!mounted) return;
      _showFlumeaNotification(
        title: 'تعذر اختيار الصورة',
        message: 'حدث خطأ أثناء اختيار الصورة.',
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFE53935),
      );
    }
  }

  Future<void> _uploadAvatar(XFile picked) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _uploadingAvatar = true);

    try {
      final extension = _extensionFor(picked.path);
      final contentType = _contentTypeFor(extension);
      final path = '${user.id}/avatar.$extension';

      final oldUrl = _avatarUrl;
      if (oldUrl != null && oldUrl.isNotEmpty) {
        final oldPath = _storagePathFromPublicUrl(oldUrl);
        if (oldPath != null && oldPath != path) {
          await _supabase.storage.from('avatars').remove([oldPath]);
        }
      }

      await _supabase.storage.from('avatars').upload(
            path,
            File(picked.path),
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      final cacheBustedUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'avatar_url': cacheBustedUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() {
        _avatarUrl = cacheBustedUrl;
        _uploadingAvatar = false;
      });

      _showFlumeaNotification(
        title: 'تم تحديث صورة الحساب!',
        message: 'أحسنت! تم حفظ الصورة بنجاح.',
        icon: Icons.check_rounded,
        accent: const Color(0xFF20C997),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _showFlumeaNotification(
        title: 'تعذر رفع الصورة',
        message: e.message,
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFE53935),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _showFlumeaNotification(
        title: 'تعذر حفظ صورة الحساب',
        message: 'حاول مرة أخرى.',
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFE53935),
      );
    }
  }

  String _extensionFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.heic')) return 'heic';
    return 'jpg';
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  String? _storagePathFromPublicUrl(String url) {
    final marker = '/storage/v1/object/public/avatars/';
    final index = url.indexOf(marker);
    if (index == -1) return null;
    final pathWithQuery = url.substring(index + marker.length);
    return pathWithQuery.split('?').first;
  }

  Future<void> _editProfile() async {
    String editedName = _fullName;

    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تعديل الملف الشخصي'),
            content: TextFormField(
              initialValue: _fullName,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                editedName = value;
              },
              onFieldSubmitted: (value) {
                final trimmed = value.trim();
                if (trimmed.isNotEmpty) {
                  Navigator.of(dialogContext).pop(trimmed);
                }
              },
              decoration: const InputDecoration(
                labelText: 'الاسم',
                hintText: 'اكتب اسمك',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final value = editedName.trim();
                  if (value.isNotEmpty) {
                    Navigator.of(dialogContext).pop(value);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );

    if (newName == null || newName.trim().isEmpty) return;

    final trimmedName = newName.trim();
    if (trimmedName == _fullName.trim()) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': trimmedName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _fullName = trimmedName);
      _showFlumeaNotification(
        title: 'تم تحديث الاسم!',
        message: 'تم حفظ اسمك بنجاح.',
        icon: Icons.check_rounded,
        accent: const Color(0xFF20C997),
      );
    } catch (_) {
      if (!mounted) return;
      _showFlumeaNotification(
        title: 'تعذر حفظ الاسم',
        message: 'حاول مرة أخرى.',
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFE53935),
      );
    }
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _habitNotifications = prefs.getBool('flumea_notify_habits') ?? true;
      _taskNotifications = prefs.getBool('flumea_notify_tasks') ?? true;
      _achievementNotifications =
          prefs.getBool('flumea_notify_achievements') ?? true;
      _waterNotifications = prefs.getBool('flumea_notify_water') ?? true;
    });
  }

  Future<void> _setNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _showFlumeaNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
  }) async {
    await FlumeaNotificationService.instance.show(
      title: title,
      body: message,
      type: FlumeaNotificationType.general,
      payload: 'icon=${icon.codePoint};accent=${accent.toARGB32()}',
    );
  }

  Future<void> _showNotifications() async {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary =
        isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final border =
        isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: border),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                title: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: blue,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'الإشعارات',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _notificationItem(
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF20C997),
                      title: 'العادات',
                      message: 'تابع عاداتك اليومية وحافظ على تقدمك.',
                      enabled: _habitNotifications,
                      primary: primary,
                      secondary: secondary,
                      onChanged: (value) {
                        setDialogState(() => _habitNotifications = value);
                        _setNotificationPreference(
                          'flumea_notify_habits',
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _notificationItem(
                      icon: Icons.flag_outlined,
                      color: const Color(0xFF1976D2),
                      title: 'المهام',
                      message: 'راجع مهامك القادمة وأكمل ما عليك.',
                      enabled: _taskNotifications,
                      primary: primary,
                      secondary: secondary,
                      onChanged: (value) {
                        setDialogState(() => _taskNotifications = value);
                        _setNotificationPreference(
                          'flumea_notify_tasks',
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _notificationItem(
                      icon: Icons.emoji_events_outlined,
                      color: const Color(0xFFFFA726),
                      title: 'إنجاز جديد',
                      message: 'استمر في التقدم نحو أهدافك.',
                      enabled: _achievementNotifications,
                      primary: primary,
                      secondary: secondary,
                      onChanged: (value) {
                        setDialogState(
                          () => _achievementNotifications = value,
                        );
                        _setNotificationPreference(
                          'flumea_notify_achievements',
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _notificationItem(
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF42A5F5),
                      title: 'حان وقت شرب الماء',
                      message: 'خذ لحظة واشرب بعض الماء لتحافظ على ترطيبك. 💧',
                      enabled: _waterNotifications,
                      primary: primary,
                      secondary: secondary,
                      onChanged: (value) {
                        setDialogState(() => _waterNotifications = value);
                        _setNotificationPreference(
                          'flumea_notify_water',
                          value,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF223247)
                              : const Color(0xFFEAF3FF),
                          foregroundColor: blue,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'إغلاق',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required bool enabled,
    required Color primary,
    required Color secondary,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF151A20) : const Color(0xFFF7F9FC);
    final border =
        isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 13, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        // LTR هنا حتى يبقى زر التشغيل في أقصى اليسار دائماً.
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF20C997),
            activeThumbColor: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              // RTL: الأيقونة أقصى اليمين، والنص مباشرة إلى يسارها.
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          message,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppearance() async {
    final currentMode = FlumeaThemeController.mode.value;

    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('المظهر'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('فاتح'),
                  trailing: Icon(
                    currentMode == ThemeMode.light
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () => Navigator.of(dialogContext).pop(ThemeMode.light),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('داكن'),
                  trailing: Icon(
                    currentMode == ThemeMode.dark
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () => Navigator.of(dialogContext).pop(ThemeMode.dark),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMode == null || selectedMode == currentMode) return;

    await FlumeaThemeController.setMode(selectedMode);

    if (!mounted) return;

    _showFlumeaNotification(
      title: selectedMode == ThemeMode.dark
          ? 'تم تفعيل الوضع الداكن!'
          : 'تم تفعيل الوضع الفاتح!',
      message: selectedMode == ThemeMode.dark
          ? '🌙 تم حفظ اختيارك وسيبقى مفعّلًا.'
          : '☀️ تم حفظ اختيارك وسيبقى مفعّلًا.',
      icon: selectedMode == ThemeMode.dark
          ? Icons.dark_mode_rounded
          : Icons.light_mode_rounded,
      accent: blue,
    );
  }

  Future<void> _signOut() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final surface = Theme.of(dialogContext).colorScheme.surface;
        final primary = Theme.of(dialogContext).colorScheme.onSurface;
        final secondary =
            isDark ? const Color(0xFFB8C2CC) : const Color(0xFF718096);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Column(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFD93B3B),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تسجيل الخروج',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            content: Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج؟\nيمكنك تسجيل الدخول مرة أخرى في أي وقت.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondary,
                fontSize: 14.5,
                height: 1.6,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blue,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF3B4B5B)
                              : const Color(0xFFD9E4EF),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'البقاء',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD93B3B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _supabase.auth.signOut();
    } catch (_) {
      if (!mounted) return;
      _showFlumeaNotification(
        title: 'تعذر تسجيل الخروج',
        message: 'حاول مرة أخرى.',
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFE53935),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 74,
                  child: Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FLUMEA',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'حسابي',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.05,
                                  fontWeight: FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'إدارة حسابك وتخصيص تجربتك',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7B8798),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // بطاقة الملف الشخصي
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  constraints: const BoxConstraints(minHeight: 174),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? const [
                              Color(0xFF17212B),
                              Color(0xFF1B2733),
                            ]
                          : const [
                              Color(0xFFF2FBFA),
                              Color(0xFFF8FBFF),
                            ],
                    ),
                    border: Border.all(
                      color: Color(0xFFE4EBF2),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE3F5F1),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => const Icon(
                                        Icons.person,
                                        size: 58,
                                        color: navy,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 58,
                                      color: navy,
                                    ),
                            ),
                            Positioned(
                              bottom: -2,
                              left: -4,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: navy,
                                ),
                                child: _uploadingAvatar
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                _loading ? '...' : _fullName,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 25,
                                  height: 1.15,
                                  fontWeight: FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            const SizedBox(
                              width: double.infinity,
                              child: Text(
                                '✨  نسخة أفضل من نفسي كل يوم',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _editProfile,
                                icon: const Icon(
                                  Icons.edit,
                                  size: 19,
                                  color: blue,
                                ),
                                label: const Text(
                                  'تعديل الملف الشخصي',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFE4EBF2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                _sectionCard(
                  title: 'الإعدادات',
                  icon: Icons.settings,
                  children: [
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: FlumeaThemeController.mode,
                      builder: (context, mode, _) {
                        return _settingRow(
                          icon: Icons.dark_mode,
                          title: 'المظهر',
                          subtitle: mode == ThemeMode.dark ? 'داكن' : 'فاتح',
                          color: blue,
                          onTap: _showAppearance,
                        );
                      },
                    ),
                    _settingRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      subtitle: 'تنبيهات المهام والعادات',
                      color: blue,
                      onTap: _showNotifications,
                    ),
                    _settingRow(
                      icon: Icons.lock,
                      title: 'الخصوصية',
                      subtitle: 'إدارة بياناتك',
                      color: navy,
                      last: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrivacyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _sectionCard(
                  title: 'الدعم والمساعدة',
                  icon: Icons.help_outline,
                  children: [
                    _settingRow(
                      icon: Icons.headset_mic,
                      title: 'مركز المساعدة',
                      subtitle: 'الأسئلة الشائعة',
                      color: blue,
                      iconOnLeft: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FlumeaHelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    _settingRow(
                      icon: Icons.mail_outline,
                      title: 'تواصل معنا',
                      subtitle: 'نحن هنا لمساعدتك',
                      color: navy,
                      last: true,
                      iconOnLeft: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FlumeaContactScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFD2D2),
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(
                      Icons.logout,
                      color: Color(0xFFD93B3B),
                    ),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Color(0xFFD93B3B),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FlumeaBottomNavigation(
          selectedIndex: 3,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5EBF1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  icon,
                  color: navy,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool last = false,
    bool iconOnLeft = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final divider = isDark ? const Color(0xFF2A3540) : const Color(0xFFE9EEF3);
    final iconBackground = isDark ? const Color(0xFF223247) : lightBlue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                    color: divider,
                  ),
                ),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: iconOnLeft
              ? [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF718096),
                    size: 27,
                  ),
                  const Spacer(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            title,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : [
                  const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF718096),
                    size: 27,
                  ),
                  const Spacer(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            title,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            subtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 27,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

class FlumeaHelpCenterScreen extends StatelessWidget {
  const FlumeaHelpCenterScreen({super.key});

  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary =
        isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    const Text(
                      'FLUMEA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      color: navy,
                      tooltip: 'رجوع',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: blue,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'مركز المساعدة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: primary,
                              fontSize: 30,
                              height: 1.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'إجابات سريعة لأهم الأسئلة حول FLUMEA.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _faqCard(
                  context,
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF1976D2),
                  question: 'كيف أعدل بيانات حسابي؟',
                  answer:
                      'من صفحة الحساب اضغط على «تعديل الملف الشخصي» لتغيير اسمك أو صورة الحساب.',
                  primary: primary,
                  secondary: secondary,
                ),
                _faqCard(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF20C997),
                  question: 'كيف أتابع المهام والعادات؟',
                  answer:
                      'استخدم صفحة الخطة لإضافة مهامك وعاداتك اليومية، ثم تابع تقدمك من صفحة التقدم.',
                  primary: primary,
                  secondary: secondary,
                ),
                _faqCard(
                  context,
                  icon: Icons.restaurant_outlined,
                  color: const Color(0xFFE6A62C),
                  question: 'كيف أسجل الطعام والسعرات؟',
                  answer:
                      'يمكنك إضافة وجباتك من قسم الطعام وتسجيل السعرات ومتابعة ما تم اختياره ضمن هدفك اليومي.',
                  primary: primary,
                  secondary: secondary,
                ),
                _faqCard(
                  context,
                  icon: Icons.notifications_none_rounded,
                  color: const Color(0xFF42A5F5),
                  question: 'كيف أتحكم بالإشعارات؟',
                  answer:
                      'من صفحة الحساب ثم «الإشعارات» يمكنك تشغيل أو إيقاف أنواع التنبيهات التي تريدها.',
                  primary: primary,
                  secondary: secondary,
                ),
                _faqCard(
                  context,
                  icon: Icons.lock_outline_rounded,
                  color: navy,
                  question: 'أين أجد إعدادات الخصوصية؟',
                  answer:
                      'من صفحة الحساب افتح «الخصوصية» للوصول إلى بيانات الحساب وحذف الحساب وسياسة الخصوصية.',
                  primary: primary,
                  secondary: secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _faqCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String question,
    required String answer,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4EBF2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          title: Text(
            question,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                answer,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: secondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlumeaContactScreen extends StatefulWidget {
  const FlumeaContactScreen({super.key});

  @override
  State<FlumeaContactScreen> createState() => _FlumeaContactScreenState();
}

class _FlumeaContactScreenState extends State<FlumeaContactScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showContactSnackBar(
        'اكتب رسالتك أولاً.',
        icon: Icons.edit_note_rounded,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();
    _subjectController.clear();

    _showContactSnackBar(
      'تم إرسال رسالتك بنجاح! شكرًا لتواصلك معنا. ❤️',
      icon: Icons.check_circle_rounded,
    );
  }

  void _showContactSnackBar(String message, {required IconData icon}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: const Color(0xFF102A4C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          duration: const Duration(seconds: 3),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF55D6B2),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary =
        isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final fieldFill = isDark ? const Color(0xFF151A20) : const Color(0xFFF7F9FC);
    final border = isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    const Text(
                      'FLUMEA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      color: navy,
                      tooltip: 'رجوع',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: blue,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'تواصل معنا',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: primary,
                              fontSize: 30,
                              height: 1.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'نحن هنا لمساعدتك والإجابة عن استفساراتك.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'أرسل لنا رسالتك',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: primary,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _subjectController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'الموضوع',
                          hintText: 'اكتب موضوع الرسالة',
                          filled: true,
                          fillColor: fieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _messageController,
                        minLines: 6,
                        maxLines: 8,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          labelText: 'الرسالة',
                          hintText: 'اكتب رسالتك هنا...',
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: fieldFill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text(
                            'إرسال الرسالة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF17212B)
                        : const Color(0xFFEFFBF8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3540)
                          : const Color(0xFFD7F1EA),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF20B995),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'خصوصيتك مهمة بالنسبة لنا، لذلك لا تكتب كلمات المرور أو أي بيانات حساسة داخل الرسالة.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: primary,
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
