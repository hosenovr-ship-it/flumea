import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);
  static const Color green = Color(0xFF18B77A);
  static const Color lightBlue = Color(0xFFEAF4FF);
  static const Color lightGreen = Color(0xFFEAF9F2);
  static const Color lightYellow = Color(0xFFFFF8E8);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFD),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // العنوان
                Row(
                  children: [
                    const Icon(
                      Icons.bar_chart_rounded,
                      color: navy,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'التقدم',
                      style: TextStyle(
                        color: navy,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  'رحلتك نحو نسخة أفضل من نفسك',
                  style: TextStyle(
                    color: Color(0xFF7B8798),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 18),

                // الفترات الزمنية
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE4EAF1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _periodItem('اليوم', true),
                      _periodItem('الأسبوع', false),
                      _periodItem('الشهر', false),
                      _periodItem('الكل', false),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // بطاقات الإحصائيات
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '17',
                        title: 'أيام النشاط',
                        background: lightGreen,
                        iconColor: green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.track_changes_rounded,
                        value: '12',
                        title: 'العادات المكتملة',
                        background: lightBlue,
                        iconColor: blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.flag_rounded,
                        value: '5',
                        title: 'الأهداف قيد العمل',
                        background: lightYellow,
                        iconColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // معدل إكمال العادات
                _habitChart(),

                const SizedBox(height: 14),

                // توزيع الوقت + التحسن
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _timeCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _improvementCard()),
                  ],
                ),

                const SizedBox(height: 14),

                // الإنجازات
                _achievementsCard(),
              ],
            ),
          ),
        ),

        // شريط التنقل السفلي
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  Widget _periodItem(String title, bool selected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? blue : navy,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 38,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: iconColor == blue ? blue : navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitChart() {
    final values = [0.55, 0.68, 0.60, 0.70, 0.57, 0.80, 0.62];
    final names = [
      'الصحة',
      'الرياضة',
      'الدراسة',
      'القراءة',
      'العمل',
      'الماء',
      'التأمل',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EBF1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: navy,
                size: 25,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'معدل إكمال العادات',
                  style: TextStyle(
                    color: navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Text(
                      '%71',
                      style: TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'معدل اليوم',
                      style: TextStyle(
                        color: navy,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'اليوم - الثلاثاء 23 أبريل',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFF7B8798),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                values.length,
                (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 28,
                                height: 130 * values[index],
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            names[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF66758A),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeCard() {
    return Container(
      height: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EBF1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'توزيع وقتك اليومي',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.access_time_rounded,
                color: navy,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'إجمالي الوقت: 6.5 ساعات',
            style: TextStyle(
              color: Color(0xFF7B8798),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 125,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: 0.72,
                          strokeWidth: 20,
                          backgroundColor: const Color(0xFFE9EEF4),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(blue),
                        ),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '6.5',
                            style: TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'ساعات',
                            style: TextStyle(
                              color: Color(0xFF7B8798),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Legend(
                        color: blue,
                        title: 'دراسة',
                        value: '2.5 س',
                      ),
                      _Legend(
                        color: green,
                        title: 'عمل',
                        value: '1.5 س',
                      ),
                      _Legend(
                        color: Colors.orange,
                        title: 'رياضة',
                        value: '1.0 س',
                      ),
                      _Legend(
                        color: Colors.purple,
                        title: 'قراءة',
                        value: '0.5 س',
                      ),
                      _Legend(
                        color: Color(0xFF9AA7B8),
                        title: 'أخرى',
                        value: '1.0 س',
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

  Widget _improvementCard() {
    return Container(
      height: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EBF1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'تحسنك عبر الوقت',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: navy,
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'مقارنة بالأيام الماضية',
            style: TextStyle(
              color: Color(0xFF7B8798),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                color: green,
                size: 25,
              ),
              SizedBox(width: 5),
              Text(
                '+28%',
                style: TextStyle(
                  color: green,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const Text(
            'تحسن عام',
            style: TextStyle(
              color: Color(0xFF7B8798),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(),
            ),
          ),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الجمعة', style: _smallText),
              Text('الأحد', style: _smallText),
              Text('الاثنين', style: _smallText),
              Text('الثلاثاء', style: _smallText),
              Text('الأربعاء', style: _smallText),
              Text('الخميس', style: _smallText),
              Text('السبت', style: _smallText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EBF1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: navy,
                  size: 25,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'أبرز إنجازاتك',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _achievement(
            Icons.local_fire_department_rounded,
            green,
            'أكملت 2 أيام متتالية',
            'استمر في هذا المستوى الرائع!',
          ),

          _achievement(
            Icons.school_rounded,
            blue,
            'أنجزت 20 جلسة دراسة',
            'خطوة كبيرة نحو هدفك!',
          ),

          _achievement(
            Icons.fitness_center_rounded,
            Colors.orange,
            'حافظت على عادة الرياضة',
            'الالتزام يصنع الفرق',
          ),
        ],
      ),
    );
  }

  Widget _achievement(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE9EEF4),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
  title,
  textAlign: TextAlign.right,
  style: const TextStyle(
    color: navy,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  ),
),
const SizedBox(height: 5),
Text(
  subtitle,
  textAlign: TextAlign.right,
  style: const TextStyle(
    color: Color(0xFF7B8798),
    fontSize: 12,
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
                  
                  
                  
                    
  
