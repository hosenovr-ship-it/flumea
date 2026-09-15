import 'package:flutter/material.dart';
import 'food_screen.dart';
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final Set<int> selectedHabits = {};

  final List<Map<String, dynamic>> habits = [
    {
      'icon': Icons.water_drop_outlined,
      'title': 'شرب الماء',
      'subtitle': '8 أكواب يوميًا',
      'color': Color(0xFF2F9FEF),
    },
    {
      'icon': Icons.menu_book_outlined,
      'title': 'قراءة',
      'subtitle': '15 دقيقة يوميًا',
      'color': Color(0xFF238A8D),
    },
    {
      'icon': Icons.fitness_center_outlined,
      'title': 'رياضة',
      'subtitle': '30 دقيقة يوميًا',
      'color': Color(0xFF173A5E),
    },
    {
      'icon': Icons.eco_outlined,
      'title': 'تأمل أو استرخاء',
      'subtitle': '10 دقائق يوميًا',
      'color': Color(0xFF22A99A),
    },
    {
      'icon': Icons.nightlight_outlined,
      'title': 'النوم مبكرًا',
      'subtitle': '7–8 ساعات يوميًا',
      'color': Color(0xFF347BEA),
    },
  ];

  void toggleHabit(int index) {
    setState(() {
      if (selectedHabits.contains(index)) {
        selectedHabits.remove(index);
      } else {
        selectedHabits.add(index);
      }
    });
  }

  void addHabit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'سنضيف إمكانية إنشاء عادة مخصصة لاحقًا ❤️‍🔥',
          textAlign: TextAlign.center,
        ),
      ),
    );
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
              // شريط التقدم
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
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
                    const SizedBox(width: 28),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
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
                              color: Color(0xFF18B77A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E4EA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // العنوان
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'ما العادات التي تريد البدء بمراقبتها؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'يمكنك إضافة أو تعديلها لاحقًا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA0A8B3),
                ),
              ),

              const SizedBox(height: 25),

              // قائمة العادات
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final bool isSelected =
                        selectedHabits.contains(index);

                    final Color habitColor =
                        habit['color'] as Color;

                    return GestureDetector(
                      onTap: () => toggleHabit(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF5FFFB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF18B77A)
                                : const Color(0xFFE5E8EC),
                            width: isSelected ? 2 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.025),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // الأيقونة
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: habitColor.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: Icon(
                                habit['icon'] as IconData,
                                color: habitColor,
                                size: 29,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // النص
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF102A4C),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    habit['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFA0A8B3),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // علامة الاختيار
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 180),
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
                                      : const Color(0xFFD1D6DC),
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

              // إضافة عادة أخرى
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: GestureDetector(
                  onTap: addHabit,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color(0xFFE5E8EC),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Color(0xFF18B77A),
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'إضافة عادة أخرى',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF18B77A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // زر التالي
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: selectedHabits.isEmpty
                        ? null
                        : () {
                            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FoodScreen(),
  ),
);
                            
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
