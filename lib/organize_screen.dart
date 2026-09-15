import 'package:flutter/material.dart';
import 'habits_screen.dart';
class OrganizeScreen extends StatefulWidget {
  const OrganizeScreen({super.key});

  @override
  State<OrganizeScreen> createState() => _OrganizeScreenState();
}

class _OrganizeScreenState extends State<OrganizeScreen> {
  final Set<int> selectedItems = {0, 1, 2};

  final List<Map<String, dynamic>> items = [
    {
      'icon': Icons.restaurant_outlined,
      'title': 'تسجيل الطعام',
      'color': const Color(0xFFF2B01E),
      'background': const Color(0xFFFFF8E8),
    },
    {
      'icon': Icons.account_tree_outlined,
      'title': 'العادات اليومية',
      'color': const Color(0xFF18B77A),
      'background': const Color(0xFFEFFBF6),
    },
    {
      'icon': Icons.assignment_outlined,
      'title': 'المهام والواجبات',
      'color': const Color(0xFF2B82E6),
      'background': const Color(0xFFEEF5FF),
    },
    {
      'icon': Icons.sports_esports_outlined,
      'title': 'أهدافي ومشاريعي',
      'color': const Color(0xFFF06445),
      'background': const Color(0xFFFFF1ED),
    },
    {
      'icon': Icons.fitness_center_outlined,
      'title': 'الرياضة والتمرين',
      'color': const Color(0xFFE96A38),
      'background': const Color(0xFFFFF3ED),
    },
    {
      'icon': Icons.nightlight_outlined,
      'title': 'النوم والطاقة',
      'color': const Color(0xFF7047C7),
      'background': const Color(0xFFF4F0FF),
    },
  ];

  void toggleItem(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
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
              // شريط التقدم
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                child: Row(
                  children: [
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
                              color: Color(0xFF18B77A),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              // العنوان
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ما الذي تريد تنظيمه في FLUMEA؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'اختر ما يناسبك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9AA4B2),
                ),
              ),

              const SizedBox(height: 26),

              // البطاقات
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final bool isSelected =
                        selectedItems.contains(index);

                    final Color itemColor = item['color'] as Color;
                    final Color background =
                        item['background'] as Color;

                    return GestureDetector(
                      onTap: () => toggleItem(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF18B77A)
                                : const Color(0xFFE5E7EB),
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
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: background,
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData,
                                      color: itemColor,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    item['title'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      height: 1.35,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF102A4C),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // علامة الاختيار
                            if (isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF18B77A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: selectedItems.isEmpty
                        ? null
                        : () {
                            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HabitsScreen(),
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
