import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);
  static const Color mint = Color(0xFF2BC7A5);
  static const Color lightBlue = Color(0xFFEAF3FF);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final primary = scheme.onSurface;
    final secondary = isDark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);
    final card = isDark ? const Color(0xFF121820) : Colors.white;
    final border = isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);
    final iconBlue = isDark ? const Color(0xFF1C3857) : lightBlue;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Text(
                      'FLUMEA',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF6EA7E6) : navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'رجوع',
                      icon: Icon(
                        Icons.arrow_forward,
                        color: primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: iconBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: blue,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الخصوصية',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: primary,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تحكم في بياناتك وأمان حسابك وخصوصيتك',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _PrivacyOption(
                  title: 'أمان الحساب',
                  subtitle: 'تغيير كلمة المرور وإدارة الأمان.',
                  icon: Icons.shield_outlined,
                  iconColor: mint,
                  iconBackground: isDark
                      ? const Color(0xFF12372F)
                      : const Color(0xFFE4F8F3),
                  cardColor: card,
                  borderColor: isDark
                      ? const Color(0xFF24483F)
                      : const Color(0xFFCDEFE6),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountSecurityScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _PrivacyOption(
                  title: 'بيانات الحساب',
                  subtitle: 'عرض وإدارة بياناتك الشخصية.',
                  icon: Icons.person_outline_rounded,
                  iconColor: blue,
                  iconBackground: iconBlue,
                  cardColor: card,
                  borderColor: border,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccountDataScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _PrivacyOption(
                  title: 'حذف الحساب',
                  subtitle: 'حذف حسابك وبياناتك نهائيًا.',
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFE45B5B),
                  iconBackground: isDark
                      ? const Color(0xFF3A2024)
                      : const Color(0xFFFFE9E9),
                  cardColor: isDark
                      ? const Color(0xFF171315)
                      : const Color(0xFFFFFBFB),
                  borderColor: isDark
                      ? const Color(0xFF543038)
                      : const Color(0xFFFFD4D4),
                  onTap: () => _showDeleteNotice(context),
                ),
                const SizedBox(height: 16),
                _PrivacyOption(
                  title: 'سياسة الخصوصية',
                  subtitle: 'اطّلع على كيفية جمع واستخدام بياناتك.',
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF8067D8),
                  iconBackground: isDark
                      ? const Color(0xFF2D2746)
                      : const Color(0xFFF0ECFF),
                  cardColor: card,
                  borderColor: border,
                  onTap: () => _showInfo(
                    context,
                    'سياسة الخصوصية',
                    'سنضع هنا نص سياسة الخصوصية الكامل الخاص بـ FLUMEA قبل إطلاق التطبيق.',
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF102C29)
                        : const Color(0xFFEAFBF7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF22534C)
                          : const Color(0xFFD1F2EA),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF17443D)
                              : const Color(0xFFDDF7F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: mint,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بياناتك آمنة معنا',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: primary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'نحرص على حماية بياناتك الشخصية وفق أعلى معايير الأمان والخصوصية.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 14,
                                height: 1.5,
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
          ),
        ),
      ),
    );
  }

  static void _showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, textAlign: TextAlign.left),
        content: Text(message, textAlign: TextAlign.left),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteNotice(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'حذف الحساب',
          textAlign: TextAlign.left,
        ),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟\\n\\nسيتم حذف حسابك وبياناتك المرتبطة به نهائيًا، ولا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.left,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE45B5B),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteAccount(context);
            },
            child: const Text('نعم، حذف الحساب'),
          ),
        ],
      ),
    );
  }

  static Future<void> _deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'لم يتم العثور على الحساب الحالي.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            textDirection: TextDirection.rtl,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  'جارٍ حذف الحساب...',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await Supabase.instance.client.rpc('delete_my_account');

      if (!context.mounted) return;

      try {
        await Supabase.instance.client.auth.signOut(
          scope: SignOutScope.local,
        );
      } catch (_) {}

      if (!context.mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message.isNotEmpty
                  ? error.message
                  : 'تعذر حذف الحساب. حاول مرة أخرى.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop();

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء حذف الحساب. حاول مرة أخرى.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        );
    }
  }
}

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 6) {
      _showMessage('كلمة المرور يجب أن تحتوي على 6 أحرف أو أكثر.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('كلمتا المرور غير متطابقتين.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showMessage('تم تغيير كلمة المرور بنجاح 🔐');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.message.isNotEmpty
            ? error.message
            : 'تعذر تغيير كلمة المرور. حاول مرة أخرى.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.onSurface;
    final secondary = isDark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);
    final background = theme.scaffoldBackgroundColor;
    final card = isDark ? const Color(0xFF121820) : Colors.white;
    final border = isDark ? const Color(0xFF2A3540) : const Color(0xFFE4EBF2);

    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'الحساب الحالي';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Text(
                      'FLUMEA',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6EA7E6)
                            : PrivacyScreen.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'رجوع',
                      icon: Icon(
                        Icons.arrow_forward,
                        color: primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C3857)
                            : PrivacyScreen.lightBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: PrivacyScreen.mint,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أمان الحساب',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: primary,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'إدارة كلمة المرور وحماية حسابك',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C3857)
                              : PrivacyScreen.lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: isDark
                              ? const Color(0xFF6EA7E6)
                              : PrivacyScreen.blue,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحساب',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              email,
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'تغيير كلمة المرور',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'اختر كلمة مرور جديدة لحماية حسابك.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _PasswordField(
                        controller: _newPasswordController,
                        label: 'كلمة المرور الجديدة',
                        visible: _newPasswordVisible,
                        onToggle: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _PasswordField(
                        controller: _confirmPasswordController,
                        label: 'تأكيد كلمة المرور',
                        visible: _confirmPasswordVisible,
                        onToggle: () {
                          setState(() {
                            _confirmPasswordVisible =
                                !_confirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'يجب أن تحتوي كلمة المرور على 6 أحرف أو أكثر.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PrivacyScreen.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF26384B)
                                : const Color(0xFFB9CCE0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'حفظ كلمة المرور',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF102C29)
                        : const Color(0xFFEAFBF7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF22534C)
                          : const Color(0xFFD1F2EA),
                    ),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF17443D)
                              : const Color(0xFFDDF7F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: PrivacyScreen.mint,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'حسابك محمي. لا تشارك كلمة المرور مع أي شخص.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = isDark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);

    return TextField(
      controller: controller,
      obscureText: !visible,
      textDirection: TextDirection.ltr,
      style: TextStyle(color: primary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondary),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isDark
              ? const Color(0xFF6EA7E6)
              : PrivacyScreen.blue,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          tooltip: visible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
          icon: Icon(
            visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: secondary,
          ),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F151B) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2A3540)
                : const Color(0xFFE4EBF2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2A3540)
                : const Color(0xFFE4EBF2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: PrivacyScreen.blue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  const _PrivacyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Icon(
                Icons.chevron_left_rounded,
                color: secondary,
                size: 30,
              ),
              const Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({super.key});

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final result = await client
        .from('profiles')
        .select('full_name, avatar_url, created_at')
        .eq('id', user.id)
        .maybeSingle();

    return result;
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.onSurface;
    final secondary = isDark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);
    final background = theme.scaffoldBackgroundColor;
    final card = isDark ? const Color(0xFF121820) : Colors.white;
    final border = isDark
        ? const Color(0xFF2A3540)
        : const Color(0xFFE4EBF2);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _AccountDataError(
                      message: 'تعذر تحميل بيانات الحساب.',
                      onRetry: _refresh,
                    );
                  }

                  final user = Supabase.instance.client.auth.currentUser;
                  final profile = snapshot.data;
                  final fullName =
                      (profile?['full_name'] as String?)?.trim() ?? '';
                  final avatarUrl =
                      (profile?['avatar_url'] as String?)?.trim() ?? '';
                  final email = user?.email ?? 'غير متوفر';
                  final createdAt =
                      (profile?['created_at'] as String?) ?? user?.createdAt;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          Text(
                            'FLUMEA',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF6EA7E6)
                                  : PrivacyScreen.navy,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'رجوع',
                            icon: Icon(
                              Icons.arrow_forward,
                              color: primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C3857)
                                  : PrivacyScreen.lightBlue,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: isDark
                                  ? const Color(0xFF6EA7E6)
                                  : PrivacyScreen.blue,
                              size: 31,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'بيانات الحساب',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 31,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'عرض وإدارة بياناتك الشخصية',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: isDark
                                    ? const Color(0xFF1C3857)
                                    : PrivacyScreen.lightBlue,
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 48,
                                        color: isDark
                                            ? const Color(0xFF6EA7E6)
                                            : PrivacyScreen.blue,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              fullName.isEmpty ? 'لم يتم تحديد الاسم' : fullName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AccountDataItem(
                        icon: Icons.person_outline_rounded,
                        title: 'الاسم',
                        value:
                            fullName.isEmpty ? 'لم يتم تحديد الاسم' : fullName,
                        cardColor: card,
                        borderColor: border,
                        iconColor: PrivacyScreen.blue,
                        iconBackground: isDark
                            ? const Color(0xFF1C3857)
                            : PrivacyScreen.lightBlue,
                      ),
                      const SizedBox(height: 14),
                      _AccountDataItem(
                        icon: Icons.email_outlined,
                        title: 'البريد الإلكتروني',
                        value: email,
                        cardColor: card,
                        borderColor: border,
                        iconColor: PrivacyScreen.mint,
                        iconBackground: isDark
                            ? const Color(0xFF12372F)
                            : const Color(0xFFE4F8F3),
                      ),
                      const SizedBox(height: 14),
                      _AccountDataItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'تاريخ إنشاء الحساب',
                        value: _formatDate(createdAt),
                        cardColor: card,
                        borderColor: border,
                        iconColor: const Color(0xFF8067D8),
                        iconBackground: isDark
                            ? const Color(0xFF2D2746)
                            : const Color(0xFFF0ECFF),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF102C29)
                              : const Color(0xFFEAFBF7),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF22534C)
                                : const Color(0xFFD1F2EA),
                          ),
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF17443D)
                                    : const Color(0xFFDDF7F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: PrivacyScreen.mint,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'هذه البيانات تخص حسابك الحالي ويتم تحميلها مباشرة من حسابك في FLUMEA.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'غير متوفر';
    }

    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'غير متوفر';
    }

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day/$month/$year';
  }
}

class _AccountDataItem extends StatelessWidget {
  const _AccountDataItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.cardColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color cardColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDataError extends StatelessWidget {
  const _AccountDataError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFB8C2CC)
        : const Color(0xFF8290A2);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: secondary,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
