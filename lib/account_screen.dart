import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bottom_navigation.dart';
import 'theme_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF35A9FF);
  static const Color lightBlue = Color(0xFF223247);
  static const Color background = Color(0xFF0B151E);

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  String _fullName = 'حسين';
  String? _avatarUrl;
  bool _loading = true;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: const Color(0xFF111216),
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
                    color: const Color(0xFF34404A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'اختيار صورة الحساب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.photo_library, color: blue),
                  ),
                  title: Text('اختيار من المعرض'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lightBlue,
                    child: Icon(Icons.camera_alt, color: navy),
                  ),
                  title: Text('التقاط صورة بالكاميرا'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة.')),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث صورة الحساب بنجاح ❤️‍🔥')),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر رفع الصورة: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ صورة الحساب.')),
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
            title: Text('تعديل الملف الشخصي'),
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
                child: Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final value = editedName.trim();
                  if (value.isNotEmpty) {
                    Navigator.of(dialogContext).pop(value);
                  }
                },
                child: Text('حفظ'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الاسم بنجاح ❤️‍🔥')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ الاسم.')),
      );
    }
  }

  Future<void> _showAppearance() async {
    final currentMode = FlumeaThemeController.mode.value;

    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('المظهر'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: currentMode,
                  title: Text('فاتح'),
                  secondary: Icon(Icons.light_mode),
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(dialogContext).pop(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: currentMode,
                  title: Text('داكن'),
                  secondary: Icon(Icons.dark_mode),
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(dialogContext).pop(value);
                    }
                  },
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedMode == ThemeMode.dark
              ? 'تم تفعيل الوضع الداكن 🌙'
              : 'تم تفعيل الوضع الفاتح ☀️',
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تسجيل الخروج.')),
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
                      Text(
                        'FLUMEA',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Color(0xFF9AA6B2),
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
                              Color(0xFF18242E),
                              Color(0xFF111216),
                            ]
                          : const [
                              Color(0xFFF2FBFA),
                              Color(0xFFF8FBFF),
                            ],
                    ),
                    border: Border.all(
                      color: Color(0xFF34404A),
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
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF203A45)
                                    : const Color(0xFFE3F5F1),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: 58,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 58,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                            ),
                            Positioned(
                              bottom: -2,
                              left: -4,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.onSurface,
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
                                style: TextStyle(
                                  fontSize: 25,
                                  height: 1.15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Color(0xFF9AA6B2),
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
                                  size: 19,
                                  color: blue,
                                ),
                                label: Text(
                                  'تعديل الملف الشخصي',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFF111216),
                                  side: const BorderSide(
                                    color: Color(0xFF34404A),
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
                      icon: Icons.notifications_none,
                      title: 'الإشعارات',
                      subtitle: 'تنبيهات المهام والعادات',
                      color: blue,
                    ),
                    _settingRow(
                      icon: Icons.lock,
                      title: 'الخصوصية',
                      subtitle: 'إدارة بياناتك',
                      color: Theme.of(context).colorScheme.onSurface,
                      last: true,
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
                    ),
                    _settingRow(
                      icon: Icons.mail_outline,
                      title: 'تواصل معنا',
                      subtitle: 'نحن هنا لمساعدتك',
                      color: Theme.of(context).colorScheme.onSurface,
                      last: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A181B),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF573238),
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _signOut,
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFFD93B3B),
                    ),
                    label: Text(
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
        bottomNavigationBar: const FlumeaBottomNavigation(
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
        color: const Color(0xFF111216),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF34404A),
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
                  color: Theme.of(context).colorScheme.onSurface,
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
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = isDark ? const Color(0xFFB8C2CC) : const Color(0xFF8290A2);
    final divider = isDark ? const Color(0xFF29343E) : const Color(0xFFE9EEF3);
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
          children: [
            Icon(
              Icons.chevron_left,
              color: Color(0xFF9AA6B2),
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
