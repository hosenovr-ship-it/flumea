import 'package:flutter/material.dart';
import 'account_screen.dart';
import 'plan_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int _selectedIndex = 0;  

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF102A4C);
    const green = Color(0xFF18B56A);
    const grayText = Color(0xFF7B8798);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الهيدر
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFE8F5EF),
                      child: Icon(
                        Icons.person,
                        color: darkBlue,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'صباح الخير، حسين 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: darkBlue,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'يوم جديد، فرصة جديدة لتصبح أفضل نسخة منك.',
                          style: TextStyle(
                            fontSize: 14,
                            color: grayText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // الطقس
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE5E9EE),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.orange,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '25°C',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkBlue,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'بغداد',
                        style: TextStyle(
                          fontSize: 15,
                          color: grayText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // تقدم اليوم
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقدمك اليوم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _ProgressItem(
                            icon: Icons.track_changes,
                            value: '3/5',
                            label: 'المهام',
                          ),
                          _ProgressItem(
                            icon: Icons.local_fire_department,
                            value: '2/3',
                            label: 'العادات',
                          ),
                          _ProgressItem(
                            icon: Icons.favorite_border,
                            value: '1,450',
                            label: 'سعرة حرارية',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'استمر، أنت على الطريق الصحيح! ✨',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // خطة اليوم
                _SectionCard(
                  title: 'خطة اليوم',
                  icon: Icons.calendar_month_rounded,
                  child: Column(
                    children: [
                      _TaskItem(
                        time: '9:00 ص',
                        title: 'دراسة 3 ساعات',
                        category: 'دراسة',
                      ),
                      _TaskItem(
                        time: '12:30 م',
                        title: 'التمرين في النادي',
                        category: 'صحة',
                        completed: true,
                      ),
                      _TaskItem(
                        time: '4:00 م',
                        title: 'قراءة 30 دقيقة',
                        category: 'تطوير ذات',
                      ),
                      _TaskItem(
                        time: '6:30 م',
                        title: 'مشروع العمل',
                        category: 'عمل',
                      ),
                      _TaskItem(
                        time: '9:30 م',
                        title: 'مراجعة اليوم',
                        category: 'روتين',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // الطعام والعادات
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SmallCard(
                        title: 'عاداتك',
                        icon: Icons.sync_rounded,
                        child: Column(
                          children: const [
                            _HabitItem(
                              icon: '💧',
                              title: 'شرب 2 لتر ماء',
                              completed: true,
                            ),
                            _HabitItem(
                              icon: '📖',
                              title: 'قراءة 20 دقيقة',
                              completed: true,
                            ),
                            _HabitItem(
                              icon: '🏋️',
                              title: 'تمرين 30 دقيقة',
                            ),
                            SizedBox(height: 10),
                            Text(
                              'عرض الكل ←',
                              style: TextStyle(
                                color: Color(0xFF2870B5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SmallCard(
                        title: 'طعامك اليوم',
                        icon: Icons.restaurant_rounded,
                        child: Column(
                          children: const [
                            Text(
                              '1,450',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: darkBlue,
                              ),
                            ),
                            Text(
                              'من 2,200 سعرة حرارية',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: grayText,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              '+ تسجيل وجبة',
                              style: TextStyle(
                                color: green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // المساعد الذكي
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F3),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '✨ مساعدك الذكي',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: darkBlue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'لديك 5 مهام اليوم. هل تريد أن أرتبها حسب الأولوية؟',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: grayText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.smart_toy_rounded,
                          color: green,
                          size: 42,
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
    bottomNavigationBar: SafeArea(
  child: Container(
    height: 72,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(
          color: Color(0xFFE5E9EE),
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: _NavItem(
            icon: Icons.person_outline,
            label: 'الحساب',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _NavItem(
            icon: Icons.insights_outlined,
            label: 'التقدم',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProgressScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFF18B56A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        Expanded(
          child: _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'الخطة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlanScreen(),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _NavItem(
            icon: Icons.home_rounded,
            label: 'الرئيسية',
            selected: true,
            onTap: () {},
          ),
        ),
      ],
    ),
  ),
),
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF55D6A0),
          size: 28,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E9EE),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF102A4C),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A4C),
                ),
              ),
              const Spacer(),
              const Text(
                'عرض الكل',
                style: TextStyle(
                  color: Color(0xFF2870B5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String time;
  final String title;
  final String category;
  final bool completed;

  const _TaskItem({
    required this.time,
    required this.title,
    required this.category,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F2F5),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7B8798),
              ),
            ),
          ),
          Icon(
            completed
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: completed
                ? const Color(0xFF18B56A)
                : const Color(0xFFB5BDC7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF102A4C),
                decoration:
                    completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2870B5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SmallCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E9EE),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF102A4C),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _HabitItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool completed;

  const _HabitItem({
    required this.icon,
    required this.title,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF102A4C),
              ),
            ),
          ),
          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 20,
            color: completed
                ? const Color(0xFF18B56A)
                : const Color(0xFFB5BDC7),
          ),
        ],
      ),
    );
  }
}
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected
                ? const Color(0xFF18B56A)
                : const Color(0xFF7B8798),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF18B56A)
                  : const Color(0xFF7B8798),
            ),
          ),
        ],
      ),
    );
  }
}
