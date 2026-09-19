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

  int selectedDay = 0;

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
      'completed': true,
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
      'completed': true,
    },
    {
      'time': '4:00 م',
      'title': 'القراءة',
      'subtitle': 'قراءة 30 دقيقة',
      'tag': 'تطوير الذات',
      'emoji': '📖',
      'color': Color(0xFF8E44AD),
      'completed': true,
    },
    {
      'time': '7:00 م',
      'title': 'مراجعة اليوم',
      'subtitle': 'تقييم ما تم إنجازه',
      'tag': 'مراجعة',
      'emoji': '📊',
      'color': cyan,
      'completed': true,
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
      'completed': true,
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
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = 0;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F4),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDay = index;
                });
              },
              child: _dayBox(
                days[index][0],
                days[index][1],
                selectedDay == index,
              ),
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
      margin: const EdgeInsets.symmetric(
        horizontal: 3,
      ),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
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
            color: color.withValues(
              alpha: 0.10,
            ),
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
              backgroundColor:
                  const Color(0xFFDDE4ED),
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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
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
    Widget _taskCard(Map<String, dynamic> task, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tasks[index]['completed'] = !tasks[index]['completed'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: task['completed']
                    ? const Color(0xFF111111)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task['completed']
                      ? const Color(0xFF111111)
                      : const Color(0xFFD6D6D6),
                  width: 1.5,
                ),
              ),
              child: task['completed']
                  ? const Icon(
                      Icons.check,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task['completed']
                          ? Colors.grey
                          : const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task['subtitle'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task['tag'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task['emoji'],
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task['time'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.more_horiz,
              color: Color(0xFF999999),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    final categoryController = TextEditingController();
    final emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'إضافة مهمة جديدة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(
                    controller: nameController,
                    label: 'اسم المهمة',
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    controller: descriptionController,
                    label: 'الوصف',
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    controller: timeController,
                    label: 'الوقت',
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    controller: categoryController,
                    label: 'التصنيف',
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    controller: emojiController,
                    label: 'الإيموجي',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    tasks.add({
                      'time': timeController.text.isEmpty
                          ? 'بدون وقت'
                          : timeController.text,
                      'title': nameController.text.isEmpty
                          ? 'مهمة جديدة'
                          : nameController.text,
                      'subtitle': descriptionController.text.isEmpty
                          ? 'مهمة جديدة'
                          : descriptionController.text,
                      'tag': categoryController.text.isEmpty
                          ? 'عام'
                          : categoryController.text,
                      'emoji': emojiController.text.isEmpty
                          ? '📝'
                          : emojiController.text,
                      'color': const Color(0xFF4F7CFF),
                      'completed': false,
                    });
                  });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF111111),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoals() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أهداف الأسبوع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 16),

          _goalRow(
            icon: Icons.menu_book_rounded,
            title: 'الدراسة',
            current: 4,
            total: 5,
          ),

          const SizedBox(height: 14),

          _goalRow(
            icon: Icons.fitness_center_rounded,
            title: 'الرياضة',
            current: 3,
            total: 5,
          ),

          const SizedBox(height: 14),

          _goalRow(
            icon: Icons.auto_stories_rounded,
            title: 'القراءة',
            current: 6,
            total: 7,
          ),
        ],
      ),
    );
  }

  Widget _goalRow({
    required IconData icon,
    required String title,
    required int current,
    required int total,
  }) {
    final double progress = current / total;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF222222),
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$current/$total',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFEDEDED),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
    Widget _buildDailyHabits() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'عادات اليوم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 16),

          _habitRow(0),
          const SizedBox(height: 10),
          _habitRow(1),
          const SizedBox(height: 10),
          _habitRow(2),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddHabitDialog,
              icon: const Icon(
                Icons.add,
                size: 20,
              ),
              label: const Text(
                'إضافة عادة جديدة',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF222222),
                side: const BorderSide(
                  color: Color(0xFFDCDCDC),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitRow(int index) {
    final habit = habits[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          habit['completed'] = !habit['completed'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: habit['completed']
                    ? const Color(0xFF111111)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit['completed']
                      ? const Color(0xFF111111)
                      : const Color(0xFFD6D6D6),
                  width: 1.5,
                ),
              ),
              child: habit['completed']
                  ? const Icon(
                      Icons.check,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                habit['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: habit['completed']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: habit['completed']
                      ? Colors.grey
                      : const Color(0xFF222222),
                ),
              ),
            ),

            Text(
              habit['emoji'],
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'إضافة عادة جديدة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _habitDialogField(
                  controller: nameController,
                  label: 'اسم العادة',
                ),

                const SizedBox(height: 10),

                _habitDialogField(
                  controller: emojiController,
                  label: 'الإيموجي',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    habits.add({
                      'title': nameController.text.isEmpty
                          ? 'عادة جديدة'
                          : nameController.text,
                      'emoji': emojiController.text.isEmpty
                          ? '⭐'
                          : emojiController.text,
                      'completed': false,
                    });
                  });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _habitDialogField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF111111),
          ),
        ),
      ),
    );
  }
}
