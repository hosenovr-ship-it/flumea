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
                        fontWeight: FontWeight.w800,
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
    final bool completed =
        _safeBool(task['completed']);

    final String title = _safeString(
      task['title'],
      fallback: 'مهمة جديدة',
    );

    final String subtitle = _safeString(
      task['subtitle'],
      fallback: 'مهمة جديدة',
    );

    final String time = _safeString(
      task['time'],
      fallback: 'بدون وقت',
    );

    final String tag = _safeString(
      task['tag'],
      fallback: 'عام',
    );

    final String emoji = _safeString(
      task['emoji'],
      fallback: '📝',
    );

    final Color color =
        _safeColor(task['color']);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8EDF2),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (index < 0 ||
                  index >= tasks.length) {
                return;
              }

              setState(() {
                tasks[index]['completed'] =
                    !_safeBool(
                  tasks[index]['completed'],
                );
              });
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: completed
                    ? blue
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(6),
                border: Border.all(
                  color: completed
                      ? blue
                      : const Color(0xFFB8C2CE),
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: GestureDetector(
              onTap: () {
                if (index < 0 ||
                    index >= tasks.length) {
                  return;
                }

                setState(() {
                  tasks[index]['completed'] =
                      !_safeBool(
                    tasks[index]['completed'],
                  );
                });
              },
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          textAlign:
                              TextAlign.right,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                            color: completed
                                ? const Color(
                                    0xFF9AA4AE,
                                  )
                                : navy,
                            decoration: completed
                                ? TextDecoration
                                    .lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              emoji,
                              style:
                                  const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B8798),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 58,
            child: Text(
              time,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF52647A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 5),

          _buildTaskMenu(index),
        ],
      ),
    );
  }

  Widget _buildTaskMenu(int index) {
    return PopupMenuButton<String>(
      tooltip: 'خيارات المهمة',
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert,
        color: Color(0xFF6E7A88),
        size: 22,
      ),
      onSelected: (value) {
        if (index < 0 ||
            index >= tasks.length) {
          return;
        }

        if (value == 'reset') {
          setState(() {
            tasks[index]['completed'] = false;
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
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'reset',
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  'إعادة المهمة 🔄',
                  style: TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  'حذف المهمة 🗑️',
                  style: TextStyle(
                    color: Color(0xFFD64545),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
    void _showAddTaskDialog() {
    final nameController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    final timeController =
        TextEditingController();

    final categoryController =
        TextEditingController();

    final emojiController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child: AlertDialog(
            backgroundColor:
                Colors.white,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(28),
            ),
            title: const Text(
              'إضافة مهمة جديدة',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Text(
                    'ابدأ بخطوة صغيرة نحو هدفك الكبير',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Color(0xFF7B8798),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  _dialogField(
                    controller:
                        nameController,
                    label:
                        'اسم المهمة *',
                    icon:
                        Icons.edit_outlined,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _dialogField(
                    controller:
                        timeController,
                    label: 'الوقت',
                    icon:
                        Icons.access_time,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _dialogField(
                    controller:
                        categoryController,
                    label:
                        'التصنيف',
                    icon: Icons
                        .local_offer_outlined,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _dialogField(
                    controller:
                        emojiController,
                    label:
                        'الإيموجي',
                    icon: Icons
                        .sentiment_satisfied_alt,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        descriptionController,
                    maxLines: 3,
                    maxLength: 100,
                    textAlign:
                        TextAlign.right,
                    decoration:
                        InputDecoration(
                      labelText:
                          'الوصف',
                      alignLabelWithHint:
                          true,
                      prefixIcon:
                          const Icon(
                        Icons
                            .description_outlined,
                        color:
                            Color(0xFFE5AA27),
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                        borderSide:
                            const BorderSide(
                          color: blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding:
                const EdgeInsets
                    .fromLTRB(
              16,
              0,
              16,
              16,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child:
                        TextButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      style:
                          TextButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFF1F4F8,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'إلغاء',
                        style:
                            TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed: () {
                        final name =
                            nameController
                                .text
                                .trim();

                        if (name.isEmpty) {
                          return;
                        }

                        final time =
                            timeController
                                .text
                                .trim();

                        final category =
                            categoryController
                                .text
                                .trim();

                        final emoji =
                            emojiController
                                .text
                                .trim();

                        final description =
                            descriptionController
                                .text
                                .trim();

                        setState(() {
                          tasks.add({
                            'time':
                                time.isEmpty
                                    ? 'بدون وقت'
                                    : time,
                            'title':
                                name,
                            'subtitle':
                                description
                                        .isEmpty
                                    ? 'مهمة جديدة'
                                    : description,
                            'tag':
                                category.isEmpty
                                    ? 'عام'
                                    : category,
                            'emoji':
                                emoji.isEmpty
                                    ? '📝'
                                    : emoji,
                            'color':
                                blue,
                            'completed':
                                false,
                          });
                        });

                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            blue,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'إضافة المهمة +',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dialogField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textAlign:
          TextAlign.right,
      decoration:
          InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(
          icon,
          color: blue,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          borderSide:
              const BorderSide(
            color: blue,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoals() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(
            0xFFE5EAF0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              const Text(
                'أهداف الأسبوع',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              const Icon(
                Icons.flag_outlined,
                color: navy,
                size: 21,
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          _goalRow(
            'الدراسة',
            4,
            5,
            blue,
          ),

          const SizedBox(
            height: 15,
          ),

          _goalRow(
            'الرياضة',
            3,
            5,
            cyan,
          ),

          const SizedBox(
            height: 15,
          ),

          _goalRow(
            'القراءة',
            6,
            7,
            const Color(
              0xFF8E44AD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalRow(
    String title,
    int current,
    int total,
    Color color,
  ) {
    final progress =
        total <= 0
            ? 0.0
            : (current / total)
                .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            Text(
              '$current/$total',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            Text(
              title,
              style:
                  const TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 7,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          child:
              LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor:
                const Color(
              0xFFE8EDF3,
            ),
            valueColor:
                AlwaysStoppedAnimation<
                    Color>(
              color,
            ),
          ),
        ),
      ],
    );
  }
    Widget _buildDailyHabits() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text(
                'عادات اليوم',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.check_circle_outline,
                color: navy,
                size: 21,
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (habits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Text(
                'لا توجد عادات بعد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B8798),
                  fontSize: 13,
                ),
              ),
            )
          else
            ...List.generate(
              habits.length,
              (index) => _habitRow(index),
            ),

          const SizedBox(height: 4),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddHabitDialog,
              icon: const Icon(
                Icons.add,
                size: 19,
              ),
              label: const Text(
                'إضافة عادة جديدة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                side: const BorderSide(
                  color: Color(0xFFD9E1EA),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitRow(int index) {
    if (index < 0 ||
        index >= habits.length) {
      return const SizedBox.shrink();
    }

    final habit = habits[index];

    final bool completed =
        _safeBool(habit['completed']);

    final String title = _safeString(
      habit['title'],
      fallback: 'عادة جديدة',
    );

    final IconData icon =
        _safeIcon(habit['icon']);

    return GestureDetector(
      onTap: () {
        if (index < 0 ||
            index >= habits.length) {
          return;
        }

        setState(() {
          final current =
              _safeBool(
            habits[index]['completed'],
          );

          habits[index]['completed'] =
              !current;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: completed
                    ? cyan
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed
                      ? cyan
                      : const Color(
                          0xFFB8C2CE,
                        ),
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 17,
                    )
                  : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: completed
                      ? const Color(
                          0xFF9AA4AE,
                        )
                      : navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFEAF9F4,
                ),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: cyan,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    final nameController =
        TextEditingController();

    final emojiController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(24),
            ),
            title: const Text(
              'إضافة عادة جديدة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _habitDialogField(
                  controller: nameController,
                  label: 'اسم العادة',
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(height: 12),
                _habitDialogField(
                  controller: emojiController,
                  label: 'الإيموجي',
                  icon: Icons
                      .sentiment_satisfied_alt,
                ),
              ],
            ),
            actionsPadding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFF1F4F8,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: navy,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name =
                            nameController
                                .text
                                .trim();

                        final emoji =
                            emojiController
                                .text
                                .trim();

                        setState(() {
                          habits.add({
                            'title': name.isEmpty
                                ? 'عادة جديدة'
                                : name,
                            'emoji': emoji.isEmpty
                                ? '⭐'
                                : emoji,
                            'icon':
                                Icons.star_outline,
                            'completed': false,
                          });
                        });

                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: const Text(
                        'إضافة',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    Widget _habitDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: blue,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: blue,
            width: 1.5,
          ),
        ),
      ),
    );
    }
  }
