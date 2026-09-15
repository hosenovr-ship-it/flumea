import 'package:flutter/material.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final Set<int> selectedGoals = {};

  final List<Map<String, dynamic>> goals = [
    {
      'icon': Icons.spa_outlined,
      'title': 'زيادة الإنتاجية وتنظيم يومي',
      'subtitle': 'أنجز أكثر وركز على ما يهم',
      'color': const Color(0xFF18B77A),
    },
    {
      'icon': Icons.fitness_center_outlined,
      'title': 'تحسين الصحة واللياقة',
      'subtitle': 'الرياضة، التغذية والنوم',
      'color': const Color(0xFFFF7428),
    },
    {
      'icon': Icons.check_circle_outline,
      'title': 'بناء عادات أفضل',
      'subtitle': 'عادات يومية إيجابية',
      'color': const Color(0xFFF2A817),
    },
    {
      'icon': Icons.home_outlined,
      'title': 'تحقيق أهداف طويلة المدى',
      'subtitle': 'الدراسة، العمل، المال وغيرها',
      'color': const Color(0xFF2585E8),
    },
  ];

  void toggleGoal(int index) {
    setState(() {
      if (selectedGoals.contains(index)) {
        selectedGoals.remove(index);
      } else {
        selectedGoals.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // =========================
              // شريط التقدم وزر الرجوع
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                child: Row(
                  children: [
                    // زر الرجوع
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 23,
                          color: Color(0xFF102A4C),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // شريط التقدم
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF18B77A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E4EA),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E4EA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E4EA),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // العنوان
              // =========================
              const SizedBox(height: 36),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'ما هدفك الأساسي من استخدام\nFLUMEA؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'يمكنك اختيار أكثر من هدف',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9AA4B2),
                ),
              ),

              const SizedBox(height: 27),

              // =========================
              // بطاقات الأهداف
              // =========================
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final bool isSelected =
                        selectedGoals.contains(index);

                    final Color goalColor = goal['color'] as Color;

                    return GestureDetector(
                      onTap: () => toggleGoal(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(bottom: 13),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF5FFFB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF18B77A)
                                : const Color(0xFFE7E9ED),
                            width: isSelected ? 2 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.025),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // =========================
                            // الأيقونة
                            // =========================
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: goalColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                goal['icon'] as IconData,
                                color: goalColor,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 15),

                            // =========================
                            // النص
                            // =========================
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF102A4C),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    goal['subtitle'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9AA4B2),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // =========================
                            // دائرة الاختيار
                            // =========================
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF18B77A)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF18B77A)
                                      : const Color(0xFFD5DAE1),
                                  width: 1.7,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 17,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // =========================
              // زر التالي
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: selectedGoals.isEmpty
                        ? null
                        : () {
                            // سنربط هذا الزر بالصفحة رقم 4
                            // بعد الانتهاء من تصميمها.
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08B477),
                      disabledBackgroundColor:
                          const Color(0xFFE1E6E9),
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                          const Color(0xFF9AA4B2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
