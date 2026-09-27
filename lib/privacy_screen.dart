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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DeleteAccountScreen(),
      ),
    );
  }
}


class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isDeleting = false;

  static const Color danger = Color(0xFFE45B5B);
  static const Color dangerLight = Color(0xFFFFE9E9);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final messenger = ScaffoldMessenger.of(context);
    final password = _passwordController.text.trim();
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
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

    if (password.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'أدخل كلمة المرور لتأكيد حذف الحساب.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        );
      return;
    }

    setState(() => _isDeleting = true);

    try {
      // نتحقق من كلمة المرور أولًا قبل تنفيذ الحذف النهائي.
      await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await client.rpc('delete_my_account');

      if (!mounted) return;

      try {
        await client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message.isNotEmpty
                  ? 'كلمة المرور غير صحيحة.'
                  : 'تعذر التحقق من كلمة المرور.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

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
      if (!mounted) return;

      setState(() => _isDeleting = false);

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

    final dangerCard = isDark ? const Color(0xFF24181B) : const Color(0xFFFFFBFB);
    final dangerBorder =
        isDark ? const Color(0xFF5A3038) : const Color(0xFFFFD0D0);
    final inputFill = isDark ? const Color(0xFF1A2028) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Text(
                      'FLUMEA',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF6EA7E6) : PrivacyScreen.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(context).pop(),
                      tooltip: 'رجوع',
                      icon: Icon(
                        Icons.arrow_forward,
                        color: primary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // عنوان الصفحة
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3A2024)
                            : dangerLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: danger,
                        size: 31,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حذف الحساب',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: primary,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'حذف حسابك وجميع بياناتك نهائيًا.',
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
                const SizedBox(height: 28),

                // تنبيه مهم
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A171A) : const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: dangerBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF6D2C35)
                              : const Color(0xFFFFDCDC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: danger,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنبيه مهم',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFF8D8D)
                                    : const Color(0xFFAA2D2D),
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سيتم حذف حسابك وبياناتك المرتبطة به نهائيًا، ولا يمكن التراجع عن هذا الإجراء.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: primary,
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // البيانات التي سيتم حذفها
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ما الذي سيتم حذفه؟',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'سيتم حذف جميع بياناتك بشكل نهائي، بما في ذلك:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DeleteDataRow(
                        icon: Icons.person_outline_rounded,
                        iconColor: PrivacyScreen.blue,
                        iconBackground: isDark
                            ? const Color(0xFF1C3857)
                            : PrivacyScreen.lightBlue,
                        title: 'بيانات ملفك الشخصي',
                        subtitle: 'الاسم، الصورة، ومعلومات الحساب.',
                        primary: primary,
                        secondary: secondary,
                        border: border,
                      ),
                      _DeleteDataRow(
                        icon: Icons.task_alt_rounded,
                        iconColor: PrivacyScreen.mint,
                        iconBackground: isDark
                            ? const Color(0xFF12372F)
                            : const Color(0xFFE4F8F3),
                        title: 'الخطط والمهام والعادات',
                        subtitle: 'جميع خططك اليومية وسجلات العادات.',
                        primary: primary,
                        secondary: secondary,
                        border: border,
                      ),
                      _DeleteDataRow(
                        icon: Icons.restaurant_outlined,
                        iconColor: const Color(0xFFE79B22),
                        iconBackground: isDark
                            ? const Color(0xFF3A2D18)
                            : const Color(0xFFFFF5DF),
                        title: 'سجلات الطعام والسعرات',
                        subtitle: 'جميع وجباتك وسجلات السعرات الغذائية.',
                        primary: primary,
                        secondary: secondary,
                        border: border,
                      ),
                      _DeleteDataRow(
                        icon: Icons.bar_chart_rounded,
                        iconColor: const Color(0xFF8067D8),
                        iconBackground: isDark
                            ? const Color(0xFF2D2746)
                            : const Color(0xFFF0ECFF),
                        title: 'الأهداف وإحصائيات التقدم',
                        subtitle: 'جميع أهدافك وإحصائياتك.',
                        primary: primary,
                        secondary: secondary,
                        border: border,
                      ),
                      _DeleteDataRow(
                        icon: Icons.description_outlined,
                        iconColor: isDark
                            ? const Color(0xFFB8C2CC)
                            : const Color(0xFF7B8794),
                        iconBackground: isDark
                            ? const Color(0xFF252B33)
                            : const Color(0xFFF0F3F6),
                        title: 'جميع البيانات الأخرى',
                        subtitle: 'أي بيانات أخرى مرتبطة بحسابك في FLUMEA.',
                        primary: primary,
                        secondary: secondary,
                        border: border,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // تأكيد كلمة المرور
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
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
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: PrivacyScreen.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تأكيد كلمة المرور',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'أدخل كلمة مرور حسابك لتأكيد الحذف.',
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        enabled: !_isDeleting,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          hintTextDirection: TextDirection.rtl,
                          filled: true,
                          fillColor: inputFill,
                          prefixIcon: IconButton(
                            onPressed: _isDeleting
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: isDark
                                  ? const Color(0xFF9AA7B4)
                                  : const Color(0xFF8290A2),
                            ),
                          ),
                          suffixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: PrivacyScreen.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: border,
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // أزرار الإجراء
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: OutlinedButton(
                          onPressed: _isDeleting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1B2940)
                                : const Color(0xFFEAF1FF),
                            foregroundColor:
                                isDark ? const Color(0xFFBFD9FF) : PrivacyScreen.navy,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: FilledButton(
                          onPressed: _isDeleting ? null : _deleteAccount,
                          style: FilledButton.styleFrom(
                            backgroundColor: danger,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                isDark ? const Color(0xFF673238) : const Color(0xFFF3A5A5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isDeleting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'نعم، حذف الحساب',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteDataRow extends StatelessWidget {
  const _DeleteDataRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.secondary,
    required this.border,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Color primary;
  final Color secondary;
  final Color border;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: border))
            : null,
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
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: secondary,
                    fontSize: 13.5,
                    height: 1.4,
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
