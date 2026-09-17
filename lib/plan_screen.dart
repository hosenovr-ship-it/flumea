import 'package:flutter/material.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF102A4C);
    const blue = Color(0xFF1478D4);
    const cyan = Color(0xFF20C7B7);
    const lightBlue = Color(0xFFEAF4FF);
    const lightGreen = Color(0xFFEAF9F4);
    const gray = Color(0xFF7B8798);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FBFF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            child: Column(
              children: [
                // =========================
                // العنوان
                // =========================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'الخطة',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
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
                              color: gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =========================
                // زر اليوم
                // =========================
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'اليوم',
                            style: TextStyle(
                              color: navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.calendar_month_outlined,
                            color: navy,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =========================
                // شريط الأيام
                // =========================
                SizedBox(
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
                ),

                const SizedBox(height: 14),

                // =========================
                // ملخص اليوم
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF9F4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
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
                            const SizedBox(height: 8),
                            const Text(
                              'خطوات صغيرة تصنع فرقاً كبيراً',
                              style: TextStyle(
                                fontSize: 14,
                                color: gray,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                ),

                const SizedBox(height: 14),

                // =========================
                // المهام اليومية
                // =========================
                Container(
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
                            const Icon(
                              Icons.format_list_bulleted,
                              color: navy,
                              size: 27,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
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
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: navy,
                                    size: 21,
                                  ),
                                  SizedBox(width: 4),
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
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: blue,
                                size: 24,
                              ),
                              SizedBox(width: 5),
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
                ),

                const SizedBox(height: 14),

                // =========================
                // البطاقات السفلية
                // =========================
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

        // =========================
        // الشريط السفلي
        // =========================
        bottomNavigationBar: _bottomNavigation(
          navy: navy,
          blue: blue,
          cyan: cyan,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // اليوم
  // --------------------------------------------------

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
          color: selected ? blue : const Color(0xFFF5F8FC),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF52647A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF102A4C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ملخص
  // --------------------------------------------------

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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF102A4C),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF66758A),
          ),
        ),
      ],
    );
  }

  Widget _progressCircle() {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.625,
            strokeWidth: 8,
            backgroundColor: const Color(0xFFDDE4ED),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF20C7B7),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '5/8',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A4C),
                ),
              ),
              Text(
                'مكتملة',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF66758A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // المهمة
  // --------------------------------------------------

  Widget _task({
    required String time,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required bool completed,
  }) {
    return Container(
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
            color: const Color(0xFF78879A),
            size: 20,
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 65,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF65758A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              tag,
          
