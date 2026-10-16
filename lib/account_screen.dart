// ignore_for_file: unused_field, unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_navigation.dart';
import 'theme_controller.dart';
import 'services/flumea_notification_service.dart';
import 'privacy_screen.dart';
import 'login_screen.dart';

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

  String _fullName = 'صديقي';
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

      final metadata = user.userMetadata;
      final metadataName = (metadata?['full_name'] ??
              metadata?['name'] ??
              metadata?['display_name'])
          ?.toString()
          .trim();
      final metadataAvatar = (metadata?['avatar_url'] ?? metadata?['picture'])
          ?.toString()
          .trim();
      final emailName = user.email?.split('@').first.trim();

      final storedName = data?['full_name']?.toString().trim() ?? '';
      final storedAvatar = data?['avatar_url']?.toString().trim() ?? '';

      // استخدم بيانات الحساب الحقيقية عند عدم وجود ملف شخصي،
      // أو عند وجود الاسم الافتراضي القديم الذي كان يظهر ثابتاً.
      final resolvedName = storedName.isNotEmpty && storedName != 'حسين'
          ? storedName
          : ((metadataName != null && metadataName.isNotEmpty)
              ? metadataName
              : ((emailName != null && emailName.isNotEmpty)
                  ? emailName
                  : 'صديقي'));
      final resolvedAvatar = storedAvatar.isNotEmpty
          ? storedAvatar
          : ((metadataAvatar != null && metadataAvatar.isNotEmpty)
              ? metadataAvatar
              : null);

      // احفظ القيم الحقيقية في profiles عند الحاجة حتى تستخدمها
      // الصفحة الرئيسية وصفحة الحساب معاً.
      final updates = <String, dynamic>{
        'id': user.id,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (storedName.isEmpty || storedName == 'حسين') {
        updates['full_name'] = resolvedName;
      }
      if (storedAvatar.isEmpty && resolvedAvatar != null) {
        updates['avatar_url'] = resolvedAvatar;
      }
      if (updates.length > 2) {
        await _supabase.from('profiles').upsert(updates);
      }

      if (!mounted) return;

      setState(() {
        _fullName = resolvedName;
        _avatarUrl = resolvedAvatar;
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
                    fontSize: 18,
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
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => FlumeaEditProfileScreen(
          initialName: _fullName,
          initialAvatarUrl: _avatarUrl,
        ),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;
    await _loadProfile();

  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // سياسة الإشعارات الجديدة: نُبقي فقط التنبيهات المهمة افتراضيًا.
    // المهام والإنجازات مهمة، بينما العادات وشرب الماء اختياريان.
    if (prefs.getInt('flumea_notification_policy_version') != 2) {
      await prefs.setBool('flumea_notify_habits', false);
      await prefs.setBool('flumea_notify_tasks', true);
      await prefs.setBool('flumea_notify_achievements', true);
      await prefs.setBool('flumea_notify_water', false);
      await prefs.setInt('flumea_notification_policy_version', 2);
    }

    if (!mounted) return;

    setState(() {
      _habitNotifications = prefs.getBool('flumea_notify_habits') ?? false;
      _taskNotifications = prefs.getBool('flumea_notify_tasks') ?? true;
      _achievementNotifications =
          prefs.getBool('flumea_notify_achievements') ?? true;
      _waterNotifications = prefs.getBool('flumea_notify_water') ?? false;
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
    // هذه رسائل داخل التطبيق وليست إشعارات خارجية.
    // نعرضها داخل FLUMEA حتى لا يتحول كل خطأ بسيط إلى إشعار مزعج للمستخدم.
    if (!mounted) return;
    FlumeaNotificationService.showTopMessage(
      context,
      message,
      success: false,
    );
  }

  Future<void> _showNotifications() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsScreen(),
      ),
    );
    await _loadNotificationPreferences();
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
                    size: MediaQuery.sizeOf(context).width < 600 ? 23 * 0.90 : 23,
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
                            fontSize: 13.5,
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
                            fontSize: 11.2,
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
      barrierDismissible: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final surface = Theme.of(dialogContext).colorScheme.surface;
        final primary = Theme.of(dialogContext).colorScheme.onSurface;
        final secondary = isDark
            ? const Color(0xFFB8C2CC)
            : const Color(0xFF8290A2);
        final border = isDark
            ? const Color(0xFF2A3540)
            : const Color(0xFFE4EBF2);

        Widget option({
          required ThemeMode mode,
          required IconData icon,
          required String title,
          required String subtitle,
        }) {
          final selected = currentMode == mode;
          final accent = mode == ThemeMode.dark
              ? const Color(0xFF6EA8FF)
              : const Color(0xFFF2A93B);

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(dialogContext).pop(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                        ? const Color(0xFF1B2B3D)
                        : const Color(0xFFEAF3FF))
                    : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? accent : border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: accent, size: 24.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? accent : secondary,
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B2B3D)
                            : lightBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: blue,
                        size: MediaQuery.sizeOf(context).width < 600 ? 27 * 0.90 : 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'المظهر',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: primary,
                              fontSize: 19.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'اختر الشكل الذي يناسب تجربتك في FLUMEA',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 11.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                option(
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  title: 'فاتح',
                  subtitle: 'ألوان واضحة ومشرقة',
                ),
                const SizedBox(height: 10),
                option(
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  title: 'داكن',
                  subtitle: 'مظهر هادئ ومريح للعين',
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMode == null || selectedMode == currentMode) return;

    await FlumeaThemeController.setMode(selectedMode);
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
                  child: Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFD93B3B),
                    size: MediaQuery.sizeOf(context).width < 600 ? 32 * 0.90 : 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تسجيل الخروج',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 20.7,
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
                fontSize: 13.1,
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

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.sizeOf(context).width < 600 ? 0.90 : 1.0,
            ),
          ),
          child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 74,
                  child: Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLUMEA',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4.0,
                          color: isDark ? Colors.white : navy,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'الحساب',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 27,
                                  height: 1.05,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFF2F6FA)
                                      : navy,
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
                                  fontSize: 14.4,
                                  color: isDark
                                      ? const Color(0xFFB8C2CC)
                                      : const Color(0xFF7B8798),
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
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: MediaQuery.sizeOf(context).width < 600 ? 58 * 0.90 : 58,
                                        color: navy,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: MediaQuery.sizeOf(context).width < 600 ? 58 * 0.90 : 58,
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
                                    : Icon(
                                        Icons.camera_alt,
                                        size: MediaQuery.sizeOf(context).width < 600 ? 18 * 0.90 : 18,
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
                                style: TextStyle(
                                  fontSize: 22.5,
                                  height: 1.15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : navy,
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
                                  fontSize: 12.6,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _editProfile,
                                icon: Icon(
                                  Icons.edit,
                                  size: MediaQuery.sizeOf(context).width < 600 ? 19 * 0.90 : 19,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                  size: MediaQuery.sizeOf(context).width < 600 ? 28 * 0.90 : 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 19.8,
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
                      size: MediaQuery.sizeOf(context).width < 600 ? 27 * 0.90 : 27,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_left,
                    color: Color(0xFF718096),
                    size: MediaQuery.sizeOf(context).width < 600 ? 27 * 0.90 : 27,
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
                              fontSize: 15.3,
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
                              fontSize: 11.7,
                              color: secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : [
                  Icon(
                    Icons.chevron_left,
                    color: Color(0xFF718096),
                    size: MediaQuery.sizeOf(context).width < 600 ? 27 * 0.90 : 27,
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
                              fontSize: 15.3,
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
                              fontSize: 11.7,
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
                      size: MediaQuery.sizeOf(context).width < 600 ? 27 * 0.90 : 27,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}


class FlumeaEditProfileScreen extends StatefulWidget {
  const FlumeaEditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialAvatarUrl,
  });

  final String initialName;
  final String? initialAvatarUrl;

  @override
  State<FlumeaEditProfileScreen> createState() =>
      _FlumeaEditProfileScreenState();
}

class _FlumeaEditProfileScreenState extends State<FlumeaEditProfileScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _nameController;

  String? _avatarUrl;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _avatarUrl = widget.initialAvatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_uploadingAvatar) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final primary = Theme.of(sheetContext).colorScheme.onSurface;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'تغيير صورة الحساب',
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF3FF),
                      child: Icon(Icons.photo_library_rounded, color: blue),
                    ),
                    title: const Text('اختيار من المعرض'),
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.gallery),
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF3FF),
                      child: Icon(Icons.camera_alt_rounded, color: navy),
                    ),
                    title: const Text('التقاط صورة بالكاميرا'),
                    onTap: () =>
                        Navigator.pop(sheetContext, ImageSource.camera),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return;
      await _uploadAvatar(picked);
    } catch (_) {
      if (!mounted) return;
      _showMessage('تعذر اختيار الصورة.');
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

      await _supabase.storage.from('avatars').upload(
        path,
        File(picked.path),
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
      final cacheBustedUrl =
          '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

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
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _showMessage('تعذر حفظ الصورة، حاول مرة أخرى.');
    }
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)
        ? (ext == 'jpeg' ? 'jpg' : ext)
        : 'jpg';
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('اكتب اسمك أولاً.');
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'avatar_url': _avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.of(context).pop(name);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('تعذر حفظ الملف الشخصي، حاول مرة أخرى.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary =
        isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final surface = Theme.of(context).colorScheme.surface;
    final border =
        isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF182433)
                    : const Color(0xFFEAF3FF),
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_forward_rounded),
                color: primary,
                tooltip: 'رجوع',
              ),
            ),
          ),
          title: Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? const [Color(0xFF17212B), Color(0xFF1B2733)]
                        : const [Color(0xFFEFFBF8), Color(0xFFF4F8FF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 124,
                            height: 124,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF243140)
                                  : const Color(0xFFE3F5F1),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3A4B5F)
                                    : Colors.white,
                                width: 5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.person_rounded,
                                      size: MediaQuery.sizeOf(context).width < 600 ? 68 * 0.90 : 68,
                                      color: isDark ? Colors.white70 : navy,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: MediaQuery.sizeOf(context).width < 600 ? 68 * 0.90 : 68,
                                    color: isDark ? Colors.white70 : navy,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: -2,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: navy,
                                shape: BoxShape.circle,
                              ),
                              child: _uploadingAvatar
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: MediaQuery.sizeOf(context).width < 600 ? 21 * 0.90 : 21,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'صورتك، هويتك في FLUMEA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary,
                        fontSize: 17.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'اضغط على الصورة لتغييرها',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondary, fontSize: 12.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'معلوماتك الشخصية',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        hintText: 'اكتب اسمك',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: blue,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF151A20) : const Color(0xFFF7F9FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: blue, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _saving ? 'جارٍ الحفظ...' : 'حفظ التغييرات',
                    style: const TextStyle(
                      fontSize: 14.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: blue.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                    Text(
                      'FLUMEA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF182433)
                            : const Color(0xFFEAF3FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF314155)
                              : const Color(0xFFDCE7F2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        color: primary,
                        tooltip: 'رجوع',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'مركز المساعدة',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: primary,
                                fontSize: 27,
                                height: 1.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'إجابات سريعة لأهم الأسئلة حول FLUMEA.',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.headset_mic_rounded,
                        color: blue,
                        size: MediaQuery.sizeOf(context).width < 600 ? 35 * 0.90 : 35,
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
            child: Icon(icon, color: color, size: 22.5),
          ),
          title: Text(
            question,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: primary,
              fontSize: 14.4,
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
                  fontSize: 12.6,
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
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        final top = MediaQuery.of(overlayContext).padding.top + 12;

        return Positioned(
          top: top,
          left: 18,
          right: 18,
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF102A4C),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
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
                          size: MediaQuery.sizeOf(context).width < 600 ? 22 * 0.90 : 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.1,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
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
                    Text(
                      'FLUMEA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF182433)
                            : const Color(0xFFEAF3FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF314155)
                              : const Color(0xFFDCE7F2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        color: primary,
                        tooltip: 'رجوع',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'تواصل معنا',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: primary,
                                fontSize: 27,
                                height: 1.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'نحن هنا لمساعدتك والإجابة عن استفساراتك.',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.mail_outline_rounded,
                        color: blue,
                        size: MediaQuery.sizeOf(context).width < 600 ? 35 * 0.90 : 35,
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
                          fontSize: 18.9,
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
                              fontSize: 14.4,
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
                      Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF20B995),
                        size: MediaQuery.sizeOf(context).width < 600 ? 32 * 0.90 : 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'خصوصيتك مهمة بالنسبة لنا، لذلك لا تكتب كلمات المرور أو أي بيانات حساسة داخل الرسالة.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: primary,
                            fontSize: 12.2,
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


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _mint = Color(0xFF20C997);

  bool _habits = false;
  bool _tasks = true;
  bool _achievements = true;
  bool _water = false;
  bool _loading = true;
  TimeOfDay _waterTime = const TimeOfDay(hour: 9, minute: 0);
  List<TimeOfDay> _waterTimes = <TimeOfDay>[const TimeOfDay(hour: 9, minute: 0)];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _habits = prefs.getBool('flumea_notify_habits') ?? false;
      _tasks = prefs.getBool('flumea_notify_tasks') ?? true;
      _achievements = prefs.getBool('flumea_notify_achievements') ?? true;
      _water = prefs.getBool('flumea_notify_water') ?? false;
      _waterTime = TimeOfDay(
        hour: prefs.getInt('flumea_water_hour') ?? 9,
        minute: prefs.getInt('flumea_water_minute') ?? 0,
      );
      final savedTimes = prefs.getStringList('flumea_water_times') ?? <String>[];
      _waterTimes = savedTimes.map((value) {
        final parts = value.split(':');
        if (parts.length != 2) return _waterTime;
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? _waterTime.hour,
          minute: int.tryParse(parts[1]) ?? _waterTime.minute,
        );
      }).toList();
      if (_waterTimes.isEmpty) _waterTimes = <TimeOfDay>[_waterTime];
      _loading = false;
    });
  }

  Future<void> _setOption(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flumea_notifications_master_enabled', true);
    await prefs.setBool(key, value);
    if (key == 'flumea_notify_water') {
      if (value) {
        for (var i = 0; i < _waterTimes.length && i < 20; i++) {
          await FlumeaNotificationService.instance.scheduleWaterReminder(_waterTimes[i]);
        }
      } else {
        await FlumeaNotificationService.instance.cancelWaterReminder();
      }
    }
  }

  Future<void> _cancelAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flumea_notifications_master_enabled', false);
    await prefs.setBool('flumea_notify_habits', false);
    await prefs.setBool('flumea_notify_tasks', false);
    await prefs.setBool('flumea_notify_achievements', false);
    await prefs.setBool('flumea_notify_water', false);
    await FlumeaNotificationService.instance.cancelAllNotifications();
    if (!mounted) return;
    setState(() {
      _habits = false;
      _tasks = false;
      _achievements = false;
      _water = false;
    });
    FlumeaNotificationService.showTopMessage(
      context,
      'تم إيقاف جميع الإشعارات',
      success: true,
    );
  }

  Future<void> _chooseWaterTime({int? index}) async {
    final initial = index != null && index < _waterTimes.length
        ? _waterTimes[index]
        : _waterTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: index == null ? 'أضف وقت تذكير شرب الماء' : 'عدّل وقت التذكير',
      cancelText: 'إلغاء',
      confirmText: 'حفظ الوقت',
    );
    if (selected == null || !mounted) return;

    final updated = List<TimeOfDay>.from(_waterTimes);
    if (index == null) {
      if (updated.any((t) => t.hour == selected.hour && t.minute == selected.minute)) {
        FlumeaNotificationService.showTopMessage(context, 'هذا الوقت مضاف بالفعل');
        return;
      }
      if (updated.length >= 20) {
        FlumeaNotificationService.showTopMessage(context, 'يمكنك إضافة 20 وقت تذكير كحد أقصى');
        return;
      }
      updated.add(selected);
    } else {
      updated[index] = selected;
    }
    updated.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    setState(() {
      _waterTimes = updated;
      _waterTime = updated.first;
    });
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = updated.map((t) {
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }).toList();
    await prefs.setStringList('flumea_water_times', savedTimes);
    await prefs.setInt('flumea_water_hour', _waterTime.hour);
    await prefs.setInt('flumea_water_minute', _waterTime.minute);
    if (_water) {
      await FlumeaNotificationService.instance.cancelWaterReminder();
      for (var i = 0; i < _waterTimes.length && i < 20; i++) {
        await FlumeaNotificationService.instance.scheduleWaterReminder(_waterTimes[i]);
      }
    }
  }

  Future<void> _removeWaterTime(int index) async {
    if (_waterTimes.length <= 1) {
      FlumeaNotificationService.showTopMessage(context, 'احتفظ بوقت واحد على الأقل للتذكير');
      return;
    }
    final updated = List<TimeOfDay>.from(_waterTimes)..removeAt(index);
    setState(() {
      _waterTimes = updated;
      _waterTime = updated.first;
    });
    final prefs = await SharedPreferences.getInstance();
    final savedTimes = updated.map((t) {
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }).toList();
    await prefs.setStringList('flumea_water_times', savedTimes);
    if (_water) {
      await FlumeaNotificationService.instance.cancelWaterReminder();
      for (var i = 0; i < _waterTimes.length && i < 20; i++) {
        await FlumeaNotificationService.instance.scheduleWaterReminder(_waterTimes[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.onSurface;
    final secondary = isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final card = scheme.surface;
    final border = isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            textDirection: TextDirection.ltr,
                            children: [
                              Text(
                                'FLUMEA',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF102A4C),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                tooltip: 'رجوع',
                                icon: Icon(Icons.arrow_forward_rounded, color: primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            textDirection: TextDirection.ltr,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Icon(Icons.notifications_active_outlined, color: _blue, size: 27),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text('الإشعارات', textAlign: TextAlign.right, style: TextStyle(color: primary, fontSize: 25, fontWeight: FontWeight.w800))),
                                    const SizedBox(height: 4),
                                    SizedBox(width: double.infinity, child: Text('اختر التنبيهات التي تساعدك دون إزعاج.', textAlign: TextAlign.right, style: TextStyle(color: secondary, fontSize: 13, height: 1.4))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _notificationCard(
                            icon: Icons.check_circle_outline_rounded,
                            color: _mint,
                            title: 'العادات',
                            subtitle: 'تابع عاداتك اليومية وحافظ على تقدمك.',
                            value: _habits,
                            onChanged: (v) async { setState(() => _habits = v); await _setOption('flumea_notify_habits', v); },
                            card: card, border: border, primary: primary, secondary: secondary,
                          ),
                          const SizedBox(height: 12),
                          _notificationCard(
                            icon: Icons.flag_outlined,
                            color: _blue,
                            title: 'المهام',
                            subtitle: 'تذكيرات تساعدك على إكمال خطتك.',
                            value: _tasks,
                            onChanged: (v) async { setState(() => _tasks = v); await _setOption('flumea_notify_tasks', v); },
                            card: card, border: border, primary: primary, secondary: secondary,
                          ),
                          const SizedBox(height: 12),
                          _notificationCard(
                            icon: Icons.emoji_events_outlined,
                            color: const Color(0xFFFFA726),
                            title: 'إنجاز جديد',
                            subtitle: 'احتفل بتقدمك عندما تحقق إنجازًا.',
                            value: _achievements,
                            onChanged: (v) async { setState(() => _achievements = v); await _setOption('flumea_notify_achievements', v); },
                            card: card, border: border, primary: primary, secondary: secondary,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF42A5F5).withValues(alpha: 0.13), shape: BoxShape.circle), child: const Icon(Icons.water_drop_outlined, color: Color(0xFF42A5F5))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'حان وقت شرب الماء',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'أضف أوقاتاً متعددة للتذكير يومياً.',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: secondary,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch.adaptive(value: _water, activeTrackColor: _mint, onChanged: (v) async { setState(() => _water = v); await _setOption('flumea_notify_water', v); }),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ..._waterTimes.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final time = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(color: isDark ? const Color(0xFF202A35) : const Color(0xFFEAF3FF), borderRadius: BorderRadius.circular(14)),
                                      child: Row(children: [
                                        IconButton(tooltip: 'حذف الوقت', onPressed: () => _removeWaterTime(index), icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE45B5B), size: 20)),
                                        IconButton(tooltip: 'تعديل الوقت', onPressed: () => _chooseWaterTime(index: index), icon: const Icon(Icons.edit_outlined, color: _blue, size: 19)),
                                        const Spacer(),
                                        Text('وقت التذكير ${index + 1}', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 10),
                                        Text(time.format(context), style: const TextStyle(color: _blue, fontSize: 14, fontWeight: FontWeight.w800)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.schedule_rounded, color: _blue, size: 20),
                                      ]),
                                    ),
                                  );
                                }),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _chooseWaterTime(),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('إضافة وقت تذكير'),
                                    style: OutlinedButton.styleFrom(foregroundColor: _blue, side: BorderSide(color: _blue.withValues(alpha: 0.35)), padding: const EdgeInsets.symmetric(vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _cancelAll,
                              icon: const Icon(Icons.notifications_off_outlined),
                              label: const Text('إلغاء الكل'),
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE45B5B), side: const BorderSide(color: Color(0xFFE8B9B9)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: FilledButton.styleFrom(backgroundColor: isDark ? const Color(0xFF223247) : const Color(0xFFEAF3FF), foregroundColor: _blue, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: const Text('تم', style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _notificationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color card,
    required Color border,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(19), border: Border.all(color: border)),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: _mint),
          const SizedBox(width: 9),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.13), shape: BoxShape.circle), child: Icon(icon, color: color, size: 21)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [SizedBox(width: double.infinity, child: Text(title, textAlign: TextAlign.right, style: TextStyle(color: primary, fontSize: 13.5, fontWeight: FontWeight.w800))), const SizedBox(height: 3), SizedBox(width: double.infinity, child: Text(subtitle, textAlign: TextAlign.right, style: TextStyle(color: secondary, fontSize: 11.5, height: 1.35)))])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
