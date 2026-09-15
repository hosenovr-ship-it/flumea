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
      'color': Color(0xFF18A878),
    },
    {
      'icon': Icons.local_fire_department_outlined,
      'title': 'تحسين الصحة واللياقة',
      'subtitle': 'الرياضة، التغذية والنوم',
      'color': Color(0xFFFF7A2F),
    },
    {
      'icon': Icons.emoji_events_outlined,
      'title': 'بناء عادات أفضل',
      'subtitle': 'عادات يومية إيجابية',
      'color': Color(0xFFF2B84B),
    },
    {
      'icon': Icons.home_outlined,
      'title': 'تحقيق أهداف طويلة المدى',
      'subtitle': 'الدراسة، العمل، المال وغيرها',
      'color': Color(0xFF4A90E2),
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
              // شريط التقدم + زر الرجوع
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF102A4C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF18A878),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9DEE5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9DEE5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9DEE5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // العنوان
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'ما هدفك الأساسي من استخدام\nFLUMEA؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF102A4C),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'يمكنك اختيار أكثر من هدف',
                style: TextStyle(
                  color: Color(0xFF9AA3AE),
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              // الخيارات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final bool isSelected =
                        selectedGoals.contains(index);

                    return GestureDetector(
                      onTap: () => toggleGoal(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF18A878)
                                : const Color(0xFFE1E5EA),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // الأيقونة
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: (goal['color'] as Color)
                                    .withOpacity(0.10),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                goal['icon'] as IconData,
                                color: goal['color'] as Color,
                                size: 25,
                              ),
                            ),

                            const SizedBox(width: 13),

                            // النص
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF25364D),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal['subtitle'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF9AA3AE),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // علامة الاختيار
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF18A878)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF18A878)
                                      : const Color(0xFFD0D5DB),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 15,
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

              // زر التالي
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: selectedGoals.isEmpty
                        ? null
                        : () {
                            // سنربطه بالصفحة رقم 4 لاحقًا
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF18A878),
                      disabledBackgroundColor:
                          const Color(0xFFE0E5E9),
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                          const Color(0xFF9AA3AE),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
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
