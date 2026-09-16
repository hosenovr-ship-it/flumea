import 'package:flutter/material.dart';
import 'ai_assistant_screen.dart';
class DailyTimesScreen extends StatefulWidget {
  const DailyTimesScreen({super.key});

  @override
  State<DailyTimesScreen> createState() => _DailyTimesScreenState();
}

class _DailyTimesScreenState extends State<DailyTimesScreen> {
  TimeOfDay wakeUpTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay sleepTime = const TimeOfDay(hour: 23, minute: 30);

  final List<String> days = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final Set<String> selectedDays = {
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  };

  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: wakeUpTime,
    );

    if (picked != null) {
      setState(() {
        wakeUpTime = picked;
      });
    }
  }

  Future<void> _selectSleepTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: sleepTime,
    );

    if (picked != null) {
      setState(() {
        sleepTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'ص' : 'م';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // سهم الرجوع - الجهة اليسرى
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF102A4C),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // العنوان
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'أخبرنا عن أوقاتك اليومية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 29,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF102A4C),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // الوصف
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'لضبط جدولك واقتراح أفضل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA0A8B3),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // وقت الاستيقاظ
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'وقت الاستيقاظ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A4C),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: _selectWakeUpTime,
                    child: Container(
                      width: double.infinity,
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE7EBEF),
                          width: 1.3,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '☀️',
                            style: TextStyle(fontSize: 27),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(wakeUpTime),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // وقت النوم
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'وقت النوم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A4C),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: _selectSleepTime,
                    child: Container(
                      width: double.infinity,
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFFE7EBEF),
                          width: 1.3,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '🌙',
                            style: TextStyle(fontSize: 27),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(sleepTime),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF102A4C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 38),

                // أيام الدراسة / العمل
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أيام الدراسة / العمل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A4C),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // الأيام بالترتيب من الأحد إلى السبت
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 12,
                    children: days.map((day) {
                      final bool selected = selectedDays.contains(day);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedDays.remove(day);
                            } else {
                              selectedDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF08B477)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF08B477)
                                  : const Color(0xFFE1E6EA),
                              width: 1.3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF102A4C),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 48),

                // زر التالي
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AiAssistantScreen(),
    ),
  );
},
                        
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08B477),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 19,
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
      ),
    );
  }
}
