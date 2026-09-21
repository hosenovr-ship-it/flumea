import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const darkBlue = Color(0xFF102A4C);
  static const blue = Color(0xFF2870B5);
  static const green = Color(0xFF18B56A);
  static const teal = Color(0xFF32C6B4);
  static const grayText = Color(0xFF7B8798);
  static const background = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDailyProgress(),
                const SizedBox(height: 20),
                _buildTodayPlan(),
                const SizedBox(height: 16),
                _buildHabitsAndFood(),
                const SizedBox(height: 16),
                _buildSmartAssistant(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const FlumeaBottomNavigation(
          selectedIndex: 0,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;

    final rawName = metadata?['full_name'] ??
        metadata?['name'] ??
        metadata?['display_name'];
    final avatarUrl = metadata?['avatar_url']?.toString();

    String userName = rawName?.toString().trim() ?? '';
    if (userName.isEmpty && user?.email != null) {
      userName = user!.email!.split('@').first.trim();
    }
    if (userName.isEmpty) {
      userName = 'صديقي';
    }

    final hour = DateTime.now().hour;
    final greeting = hour >= 5 && hour < 12
        ? 'صباح الخير'
        : 'مساء الخير';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE9EEF5),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: darkBlue,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                '$greeting، $userName 👋',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'يوم جديد، فرصة جديدة لتصبح أفضل نسخة منك.',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14,
                  color: grayText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Column(
          children: [
            const SizedBox(height: 3),
            const _FlumeaMark(),
            const SizedBox(height: 5),
            const Text(
              'FLUMEA',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: darkBlue,
                fontSize: 11,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyProgress() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0B2D52),
            Color(0xFF062548),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'تقدمك اليوم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _ProgressStat(
                      icon: Icons.track_changes_rounded,
                      value: '3/5',
                      label: 'المهام',
                      iconColor: Color(0xFF4B9FFF),
                    ),
                    _VerticalDivider(),
                    _ProgressStat(
                      icon: Icons.local_fire_department_rounded,
                      value: '2/3',
                      label: 'العادات',
                      iconColor: Color(0xFF49D59B),
                    ),
                    _VerticalDivider(),
                    _ProgressStat(
                      icon: Icons.favorite_border_rounded,
                      value: '1,450',
                      label: 'سعرة حرارية',
                      iconColor: Color(0xFF8C78FF),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
          const SizedBox(width: 15),
          const _DailyProgressRing(
            progress: 0.65,
            value: '65%',
            label: 'اليوم',
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPlan() {
    return _LargeCard(
      child: Column(
        children: [
          const _CardTitle(
            title: 'خطة اليوم',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 5),
          const _HomeTask(
            time: '9:00 ص',
            title: 'دراسة 3 ساعات',
            category: 'دراسة',
            dotColor: Color(0xFF4AA4D9),
          ),
          const _HomeTask(
            time: '12:30 م',
            title: 'التمرين في النادي',
            category: 'صحة',
            completed: true,
            dotColor: Color(0xFF3CC28D),
          ),
          const _HomeTask(
            time: '4:00 م',
            title: 'قراءة 30 دقيقة',
            category: 'تطوير ذات',
            dotColor: Color(0xFF4AA4D9),
          ),
          const _HomeTask(
            time: '6:30 م',
            title: 'مشروع العمل',
            category: 'عمل',
            dotColor: Color(0xFFF2BF2C),
          ),
          const _HomeTask(
            time: '9:30 م',
            title: 'مراجعة اليوم',
            category: 'روتين',
            dotColor: Color(0xFF4AA4D9),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                '3 من 5 مكتملة',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.60,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8ECEF),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(green),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'تبقى مهمتان',
                style: TextStyle(
                  color: grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsAndFood() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildHabitsCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildFoodCard()),
      ],
    );
  }

  Widget _buildHabitsCard() {
    return _SmallCard(
      title: 'عاداتك',
      icon: Icons.history_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _HomeHabit(
            icon: '💧',
            title: 'شرب 2 لتر ماء',
            completed: true,
          ),
          _HomeHabit(
            icon: '📖',
            title: 'قراءة 20 دقيقة',
            completed: true,
          ),
          _HomeHabit(
            icon: '↔',
            title: 'تمرين 30 دقيقة',
          ),
          SizedBox(height: 7),
          Text(
            'عرض الكل  ←',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard() {
    return _SmallCard(
      title: 'طعامك اليوم',
      icon: Icons.restaurant_rounded,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _CaloriesRing(
                  progress: 1450 / 2200,
                  value: '1,450',
                  subtitle: 'من 2,200\nسعرة حرارية',
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MealLine(
                      name: 'الفطور',
                      calories: '420 سعرة',
                      icon: '☀️',
                    ),
                    _MealLine(
                      name: 'الغداء',
                      calories: '660 سعرة',
                      icon: '☀️',
                    ),
                    _MealLine(
                      name: 'العشاء',
                      calories: '350 سعرة',
                      icon: '🌙',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F3),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'تسجيل وجبة  +',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: green,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAssistant() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '✨ مساعدك الذكي',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'لديك 5 مهام اليوم. هل تريد أن أرتبها حسب الأولوية؟',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF8FD9C0),
                    ),
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  child: const Center(
                    child: Text(
                      'رتب الآن',
                      style: TextStyle(
                        color: green,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5EE),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 82,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7F8),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF0B3E6D),
                  size: 47,
                ),
                const Positioned(
                  left: 24,
                  top: 30,
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFF39D4C1),
                    size: 5,
                  ),
                ),
                const Positioned(
                  right: 24,
                  top: 30,
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFF39D4C1),
                    size: 5,
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

class _FlumeaMark extends StatelessWidget {
  const _FlumeaMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 31,
      child: CustomPaint(
        painter: _FlumeaMarkPainter(),
      ),
    );
  }
}

class _FlumeaMarkPainter extends CustomPainter {
  const _FlumeaMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF32C6B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final y = 7.0 + (i * 9.0);
      path.moveTo(4, y + 2);
      path.cubicTo(10, y - 2, 14, y - 2, 20, y + 2);
      path.cubicTo(26, y + 6, 31, y + 6, 36, y + 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _ProgressStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xBFFFFFFF),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      color: const Color(0x557B9AB5),
    );
  }
}

class _DailyProgressRing extends StatelessWidget {
  final double progress;
  final String value;
  final String label;

  const _DailyProgressRing({
    required this.progress,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              color: const Color(0x334E83AD),
            ),
          ),
          SizedBox(
            width: 112,
            height: 112,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: const Color(0xFF20B9D4),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF36C7E0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeCard extends StatelessWidget {
  final Widget child;

  const _LargeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CardTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 25,
          color: HomeScreen.darkBlue,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: HomeScreen.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTask extends StatelessWidget {
  final String time;
  final String title;
  final String category;
  final bool completed;
  final Color dotColor;

  const _HomeTask({
    required this.time,
    required this.title,
    required this.category,
    required this.dotColor,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 51),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F2F5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _categoryColor(category).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: _categoryColor(category),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: HomeScreen.darkBlue,
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            completed
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: completed
                ? HomeScreen.green
                : const Color(0xFFC6CCD3),
            size: 25,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 56,
            child: Text(
              time,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 11,
                color: HomeScreen.grayText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'صحة':
        return const Color(0xFF3EBB91);
      case 'تطوير ذات':
        return const Color(0xFF8A52B8);
      case 'عمل':
        return const Color(0xFFE3AD1D);
      default:
        return HomeScreen.blue;
    }
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
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: HomeScreen.darkBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: HomeScreen.darkBlue,
                  ),
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

class _HomeHabit extends StatelessWidget {
  final String icon;
  final String title;
  final bool completed;

  const _HomeHabit({
    required this.icon,
    required this.title,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HomeScreen.darkBlue,
                decoration:
                    completed ? TextDecoration.none : null,
              ),
            ),
          ),
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 23,
            color: completed
                ? HomeScreen.green
                : const Color(0xFFD2D6DC),
          ),
        ],
      ),
    );
  }
}

class _CaloriesRing extends StatelessWidget {
  final double progress;
  final String value;
  final String subtitle;

  const _CaloriesRing({
    required this.progress,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              color: const Color(0xFFE8ECEF),
            ),
          ),
          SizedBox(
            width: 108,
            height: 108,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: HomeScreen.green,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: HomeScreen.darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: HomeScreen.grayText,
                  fontSize: 9,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealLine extends StatelessWidget {
  final String name;
  final String calories;
  final String icon;

  const _MealLine({
    required this.name,
    required this.calories,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: HomeScreen.darkBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  calories,
                  style: const TextStyle(
                    color: HomeScreen.grayText,
                    fontSize: 8,
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
