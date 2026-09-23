import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFEAF3FF);
  static const Color background = Color(0xFFF7FAFC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text(
                                  'حسابي',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: navy,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'إدارة حسابك وتخصيص تجربتك',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7B8798),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'FLUMEA',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFFF2FBFA),
                              Color(0xFFF8FBFF),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFE4EBF2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'حسين',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '✨  نسخة أفضل من نفسي كل يوم',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF718096),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  OutlinedButton.icon(
                                    onPressed: () {},
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
                                        vertical: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFE3F5F1),
                                  ),
                                  child: const Icon(
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
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _sectionCard(
                        title: 'الإعدادات',
                        icon: Icons.settings,
                        children: [
                          _settingRow(
                            icon: Icons.dark_mode,
                            title: 'المظهر',
                            subtitle: 'فاتح / داكن',
                            color: blue,
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
                            color: navy,
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
                            color: navy,
                            last: true,
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
                          onPressed: () {},
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFD93B3B),
                          ),
                          label: const Text(
                            'تسجيل الخروج',
                            textAlign: TextAlign.right,
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
            ],
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
        color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navy,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFE9EEF3),
                ),
              ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chevron_left,
            color: Color(0xFF718096),
            size: 27,
          ),
          const Spacer(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8290A2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightBlue,
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
    );
  }
}
