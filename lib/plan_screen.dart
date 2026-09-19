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

  String _safeString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  Color _safeColor(dynamic value) {
    if (value is Color) {
      return value;
    }

    return blue;
  }

  IconData _safeIcon(dynamic value) {
    if (value is IconData) {
      return value;
    }

    return Icons.check_circle_outline;
  }

  bool _safeBool(dynamic value) {
    return value == true;
  }

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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
        bottomNavigationBar:
            const FlumeaBottomNavigation(
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
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
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
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = 0;
            });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF9F4),
              borderRadius:
                  BorderRadius.circular(28),
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
          (index) {
            return Expanded(
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
            );
          },
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
      margin:
          const EdgeInsets.symmetric(
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? blue
            : const Color(0xFFF5F8FC),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? blue
              : const Color(0xFFE7ECF2),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
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
      (task) => _safeBool(task['completed']),
    ).length;

    final remaining =
        tasks.length - completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F4),
        borderRadius:
            BorderRadius.circular(24),
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
                            fontWeight:
                                FontWeight.w800,
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
                      textAlign:
                          TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF7B8798),
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
                  const Color(
                    0xFFEF5350,
                  ),
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
            child:
                CircularProgressIndicator(
              value: progress.clamp(
                0.0,
                1.0,
              ),
              strokeWidth: 7,
              backgroundColor:
                  const Color(0xFFDDE4ED),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
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
                  fontWeight:
                      FontWeight.w800,
                  color: navy,
                ),
              ),
              const Text(
                'مكتملة',
                style: TextStyle(
                  fontSize: 9,
                  color:
                      Color(0xFF66758A),
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
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(
            0xFFE5EAF0,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
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
                      fontWeight:
                          FontWeight.w800,
                      color: navy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...List.generate(
            tasks.length,
            (index) => _taskCard(
              tasks[index],
              index,
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: _showAddTaskDialog,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
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
    Widget _taskCard(
    Map<String, dynamic> task,
    int index,
  ) {
    final completed = _safeBool(
      task['completed'],
    );

    final title = _safeString(
      task['title'],
      fallback: 'مهمة',
    );

    final subtitle = _safeString(
      task['subtitle'],
    );

    final time = _safeString(
      task['time'],
    );

    final tag = _safeString(
      task['tag'],
    );

    final emoji = _safeString(
      task['emoji'],
      fallback: '📌',
    );

    final color = _safeColor(
      task['color'],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          task['completed'] = !completed;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: completed
              ? const Color(0xFFF5FAF8)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? const Color(0xFFD9EEE7)
                : const Color(0xFFE8EDF3),
          ),
        ),
        child: Row(
          children: [
            _taskMenu(task, index),
            const SizedBox(width: 8),

            Expanded(
              child: Row(
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
                            Flexible(
                              child: Text(
                                title,
                                textAlign:
                                    TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: navy,
                                  decoration:
                                      completed
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              emoji,
                              style:
                                  const TextStyle(
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          textAlign:
                              TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF7B8798),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  _taskCheck(
                    completed,
                    color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    }
    Widget _taskCheck(
    bool completed,
    Color color,
  ) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? color
            : Colors.transparent,
        border: Border.all(
          color: completed
              ? color
              : const Color(0xFFB8C4D2),
          width: 2,
        ),
      ),
      child: completed
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 19,
            )
          : null,
    );
  }

  Widget _taskMenu(
    Map<String, dynamic> task,
    int index,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Color(0xFF718096),
      ),
      onSelected: (value) {
        if (value == 'reset') {
          setState(() {
            task['completed'] = false;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'تمت إعادة المهمة',
              ),
            ),
          );
        }

        if (value == 'delete') {
          _deleteTask(index);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'reset',
          child: Text(
            'إعادة المهمة 🔄',
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'حذف المهمة 🗑️',
          ),
        ),
      ],
    );
  }
    void _deleteTask(int index) {
    if (index < 0 || index >= tasks.length) {
      return;
    }

    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'تم حذف المهمة',
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController =
        TextEditingController();
    final subtitleController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'إضافة مهمة جديدة',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        titleController,
                    textAlign: TextAlign.right,
                    decoration:
                        const InputDecoration(
                      labelText: 'اسم المهمة',
                      hintText:
                          'مثال: الدراسة',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:
                        subtitleController,
                    textAlign: TextAlign.right,
                    decoration:
                        const InputDecoration(
                      labelText: 'وصف المهمة',
                      hintText:
                          'مثال: دراسة لمدة ساعة',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'إلغاء',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final title =
                      titleController
                          .text
                          .trim();

                  final subtitle =
                      subtitleController
                          .text
                          .trim();

                  if (title.isEmpty) {
                    return;
                  }

                  setState(() {
                    tasks.add({
                      'time': 'الآن',
                      'title': title,
                      'subtitle':
                          subtitle.isEmpty
                              ? 'مهمة جديدة'
                              : subtitle,
                      'tag': 'جديد',
                      'emoji': '📌',
                      'color': blue,
                      'completed': false,
                    });
                  });

                  Navigator.pop(
                    dialogContext,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تمت إضافة المهمة',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor:
                      Colors.white,
                ),
                child: const Text(
                  'إضافة',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
    Widget _buildWeeklyGoals() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'الأهداف الأسبوعية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.flag_outlined,
                color: blue,
                size: 23,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _goalItem(
            'الدراسة',
            '4 / 5 أيام',
            0.80,
            Icons.school_outlined,
            blue,
          ),
          const SizedBox(height: 12),
          _goalItem(
            'الرياضة',
            '3 / 4 أيام',
            0.75,
            Icons.fitness_center_outlined,
            cyan,
          ),
          const SizedBox(height: 12),
          _goalItem(
            'القراءة',
            '6 / 7 أيام',
            0.86,
            Icons.menu_book_outlined,
            const Color(0xFF8E44AD),
          ),
        ],
      ),
    );
  }

  Widget _goalItem(
    String title,
    String progressText,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 19,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progressText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7B8798),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor:
                  const Color(0xFFE2E8F0),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'عاداتي اليومية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.repeat_rounded,
                color: cyan,
                size: 23,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            habits.length,
            (index) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: _habitItem(
                  habits[index],
                  index,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: _showAddHabitDialog,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF9F4),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: cyan,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'إضافة عادة',
                    style: TextStyle(
                      color: navy,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitItem(
    Map<String, dynamic> habit,
    int index,
  ) {
    final completed =
        _safeBool(habit['completed']);

    final title = _safeString(
      habit['title'],
      fallback: 'عادة',
    );

    final icon = _safeIcon(
      habit['icon'],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          habit['completed'] = !completed;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: completed
              ? const Color(0xFFEAF9F4)
              : const Color(0xFFF8FAFC),
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: completed
                ? const Color(0xFFD2EEE5)
                : const Color(0xFFE8EDF3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: completed
                    ? cyan.withValues(
                        alpha: 0.12,
                      )
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed
                    ? Icons.check
                    : icon,
                color: completed
                    ? cyan
                    : const Color(
                        0xFF718096,
                      ),
                size: 18,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: navy,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'إضافة عادة جديدة',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            content: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              autofocus: true,
              decoration:
                  const InputDecoration(
                labelText: 'اسم العادة',
                hintText:
                    'مثال: شرب الماء',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'إلغاء',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final title =
                      controller.text.trim();

                  if (title.isEmpty) {
                    return;
                  }

                  setState(() {
                    habits.add({
                      'title': title,
                      'icon':
                          Icons.check_circle_outline,
                      'emoji': '✨',
                      'completed': false,
                    });
                  });

                  Navigator.pop(
                    dialogContext,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تمت إضافة العادة',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyan,
                  foregroundColor:
                      Colors.white,
                ),
                child: const Text(
                  'إضافة',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
