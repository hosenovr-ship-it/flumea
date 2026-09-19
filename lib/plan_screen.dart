import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1478D4);
  static const Color cyan = Color(0xFF20C7B7);
  static const Color background = Color(0xFFF7FBFF);

  final List<Map<String, dynamic>> tasks = [
    {
      'time': '6:00 ص',
      'title': 'الاستيقاظ',
      'subtitle': 'ابدأ يومك بطاقة',
      'tag': 'عادات',
      'emoji': '☀️',
      'color': cyan,
      'completed': true,
    },
    {
      'time': '6:30 ص',
      'title': 'الرياضة',
      'subtitle': 'تمرين لمدة 45 دقيقة',
      'tag': 'صحة',
      'emoji': '🏋️',
      'color': Color(0xFFEF5350),
      'completed': false,
    },
    {
      'time': '8:00 ص',
      'title': 'الإفطار',
      'subtitle': 'وجبة صحية ومتوازنة',
      'tag': 'غذاء',
      'emoji': '🍽️',
      'color': Color(0xFFFFA726),
      'completed': false,
    },
    {
      'time': '9:00 ص',
      'title': 'الدراسة',
      'subtitle': 'مذاكرة المواد المهمة',
      'tag': 'تعليم',
      'emoji': '🎓',
      'color': blue,
      'completed': true,
    },
    {
      'time': '12:00 م',
      'title': 'المهام الشخصية',
      'subtitle': 'إنجاز الأعمال المطلوبة',
      'tag': 'إنتاجية',
      'emoji': '💼',
      'color': Color(0xFFE57C72),
      'completed': false,
    },
    {
      'time': '4:00 م',
      'title': 'القراءة',
      'subtitle': 'قراءة 30 دقيقة',
      'tag': 'تطوير الذات',
      'emoji': '📖',
      'color': Color(0xFF8E44AD),
      'completed': false,
    },
    {
      'time': '7:00 م',
      'title': 'مراجعة اليوم',
      'subtitle': 'تقييم ما تم إنجازه',
      'tag': 'مراجعة',
      'emoji': '📊',
      'color': cyan,
      'completed': false,
    },
    {
      'time': '8:00 م',
      'title': 'كرة القدم',
      'subtitle': 'مهمة جديدة',
      'tag': 'رياضة',
      'emoji': '⚽',
      'color': cyan,
      'completed': false,
    },
  ];

  final List<Map<String, dynamic>> habits = [
    {
      'title': 'شرب الماء',
      'icon': Icons.water_drop_outlined,
      'completed': true,
    },
    {
      'title': 'الرياضة',
      'icon': Icons.fitness_center_outlined,
      'completed': false,
    },
    {
      'title': 'القراءة',
      'icon': Icons.menu_book_outlined,
      'completed': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildTodayButton(),
                const SizedBox(height: 14),
                _buildDays(),
                const SizedBox(height: 14),
                _buildSummary(),
                const SizedBox(height: 14),
                _buildTasks(),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildWeeklyGoals(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDailyHabits(),
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

  Widget _buildHeader() {
    return Row(
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
                  color: Color(0xFF7B8798),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }

  Widget _buildDays() {
    const days = [
      ['الأحد', '20'],
      ['الاثنين', '21'],
      ['الثلاثاء', '22'],
      ['الأربعاء', '23'],
      ['الخميس', '24'],
      ['الجمعة', '25'],
      ['السبت', '26'],
    ];

    return SizedBox(
      height: 82,
      child: Row(
        children: List.generate(
          days.length,
          (index) => Expanded(
            child: _dayBox(
              days[index][0],
              days[index][1],
              index == 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dayBox(
    String day,
    String number,
    bool selected,
  ) {
    return Container(
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
              fontSize: 10,
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
                  : navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final completed = tasks.where(
      (task) => task['completed'] == true,
    ).length;

    final remaining = tasks.length - completed;

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
                          style: TextStyle(
                            fontSize: 22,
                          ),
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
                  '$completed',
                  'مهام مكتملة',
                  cyan,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  Icons.gps_fixed,
                  '$remaining',
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
                child: _progressCircle(
                  completed: completed,
                ),
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
            color: navy,
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

  Widget _progressCircle({
    required int completed,
  }) {
    final progress = tasks.isEmpty
        ? 0.0
        : completed / tasks.length;

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
              value: progress,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFDDE4ED),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                cyan,
              ),
            ),
          ),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                '$completed/${tasks.length}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const Text(
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

  Widget _buildTasks() {
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
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius:
                        BorderRadius.circular(20),
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
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(
            tasks.length,
            (index) => _taskCard(index),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: _showAddTaskDialog,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
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
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(int index) {
    final task = tasks[index];
    final bool completed =
        task['completed'] == true;

    final Color tagColor =
        task['color'] as Color;

    final String tag =
        task['tag']?.toString() ?? '';

    final String emoji =
        task['emoji']?.toString() ?? '';

    return InkWell(
      onTap: () {
        setState(() {
          tasks[index]['completed'] =
              !completed;
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
            // أقصى اليمين: علامة الإنجاز
            Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: completed
                  ? cyan
                  : const Color(0xFFB8C1CC),
              size: 24,
            ),

            const SizedBox(width: 9),

            // اسم المهمة والوصف
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    task['title'].toString(),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                      color: completed
                          ? const Color(
                              0xFF99A5B1,
                            )
                          : navy,
                      decoration: completed
                          ? TextDecoration
                              .lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['subtitle'].toString(),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF66758A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // التصنيف والإيموجي في منطقة مستقلة
            SizedBox(
              width: 86,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        tag,
                        textAlign:
                            TextAlign.center,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                          color: tagColor,
                                                ),
                    ),
                    Text(
  emoji,
  style: const TextStyle(
    fontSize: 13,
  ),
),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              width: 55,
              child: Text(
                task['time'].toString(),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF65758A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 6),

            const Icon(
              Icons.more_vert,
              color: Color(0xFF65758A),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final emojiController =
        TextEditingController(text: '📝');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            'إضافة مهمة جديدة',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ابدأ بخطوة صغيرة نحو هدفك الكبير',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF7A8797),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'اسم المهمة *',
                    prefixIcon: const Icon(
                      Icons.edit_rounded,
                      color: blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: timeController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'الوقت',
                    prefixIcon: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFE85D6A),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: categoryController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'التصنيف',
                    prefixIcon: const Icon(
                      Icons.local_offer_rounded,
                      color: Color(0xFFF0A51A),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: emojiController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'الإيموجي',
                    prefixIcon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Color(0xFF7567D9),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFFF4A90E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            14,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF0F3F8),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text
                          .trim()
                          .isEmpty) {
                        return;
                      }

                      setState(() {
                        tasks.add({
                          'time':
                              timeController.text
                                      .trim()
                                      .isEmpty
                                  ? 'بدون وقت'
                                  : timeController.text
                                      .trim(),
                          'title':
                              nameController.text.trim(),
                          'subtitle':
                              descriptionController.text
                                      .trim()
                                      .isEmpty
                                  ? 'مهمة جديدة'
                                  : descriptionController
                                      .text
                                      .trim(),
                          'tag':
                              categoryController.text
                                      .trim()
                                      .isEmpty
                                  ? 'مهمة'
                                  : categoryController
                                      .text
                                      .trim(),
                          'emoji':
                              emojiController.text
                                      .trim()
                                      .isEmpty
                                  ? '📝'
                                  : emojiController.text
                                      .trim(),
                          'color': cyan,
                          'completed': false,
                        });
                      });

                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF4169F1),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'إضافة المهمة +',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
              Widget _buildWeeklyGoals() {
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
                Icons.flag_outlined,
                size: 21,
                color: navy,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'أهداف الأسبوع',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: navy,
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
            cyan,
          ),
          _goalRow(
            'القراءة',
            '2/3',
            0.66,
            const Color(0xFFF8A44D),
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
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  const Color(0xFFEFF2F6),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHabits() {
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
                Icons.repeat,
                size: 21,
                color: navy,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'عادات اليوم',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(
            habits.length,
            (index) => _habitRow(index),
          ),
        ],
      ),
    );
  }

  Widget _habitRow(int index) {
    final habit = habits[index];
    final bool completed =
        habit['completed'] == true;

    return InkWell(
      onTap: () {
        setState(() {
          habits[index]['completed'] =
              !completed;
        });
      },
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 11),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 19,
              color: completed
                  ? cyan
                  : const Color(0xFFB8C1CC),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                habit['title'],
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: completed
                      ? const Color(0xFF66758A)
                      : navy,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            Icon(
              habit['icon'],
              size: 18,
              color: const Color(0xFF7B8798),
            ),
          ],
        ),
      ),
    );
  }
            }
