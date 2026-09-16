import 'package:flutter/material.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF102A4C);
    const Color green = Color(0xFF18B56A);
    const Color grayText = Color(0xFF7B8798);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 35, 24, 28),
              child: Column(
                children: [
                  // علامة النجاح
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 180,
                        height: 150,
                      ),

                      // دائرة النجاح
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),

                      // الزخارف
                      Positioned(
                        top: 5,
                        left: 20,
                        child: _Confetti(
                          color: Color(0xFF18B56A),
                          rotation: -0.5,
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 15,
                        child: _Confetti(
                          color: Color(0xFFE83E8C),
                          rotation: 0.4,
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 5,
                        child: _Confetti(
                          color: Color(0xFF2276E8),
                          rotation: 0.5,
                        ),
                      ),
                      Positioned(
                        top: 75,
                        right: 0,
                        child: _Confetti(
                          color: Color(0xFFFF8A00),
                          rotation: -0.4,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 65,
                        child: _Confetti(
                          color: Color(0xFF18B56A),
                          rotation: 0.3,
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 55,
                        child: _Confetti(
                          color: Color(0xFFFFB800),
                          rotation: -0.6,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // العنوان
                  const Text(
                    'كل شيء جاهز!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // النص الأول
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'تم ضبط إعداداتك ',
                          style: TextStyle(
                            fontSize: 20,
                            color: grayText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: 'FLUMEA',
                          style: TextStyle(
                            fontSize: 20,
                            color: grayText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '🚀 لنبدأ رحلتك نحو يومك الأفضل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      color: grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // صندوق الملخص
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      22,
                      18,
                      22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE8ECF0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _SummaryItem(
                          icon: Icons.track_changes_rounded,
                          title: 'هدفك الأساسي',
                          value: 'زيادة الإنتاجية وتنظيم يومي',
                          darkBlue: darkBlue,
                          grayText: grayText,
                        ),

                        const SizedBox(height: 24),

                        _SummaryItem(
                          icon: Icons.fitness_center_rounded,
                          title: 'ما تنظمه',
                          value: 'المهام، العادات، الطعام، النوم، الرياضة',
                          darkBlue: darkBlue,
                          grayText: grayText,
                        ),

                        const SizedBox(height: 24),

                        _SummaryItem(
                          icon: Icons.calendar_month_rounded,
                          title: 'عدد العادات',
                          value: '5 عادات',
                          darkBlue: darkBlue,
                          grayText: grayText,
                        ),

                        const SizedBox(height: 24),

                        _SummaryItem(
                          icon: Icons.auto_awesome_rounded,
                          title: 'نمط المساعد',
                          value: 'مختصر جدًا',
                          darkBlue: darkBlue,
                          grayText: grayText,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر ابدأ الآن
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        // سنربطه بالصفحة الرئيسية لاحقًا
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'ابدأ الآن',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color darkBlue;
  final Color grayText;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.darkBlue,
    required this.grayText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // الأيقونة
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF1FBF6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF18B56A),
            size: 32,
          ),
        ),

        const SizedBox(width: 16),

        // النص
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: grayText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Confetti extends StatelessWidget {
  final Color color;
  final double rotation;

  const _Confetti({
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 9,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
