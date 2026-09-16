import 'package:flutter/material.dart';
import 'ready_screen.dart';
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  int selectedOption = 0;

  final Color darkBlue = const Color(0xFF102A4C);
  final Color green = const Color(0xFF18B56A);
  final Color lightGreen = const Color(0xFFF0FBF6);
  final Color grayText = const Color(0xFF7B8798);

  void selectOption(int index) {
    setState(() {
      selectedOption = index;
    });
  }

  Widget buildAssistantCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool isSelected = selectedOption == index;

    return GestureDetector(
      onTap: () => selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: isSelected ? lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? green : const Color(0xFFE5E8EC),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // صورة/أيقونة المساعد
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 48,
                color: darkBlue,
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
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // زر الاختيار
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? green
                      : const Color(0xFF9AA4B2),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
              child: Column(
                children: [
                  // زر الرجوع - في الجهة اليسرى
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: 24,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // العنوان
                  Text(
                    'كيف تريد أن يكون الذكاء الاصطناعي؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // الوصف
                  Text(
                    'اختر النمط الذي يناسبك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // مختصر جدًا
                  buildAssistantCard(
                    index: 0,
                    title: 'مختصر جدًا',
                    description: 'إجابات قصيرة ومباشرة\nيركز على المهم فقط',
                    icon: Icons.smart_toy_rounded,
                  ),

                  const SizedBox(height: 16),

                  // متوازن
                  buildAssistantCard(
                    index: 1,
                    title: 'متوازن',
                    description: 'تذكيرات واقتراحات مفيدة\nبدون إزعاج',
                    icon: Icons.smart_toy_rounded,
                  ),

                  const SizedBox(height: 16),

                  // تفصيلي أكثر
                  buildAssistantCard(
                    index: 2,
                    title: 'تفصيلي أكثر',
                    description: 'تحليلات ونصائح مفصلة\nوتقارير يومية',
                    icon: Icons.smart_toy_rounded,
                  ),

                  const SizedBox(height: 38),

                  // زر التالي
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ReadyScreen(),
    ),
  );
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
                        'التالي',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
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
