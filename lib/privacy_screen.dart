import 'package:flutter/material.dart';

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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الخصوصية',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: primary,
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تحكم في بياناتك وأمان حسابك وخصوصيتك',
                            textAlign: TextAlign.right,
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
                  borderColor: isDark ? const Color(0xFF24483F) : const Color(0xFFCDEFE6),
                  onTap: () => _showInfo(context, 'أمان الحساب', 'يمكنك من هنا إدارة إعدادات أمان حسابك.'),
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
                  onTap: () => _showInfo(context, 'بيانات الحساب', 'بيانات حسابك محفوظة في ملفك الشخصي ويمكنك تعديل الاسم والصورة من صفحة الحساب.'),
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
                  cardColor: isDark ? const Color(0xFF171315) : const Color(0xFFFFFBFB),
                  borderColor: isDark ? const Color(0xFF543038) : const Color(0xFFFFD4D4),
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
                  onTap: () => _showInfo(context, 'سياسة الخصوصية', 'سنضع هنا نص سياسة الخصوصية الكامل الخاص بـ FLUMEA قبل إطلاق التطبيق.'),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF102C29) : const Color(0xFFEAFBF7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? const Color(0xFF22534C) : const Color(0xFFD1F2EA),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF17443D) : const Color(0xFFDDF7F0),
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'بياناتك آمنة معنا',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: primary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'نحرص على حماية بياناتك الشخصية وفق أعلى معايير الأمان والخصوصية.',
                              textAlign: TextAlign.right,
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

  static void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: Text(message, textAlign: TextAlign.right),
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
        title: const Text('حذف الحساب', textAlign: TextAlign.right),
        content: const Text(
          'حذف الحساب إجراء نهائي. لن ننفذه الآن حتى نتأكد من إعداد آلية الحذف الآمنة وربطها بقاعدة البيانات.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
        ],
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
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
