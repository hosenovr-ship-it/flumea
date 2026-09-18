import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF102A4C);
    const blue = Color(0xFF1478D4);
    const cyan = Color(0xFF20C7B7);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FBFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(navy),
                const SizedBox(height: 14),

                _buildTodayButton(navy),
                const SizedBox(height: 14),

                _buildDays(blue),
                const SizedBox(height: 14),

                _buildSummary(navy, blue, cyan),
                const SizedBox(height: 14),

                _buildTasks(navy, blue, cyan),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _weeklyGoals(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dailyHabits(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const FlumeaBottomNavigation(
  selectedIndex: 1,
),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(Color navy) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'الخطة',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: navy,
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'نظم يومك وحقق أهدافك',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7B8798),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // TODAY BUTTON
  // =========================================================

  Widget _buildTodayButton(Color navy) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF9F4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Text(
                'اليوم',
                style: TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_month_outlined,
                color: navy,
                size: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DAYS
  // =========================================================

  Widget _buildDays(Color blue) {
    return SizedBox(
      height: 82,
      child: Row(
        children: [
          _dayBox('الأحد', '20', true, blue),
          _dayBox('الاثنين', '21', false, blue),
          _dayBox('الثلاثاء', '22', false, blue),
          _dayBox('الأربعاء', '23', false, blue),
          _dayBox('الخميس', '24', false, blue),
          _dayBox('الجمعة', '25', false, blue),
          _dayBox('السبت', '26', false, blue),
        ],
      ),
    );
  }

  Widget _dayBox(
    String day,
    String number,
    bool selected,
    Color blue,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: selected
              ? blue
              : const Color(0xFFF5F8FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? blue
                : const Color(0xFFE7ECF2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : const Color(0xFF52647A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected
                    ? Colors.white
                    : const Color(0xFF102A4C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SUMMARY
  // =========================================================

  Widget _buildSummary(
    Color navy,
    Color blue,
    Color cyan,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text(
                          'خطة اليوم',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          '☀️',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'خطوات صغيرة تصنع فرقاً كبيراً',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B8798),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  Icons.check_circle,
                  '5',
                  'مهام مكتملة',
                  cyan,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons.gps_fixed,
                  '3',
                  'مهام متبقية',
                  blue,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons.local_fire_department,
                  '17',
                  'يوم نشط',
                  const Color(0xFFEF5350),
                ),
              ),
              Expanded(
                child: _progressCircle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    IconData icon,
    String number,
    String title,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          number,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF102A4C),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF66758A),
          ),
        ),
      ],
    );
  }

  Widget _progressCircle() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: CircularProgressIndicator(
              value: 0.625,
              strokeWidth: 7,
              backgroundColor:
                  const Color(0xFFDDE4ED),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFF20C7B7),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '5/8',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A4C),
                ),
              ),
              Text(
                'مكتملة',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF66758A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TASKS
  // =========================================================

  Widget _buildTasks(
    Color navy,
    Color blue,
    Color cyan,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              15,
              18,
              10,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_list_bulleted,
                  color: navy,
                  size: 27,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المهام اليوم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: navy,
                        size: 21,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'الكل',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _task(
            time: '6:00 ص',
            title: 'الاستيقاظ',
            subtitle: 'ابدأ يومك بطاقة',
            tag: 'عادات ☀️',
            tagColor: cyan,
            completed: true,
          ),

          _task(
            time: '6:30 ص',
            title: 'الرياضة',
            subtitle: 'تمرين لمدة 45 دقيقة',
            tag: 'صحة 🏋️',
            tagColor: const Color(0xFFEF5350),
            completed: false,
          ),

          _task(
            time: '8:00 ص',
            title: 'الإفطار',
            subtitle: 'وجبة صحية ومتوازنة',
            tag: 'غذاء 🍴',
            tagColor: const Color(0xFFFFA726),
            completed: false,
          ),

          _task(
            time: '9:00 ص',
            title: 'الدراسة',
            subtitle: 'مذاكرة المواد المهمة',
            tag: 'تعليم 🎓',
            tagColor: blue,
            completed: true,
          ),

          _task(
            time: '12:00 م',
            title: 'المهام الشخصية',
            subtitle: 'إنجاز الأعمال المطلوبة',
            tag: 'إنتاجية 💼',
            tagColor: const Color(0xFF7E57C2),
            completed: false,
          ),

          _task(
            time: '4:00 م',
            title: 'القراءة',
            subtitle: 'قراءة 30 دقيقة',
            tag: 'تطوير الذات 📖',
            tagColor: const Color(0xFF8E44AD),
            completed: false,
          ),

          _task(
            time: '7:00 م',
            title: 'مراجعة اليوم',
            subtitle: 'تقييم ما تم إنجازه',
            tag: 'مراجعة 📊',
            tagColor: cyan,
            completed: false,
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: blue,
                    size: 24,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'إضافة مهمة جديدة',
                    style: TextStyle(
                      color: blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _task({
    required String time,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required bool completed,
  }) {
  bool isCompleted = completed;

return StatefulBuilder(
  builder: (context, setState) {

    return GestureDetector(
      onTap: () {
        setState(() {
          isCompleted = !isCompleted;
        });
      },
      child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEDF0F4),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.more_vert,
            color: Color(0xFF78879A),
            size: 20,
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 55,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF65758A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Text(
              tag,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: tagColor,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? const Color(0xFF9AA5B1)
                        : const Color(0xFF102A4C),
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF66758A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 22,
            color: isCompleted
                ? const Color(0xFF20C7B7)
                : const Color(0xFFB8C1CC),
                ),
],
),
),
);
},
);
  }

  // =========================================================
  // WEEKLY GOALS
  // =========================================================

  Widget _weeklyGoals() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E9EE),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                size: 21,
                color: Color(0xFF102A4C),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'أهداف الأسبوع',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _goalRow(
            'الدراسة',
            '4/5',
            0.8,
            const Color(0xFF1478D4),
            ),
                 _goalRow(
            'الرياضة',
            '3/4',
            0.75,
            const Color(0xFF20C7B7),
          ),

          _goalRow(
            'القراءة',
            '2/3',
            0.66,
            const Color(0xFF8E44AD),
          ),
        ],
      ),
    );
  }

  Widget _goalRow(
    String title,
    String value,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF52647A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EDF3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DAILY HABITS
  // =========================================================

  Widget _dailyHabits() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E9EE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.repeat,
                size: 21,
                color: Color(0xFF102A4C),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'عادات اليوم',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _habitRow(
            'شرب الماء',
            Icons.water_drop_outlined,
            true,
          ),

          _habitRow(
            'الرياضة',
            Icons.fitness_center_outlined,
            false,
          ),

          _habitRow(
            'القراءة',
            Icons.menu_book_outlined,
            true,
          ),
        ],
      ),
    );
  }

  Widget _habitRow(
    String title,
    IconData icon,
    bool completed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 19,
            color: completed
                ? const Color(0xFF20C7B7)
                : const Color(0xFFB8C1CC),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: completed
                    ? const Color(0xFF66758A)
                    : const Color(0xFF102A4C),
              ),
            ),
          ),
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF7B8798),
          ),
        ],
      ),
    );
  }
}

