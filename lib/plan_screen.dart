import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bottom_navigation.dart';
import 'services/task_service.dart';
import 'services/habit_service.dart';

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

  final TaskService _taskService = TaskService();
  final HabitService _habitService = HabitService();
  final SupabaseClient _supabase = Supabase.instance.client;
  int selectedDay = DateTime.now().weekday % 7;

  bool _isLoadingTasks = true;
  bool _isSavingTask = false;
  bool _isSavingHabit = false;

  List<Map<String, dynamic>> tasks = [];

  final List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadHabits();
  }

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

    final text = _safeString(value);

    if (text.startsWith('#')) {
      final hex = text.replaceFirst('#', '');

      try {
        if (hex.length == 6) {
          return Color(
            int.parse('FF$hex', radix: 16),
          );
        }

        if (hex.length == 8) {
          return Color(
            int.parse(hex, radix: 16),
          );
        }
      } catch (_) {}
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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _pageBackground =>
      _isDark ? const Color(0xFF0B151E) : background;

  Color get _surfaceColor =>
      _isDark ? const Color(0xFF111318) : Colors.white;

  Color get _cardColor =>
      _isDark ? const Color(0xFF101923) : Colors.white;

  Color get _primaryText =>
      _isDark ? const Color(0xFFF2F5F8) : navy;

  Color get _secondaryText =>
      _isDark ? const Color(0xFFB7C1CC) : const Color(0xFF7B8798);

  Color get _mutedText =>
      _isDark ? const Color(0xFF8E9AA8) : const Color(0xFF52647A);

  Color get _borderColor =>
      _isDark ? const Color(0xFF2B3947) : const Color(0xFFE5EAF0);

  Color get _softBorder =>
      _isDark ? const Color(0xFF344250) : const Color(0xFFE7ECF2);

  Color get _softBackground =>
      _isDark ? const Color(0xFF171D24) : const Color(0xFFF5F8FC);

  Color get _summaryBackground =>
      _isDark ? const Color(0xFF102334) : const Color(0xFFEAF9F4);

  Color get _summaryBorder =>
      _isDark ? const Color(0xFF164E73) : const Color(0xFFEAF9F4);

  Color get _buttonSoftBackground =>
      _isDark ? const Color(0xFF182632) : const Color(0xFFEAF9F4);

  Color get _taskBackground =>
      _isDark ? const Color(0xFF101318) : Colors.white;

  Color get _fieldBackground =>
      _isDark ? const Color(0xFF151C24) : const Color(0xFFFBFCFE);

  Color get _fieldBorder =>
      _isDark ? const Color(0xFF354352) : const Color(0xFFDCE3EC);

  Color get _progressBackground =>
      _isDark ? const Color(0xFF29333D) : const Color(0xFFE8EDF3);

  Color get _habitCompletedBackground =>
      _isDark ? const Color(0xFF122B2A) : const Color(0xFFF1FBF9);

  Color get _habitIncompleteBackground =>
      _isDark ? const Color(0xFF171C22) : const Color(0xFFF8FAFC);

  Color get _habitCompletedBorder =>
      _isDark ? const Color(0xFF1B5B55) : const Color(0xFFD5F0EB);

  Color get _habitIncompleteBorder =>
      _isDark ? const Color(0xFF35404B) : const Color(0xFFE7ECF2);


  // ============================================================
  // SUPABASE - تحميل المهام حسب اليوم
  // ============================================================

  DateTime get _selectedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysFromSunday = today.weekday % 7;

    return today
        .subtract(Duration(days: daysFromSunday))
        .add(Duration(days: selectedDay));
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _saveTaskDate(
    String id,
    DateTime date,
  ) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null || id.isEmpty) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    await _supabase
        .from('tasks')
        .update({
          'due_date': _dateKey(date),
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  String? _createdDateKey(dynamic value) {
    final raw = _safeString(value);

    if (raw.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);

    if (parsed == null) {
      return null;
    }

    return _dateKey(parsed.toLocal());
  }

  Future<void> _loadTasks() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final allTasks = await _taskService.getTasks();

      if (!mounted) {
        return;
      }

      if (allTasks.isEmpty) {
        await _createInitialTasks();
        return;
      }

      final selectedDateKey = _dateKey(_selectedDate);

      // المهام القديمة التي لا تحتوي due_date لا نضعها كلها في اليوم الحالي.
      // نستخدم created_at كمرجع فقط، من دون تغيير تاريخها في Supabase.
      final selectedTasks = allTasks.where((task) {
        final dueDate = _safeString(task['due_date']);

        if (dueDate.isNotEmpty) {
          return dueDate == selectedDateKey;
        }

        final createdDate = _createdDateKey(task['created_at']);
        return createdDate == selectedDateKey;
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        tasks = selectedTasks;
        _isLoadingTasks = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingTasks = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل المهام: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // إنشاء المهام التجريبية أول مرة فقط
  // ============================================================

  Future<void> _createInitialTasks() async {
    final initialTasks = [
      {
        'time': '6:00 ص',
        'title': 'الاستيقاظ',
        'description': 'ابدأ يومك بطاقة',
        'tag': 'عادات',
        'emoji': '☀️',
        'color': '#20C7B7',
        'completed': true,
      },
      {
        'time': '6:30 ص',
        'title': 'الرياضة',
        'description': 'تمرين لمدة 45 دقيقة',
        'tag': 'صحة',
        'emoji': '🏋️',
        'color': '#EF5350',
        'completed': false,
      },
      {
        'time': '8:00 ص',
        'title': 'الإفطار',
        'description': 'وجبة صحية ومتوازنة',
        'tag': 'غذاء',
        'emoji': '🍽️',
        'color': '#FFA726',
        'completed': true,
      },
      {
        'time': '9:00 ص',
        'title': 'الدراسة',
        'description': 'مذاكرة المواد المهمة',
        'tag': 'تعليم',
        'emoji': '🎓',
        'color': '#1478D4',
        'completed': true,
      },
      {
        'time': '12:00 م',
        'title': 'المهام الشخصية',
        'description': 'إنجاز الأعمال المطلوبة',
        'tag': 'إنتاجية',
        'emoji': '💼',
        'color': '#E57C72',
        'completed': true,
      },
      {
        'time': '4:00 م',
        'title': 'القراءة',
        'description': 'قراءة 30 دقيقة',
        'tag': 'تطوير الذات',
        'emoji': '📖',
        'color': '#8E44AD',
        'completed': true,
      },
      {
        'time': '7:00 م',
        'title': 'مراجعة اليوم',
        'description': 'تقييم ما تم إنجازه',
        'tag': 'مراجعة',
        'emoji': '📊',
        'color': '#20C7B7',
        'completed': true,
      },
    ];

    try {
      final createdTasks = <Map<String, dynamic>>[];

      for (final task in initialTasks) {
        final created = await _taskService.addTask(
          title: task['title'] as String,
          description: task['description'] as String,
          time: task['time'] as String,
          tag: task['tag'] as String,
          emoji: task['emoji'] as String,
          color: task['color'] as String,
          completed: task['completed'] as bool,
        );

        await _saveTaskDate(
          _safeString(created['id']),
          _selectedDate,
        );
        created['due_date'] = _dateKey(_selectedDate);
        createdTasks.add(created);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        tasks = createdTasks;
        _isLoadingTasks = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingTasks = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إنشاء المهام الأولية: $error',
          ),
        ),
      );
    }
  }
  // ============================================================
  // Supabase - تحميل العادات
  // ============================================================

  Future<void> _loadHabits() async {
    try {
      final loadedHabits = await _habitService.getHabits();

      if (!mounted) {
        return;
      }

      if (loadedHabits.isEmpty) {
        defaultNames = [
          'شرب الماء',
          'الرياضة',
          'القراءة',
        ];

        final createdHabits = <Map<String, dynamic>>[];

        for (final name in defaultNames) {
          final created = await _habitService.addHabit(
            name: name,
            description: '',
            completed: false,
          );
          createdHabits.add(created);
        }

        if (!mounted) {
          return;
        }

        setState(() {
          habits.clear();
          for (final habit in createdHabits) {
            habits.add(_habitMap(habit));
          }
        });
        return;
      }

      setState(() {
        habits.clear();
        for (final habit in loadedHabits) {
          habits.add(_habitMap(habit));
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحميل العادات: $error',
          ),
        ),
      );
    }
  }

  Map<String, dynamic> _habitMap(Map<String, dynamic> habit) {
    final name = _safeString(habit['name']);

    return {
      'id': habit['id'],
      'title': name,
      'description': _safeString(habit['description']),
      'completed': _safeBool(habit['completed']),
      'icon': _habitIconForName(name),
    };
  }

  IconData _habitIconForName(String name) {
    switch (name.trim()) {
      case 'شرب الماء':
        return Icons.water_drop_outlined;
      case 'الرياضة':
        return Icons.fitness_center_outlined;
      case 'القراءة':
        return Icons.menu_book_outlined;
      case 'النوم':
        return Icons.bed_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  // ============================================================
  // Supabase - تحديث حالة العادة
  // ============================================================

  Future<void> _toggleHabit(
    String id,
    bool completed,
  ) async {
    if (id.isEmpty) {
      return;
    }

    final index = habits.indexWhere(
      (habit) => _safeString(habit['id']) == id,
    );

    if (index == -1) {
      return;
    }

    final newValue = !completed;

    setState(() {
      habits[index]['completed'] = newValue;
    });

    try {
      await _habitService.updateHabit(
        id: id,
        completed: newValue,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        habits[index]['completed'] = completed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحديث العادة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // إعادة العادة
  // ============================================================

  Future<void> _resetHabit(String id) async {
    if (id.isEmpty) {
      return;
    }

    final index = habits.indexWhere(
      (habit) => _safeString(habit['id']) == id,
    );

    if (index == -1) {
      return;
    }

    final oldValue = _safeBool(habits[index]['completed']);

    setState(() {
      habits[index]['completed'] = false;
    });

    try {
      await _habitService.resetHabit(id);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        habits[index]['completed'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إعادة العادة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // حذف العادة
  // ============================================================

  Future<void> _deleteHabit(String id) async {
    if (id.isEmpty) {
      return;
    }

    final index = habits.indexWhere(
      (habit) => _safeString(habit['id']) == id,
    );

    if (index == -1) {
      return;
    }

    final removedHabit = Map<String, dynamic>.from(habits[index]);

    setState(() {
      habits.removeAt(index);
    });

    try {
      await _habitService.deleteHabit(id);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        habits.insert(index, removedHabit);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر حذف العادة: $error',
          ),
        ),
      );
    }
  }

    // ============================================================
  // تحديث حالة المهمة في Supabase
  // ============================================================

  Future<void> _toggleTask(int index) async {
    if (index < 0 || index >= tasks.length) {
      return;
    }

    final task = tasks[index];
    final id = _safeString(task['id']);

    if (id.isEmpty) {
      return;
    }

    final oldValue = _safeBool(
      task['completed'],
    );

    final newValue = !oldValue;

    setState(() {
      tasks[index]['completed'] = newValue;
    });

    try {
      await _taskService.updateTask(
        id: id,
        completed: newValue,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        tasks[index]['completed'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر تحديث المهمة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // حذف المهمة من Supabase
  // ============================================================

  Future<void> _deleteTask(int index) async {
    if (index < 0 || index >= tasks.length) {
      return;
    }

    final task = tasks[index];
    final id = _safeString(task['id']);

    if (id.isEmpty) {
      return;
    }

    final deletedTask =
        Map<String, dynamic>.from(task);

    setState(() {
      tasks.removeAt(index);
    });

    try {
      await _taskService.deleteTask(id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف المهمة',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        tasks.insert(
          index,
          deletedTask,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر حذف المهمة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // إعادة المهمة
  // ============================================================

  Future<void> _resetTask(int index) async {
    if (index < 0 || index >= tasks.length) {
      return;
    }

    final id = _safeString(
      tasks[index]['id'],
    );

    if (id.isEmpty) {
      return;
    }

    final oldValue = _safeBool(
      tasks[index]['completed'],
    );

    setState(() {
      tasks[index]['completed'] = false;
    });

    try {
      await _taskService.updateTask(
        id: id,
        completed: false,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إعادة المهمة',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        tasks[index]['completed'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إعادة المهمة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // بداية واجهة الصفحة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
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
                SizedBox(height: 14),
                _buildTodayButton(),
                SizedBox(height: 14),
                _buildDays(),
                SizedBox(height: 14),
                _buildSummary(),
                SizedBox(height: 14),
                _buildTasks(),
                SizedBox(height: 14),
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildWeeklyGoals(),
                    ),
                    SizedBox(width: 12),
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
            FlumeaBottomNavigation(
          selectedIndex: 1,
        ),
      ),
    );
  }

  // ============================================================
  // رأس الصفحة
  // ============================================================

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
                  Text(
                    'الخطة',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.w800,
                      color: _primaryText,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: _primaryText,
                    size: 30,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
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

  // ============================================================
  // زر اليوم
  // ============================================================

  Widget _buildTodayButton() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = DateTime.now().weekday % 7;
            });
            _loadTasks();
          },
          child: Container(
            padding:
                EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEAF9F4),
              borderRadius:
                  BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اليوم',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.calendar_month_outlined,
                  color: _primaryText,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
    // ============================================================
  // أيام الأسبوع
  // ============================================================

  Widget _buildDays() {
    final today = DateTime.now();
    final startOfWeek = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday % 7));

    names = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final days = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return [
        names[index],
        date.day.toString(),
      ];
    });

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
                  _loadTasks();
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
          EdgeInsets.symmetric(
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? blue
            : Color(0xFFF5F8FC),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? blue
              : Color(0xFFE7ECF2),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            day,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
              color: selected
                  ? Colors.white
                  : Color(0xFF52647A),
            ),
          ),
          SizedBox(height: 5),
          Text(
            number,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
              color: selected
                  ? Colors.white
                  : navy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ملخص اليوم
  // ============================================================

  Widget _buildSummary() {
    final completed = tasks.where(
      (task) => _safeBool(
        task['completed'],
      ),
    ).length;

    final remaining =
        tasks.length - completed;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEAF9F4),
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
                        Text(
                          'خطة اليوم',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                            color: _primaryText,
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          '☀️',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
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

          SizedBox(
            height: 16,
          ),

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
                  Color(
                    0xFFEF5350,
                  ),
                ),
              ),
              Expanded(
                child: _progressCircle(
                  completed:
                      completed,
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

        SizedBox(
          height: 5,
        ),

        Text(
          number,
          style: TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
            color: _primaryText,
          ),
        ),

        Text(
          title,
          textAlign:
              TextAlign.center,
          style: TextStyle(
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
        alignment:
            Alignment.center,
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child:
                CircularProgressIndicator(
              value:
                  progress.clamp(
                0.0,
                1.0,
              ),
              strokeWidth: 7,
              backgroundColor:
                  Color(
                0xFFDDE4ED,
              ),
              valueColor:
                  AlwaysStoppedAnimation<
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
                style:
                    TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                  color: _primaryText,
                ),
              ),
              Text(
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
    // ============================================================
  // قسم المهام
  // ============================================================

  Widget _buildTasks() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFE5EAF0),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              15,
              18,
              10,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_list_bulleted,
                  color: _primaryText,
                  size: 27,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المهام اليوم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                      color: _primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoadingTasks)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 30,
              ),
              child: CircularProgressIndicator(
                color: blue,
              ),
            )
          else if (tasks.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 20,
              ),
              child: Text(
                'لا توجد مهام بعد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B8798),
                  fontSize: 14,
                ),
              ),
            )
          else
            ...List.generate(
              tasks.length,
              (index) => _taskCard(
                tasks[index],
                index,
              ),
            ),

          Padding(
            padding: EdgeInsets.all(14),
            child: GestureDetector(
              onTap: _isSavingTask
                  ? null
                  : _showAddTaskDialog,
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    0xFFEAF4FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSavingTask
                          ? Icons.hourglass_top
                          : Icons.add,
                      color: blue,
                      size: 24,
                    ),
                    SizedBox(width: 5),
                    Text(
                      _isSavingTask
                          ? 'جاري الحفظ...'
                          : 'إضافة مهمة جديدة',
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

  // ============================================================
  // بطاقة المهمة
  // ============================================================

  Widget _taskCard(
    Map<String, dynamic> task,
    int index,
  ) {
    final bool completed =
        _safeBool(
      task['completed'],
    );

    final String title =
        _safeString(
      task['title'],
      fallback: 'مهمة جديدة',
    );

    final String subtitle =
        _safeString(
      task['description'],
      fallback: 'مهمة جديدة',
    );

    final String time =
        _safeString(
      task['time'],
      fallback: 'بدون وقت',
    );

    final String tag =
        _safeString(
      task['tag'],
      fallback: 'عام',
    );

    final String emoji =
        _safeString(
      task['emoji'],
      fallback: '📝',
    );

    final Color color =
        _safeColor(
      task['color'],
    );

    return Container(
      padding:
          EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(
              0xFFE8EDF2,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _toggleTask(index);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration:
                  BoxDecoration(
                color: completed
                    ? blue
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  6,
                ),
                border: Border.all(
                  color: completed
                      ? blue
                      : Color(
                          0xFFB8C2CE,
                        ),
                  width: 2,
                ),
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      color:
                          Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),

          SizedBox(
            width: 12,
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                _toggleTask(index);
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
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                            color: completed
                                ? Color(
                                    0xFF9AA4AE,
                                  )
                                : navy,
                            decoration:
                                completed
                                    ? TextDecoration
                                        .lineThrough
                                    : TextDecoration
                                        .none,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 8,
                      ),

                      Container(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              color.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style:
                                  TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              emoji,
                              style:
                                  TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,
                    textAlign:
                        TextAlign.right,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF7B8798),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: 12,
          ),

          SizedBox(
            width: 58,
            child: Text(
              time,
              textAlign:
                  TextAlign.left,
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF52647A),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          SizedBox(
            width: 5,
          ),

          _buildTaskMenu(index),
        ],
      ),
    );
  }

  // ============================================================
  // قائمة خيارات المهمة
  // ============================================================

  Widget _buildTaskMenu(
    int index,
  ) {
    return PopupMenuButton<String>(
      tooltip:
          'خيارات المهمة',
      padding:
          EdgeInsets.zero,
      icon:
          Icon(
        Icons.more_vert,
        color:
            Color(0xFF6E7A88),
        size: 22,
      ),
      onSelected:
          (value) {
        if (value == 'reset') {
          _resetTask(index);
        }

        if (value == 'delete') {
          _deleteTask(index);
        }
      },
      itemBuilder:
          (context) {
        return [
          PopupMenuItem<String>(
            value: 'reset',
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  'إعادة المهمة 🔄',
                  style:
                      TextStyle(
                    color: _primaryText,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  'حذف المهمة 🗑️',
                  style:
                      TextStyle(
                    color:
                        Color(0xFFD64545),
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
    // ============================================================
  // نافذة إضافة مهمة جديدة
  // ============================================================

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    final categoryController = TextEditingController();
    final emojiController = TextEditingController();

    String selectedCategory = '';

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            child: StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    maxHeight: 760,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'إضافة مهمة جديدة',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: _primaryText,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        'ابدأ بخطوة صغيرة نحو هدفك الكبير',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Color(0xFF7B8798),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.35,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        width: 62,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 94,
                                height: 94,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEAF4FF),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      color: blue,
                                      size: 58,
                                    ),
                                    Positioned(
                                      right: 10,
                                      bottom: 8,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: cyan,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
                                          size: 23,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 18),

                          _modernTaskField(
                            controller: nameController,
                            label: 'اسم المهمة *',
                            hint: '',
                            icon: Icons.edit_outlined,
                            iconBackground: Color(0xFFEAF4FF),
                            iconColor: blue,
                          ),

                          SizedBox(height: 11),

                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: child!,
                                  );
                                },
                              );

                              if (picked == null) {
                                return;
                              }

                              final hour = picked.hourOfPeriod == 0
                                  ? 12
                                  : picked.hourOfPeriod;
                              final minute = picked.minute
                                  .toString()
                                  .padLeft(2, '0');
                              final period = picked.period == DayPeriod.am
                                  ? 'ص'
                                  : 'م';

                              setDialogState(() {
                                timeController.text = '$hour:$minute $period';
                              });
                            },
                            child: AbsorbPointer(
                              child: _modernTaskField(
                                controller: timeController,
                                label: 'الوقت *',
                                hint: '',
                                icon: Icons.access_time_rounded,
                                iconBackground: Color(0xFFFFEEF0),
                                iconColor: Color(0xFFEF5350),
                                suffixIcon: Icons.keyboard_arrow_down_rounded,
                              ),
                            ),
                          ),

                          SizedBox(height: 11),

                          GestureDetector(
                            onTap: () async {
                              final categories = [
                                'دراسة',
                                'صحة',
                                'إنتاجية',
                                'تطوير الذات',
                                'شخصي',
                                'مراجعة',
                                'عام',
                              ];

                              final selected = await showModalBottomSheet<String>(
                                context: dialogContext,
                                backgroundColor: _surfaceColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                ),
                                builder: (sheetContext) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: SafeArea(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          18,
                                          18,
                                          18,
                                          12,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD9E1EA),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            SizedBox(height: 14),
                                            Text(
                                              'اختر التصنيف',
                                              style: TextStyle(
                                                color: _primaryText,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            ...categories.map(
                                              (category) => ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                                title: Text(
                                                  category,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: _primaryText,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                leading: Icon(
                                                  Icons.local_offer_outlined,
                                                  color: blue,
                                                ),
                                                onTap: () {
                                                  Navigator.of(sheetContext)
                                                      .pop(category);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );

                              if (selected == null) {
                                return;
                              }

                              setDialogState(() {
                                selectedCategory = selected;
                                categoryController.text = selected;
                              });
                            },
                            child: AbsorbPointer(
                              child: _modernTaskField(
                                controller: categoryController,
                                label: 'التصنيف *',
                                hint: '',
                                icon: Icons.local_offer_outlined,
                                iconBackground: Color(0xFFFFF3DD),
                                iconColor: Color(0xFFE5A623),
                                suffixIcon:
                                    Icons.keyboard_arrow_down_rounded,
                              ),
                            ),
                          ),

                          SizedBox(height: 11),

                          _modernTaskField(
                            controller: emojiController,
                            label: 'الإيموجي',
                            hint: '',
                            icon: Icons.sentiment_satisfied_alt_outlined,
                            iconBackground: Color(0xFFEDEBFF),
                            iconColor: Color(0xFF6C63C7),
                          ),

                          SizedBox(height: 11),

                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFBFCFE),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Color(0xFFDCE3EC),
                                width: 1.2,
                              ),
                            ),
                            child: TextField(
                              controller: descriptionController,
                              maxLines: 3,
                              maxLength: 100,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                counterStyle: TextStyle(
                                  color: Color(0xFF7B8798),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(
                                  16,
                                  15,
                                  16,
                                  4,
                                ),
                                labelText: 'الوصف',
                                alignLabelWithHint: true,
                                labelStyle: TextStyle(
                                  color: _primaryText,
                                  fontWeight: FontWeight.w700,
                                ),
                                hintText: '',
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                    top: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEAF4FF),
                                        borderRadius:
                                            BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        color: blue,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _isSavingTask
                                      ? null
                                      : () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color(0xFFF0F3F8),
                                    foregroundColor: navy,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      color: _primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton.icon(
                                  onPressed: _isSavingTask
                                      ? null
                                      : () async {
                                          final name =
                                              nameController.text.trim();

                                          if (name.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'اكتب اسم المهمة أولاً',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final time =
                                              timeController.text.trim();
                                          final category =
                                              selectedCategory.isEmpty
                                                  ? categoryController.text.trim()
                                                  : selectedCategory;
                                          final emoji =
                                              emojiController.text.trim();
                                          final description =
                                              descriptionController.text.trim();

                                          setState(() {
                                            _isSavingTask = true;
                                          });

                                          try {
                                            final newTask =
                                                await _taskService.addTask(
                                              title: name,
                                              description: description,
                                              time: time.isEmpty
                                                  ? 'بدون وقت'
                                                  : time,
                                              tag: category.isEmpty
                                                  ? 'عام'
                                                  : category,
                                              emoji: emoji.isEmpty
                                                  ? '📝'
                                                  : emoji,
                                              color: '#1478D4',
                                              completed: false,
                                            );

                                            await _saveTaskDate(
                                              _safeString(newTask['id']),
                                              _selectedDate,
                                            );
                                            newTask['due_date'] =
                                                _dateKey(_selectedDate);

                                            if (!mounted) {
                                              return;
                                            }

                                            setState(() {
                                              tasks.add(newTask);
                                              _isSavingTask = false;
                                            });

                                            if (!dialogContext.mounted) {
                                              return;
                                            }

                                            Navigator.of(dialogContext).pop();

                                            if (!mounted) {
                                              return;
                                            }

                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'تم حفظ المهمة بنجاح ✅',
                                                ),
                                              ),
                                            );
                                          } catch (error) {
                                            if (!mounted) {
                                              return;
                                            }

                                            setState(() {
                                              _isSavingTask = false;
                                            });

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'تعذر حفظ المهمة: $error',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  icon: Icon(
                                    Icons.add,
                                    size: 23,
                                  ),
                                  label: Text(
                                    'إضافة المهمة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Color(0xFFB8CBE0),
                                    disabledForegroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _modernTaskField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    IconData? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFDCE3EC),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint.isEmpty ? null : hint,
          hintStyle: TextStyle(
            color: Color(0xFF8B98A8),
            fontSize: 14,
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: _primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 12,
            ),
            child: Align(
              widthFactor: 1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  color: _primaryText,
                  size: 25,
                ),
        ),
      ),
    );
  }

  // ============================================================
  // حقول نافذة إضافة المهمة
  // ============================================================


  // ============================================================
  // أهداف الأسبوع
  // ============================================================

  Widget _buildWeeklyGoals() {
    return Container(
      padding:
          EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: Color(
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
              Text(
                'أهداف الأسبوع',
                style:
                    TextStyle(
                  color: _primaryText,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Icon(
                Icons.flag_outlined,
                color: _primaryText,
                size: 21,
              ),
            ],
          ),

          SizedBox(
            height: 18,
          ),

          _goalRow(
            'الدراسة',
            4,
            5,
            blue,
          ),

          SizedBox(
            height: 15,
          ),

          _goalRow(
            'الرياضة',
            3,
            5,
            cyan,
          ),

          SizedBox(
            height: 15,
          ),

          _goalRow(
            'القراءة',
            6,
            7,
            Color(
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
                .clamp(
              0.0,
              1.0,
            );

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
              style:
                  TextStyle(
                color: color,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            Text(
              title,
              style:
                  TextStyle(
                color: _primaryText,
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),

        SizedBox(
          height: 7,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          child:
              LinearProgressIndicator(
            value:
                progress,
            minHeight: 7,
            backgroundColor:
                Color(
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
    // ============================================================
  // عادات اليوم
  // ============================================================

  Widget _buildDailyHabits() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xFFE5EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'عادات اليوم',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 7),
              Icon(
                Icons.repeat,
                color: _primaryText,
                size: 21,
              ),
            ],
          ),
          SizedBox(height: 16),
          if (habits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
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
              (index) {
                final habit = habits[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == habits.length - 1 ? 0 : 10,
                  ),
                  child: _buildHabitRow(
                    id: _safeString(habit['id']),
                    title: _safeString(habit['title']),
                    icon: _safeIcon(habit['icon']),
                    completed: _safeBool(habit['completed']),
                  ),
                );
              },
            ),
          SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _isSavingHabit ? null : _showAddHabitDialog,
            icon: Icon(
              _isSavingHabit ? Icons.hourglass_top : Icons.add,
              size: 20,
            ),
            label: Text(
              _isSavingHabit ? 'جاري الحفظ...' : 'إضافة عادة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              side: BorderSide(
                color: blue,
                width: 1.3,
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // بطاقة العادة
  // ============================================================

  Widget _buildHabitRow({
    required String title,
    required IconData icon,
    required bool completed,
    required String id,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: completed
            ? Color(0xFFF1FBF9)
            : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: completed
              ? Color(0xFFD5F0EB)
              : Color(0xFFE7ECF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: completed
                  ? cyan.withValues(alpha: 0.12)
                  : blue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : icon,
              color: completed ? cyan : blue,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: completed
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: navy,
              ),
            ),
          ),
          SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'خيارات العادة',
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF7B8798),
              size: 21,
            ),
            onSelected: (value) async {
              if (value == 'reset') {
                await _resetHabit(id);
              } else if (value == 'delete') {
                await _deleteHabit(id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: blue,
                    ),
                    SizedBox(width: 10),
                    Text('إعادة العادة'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text('حذف العادة'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => _toggleHabit(id, completed),
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: completed ? cyan : (_isDark ? const Color(0xFF171D24) : Colors.white),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: completed
                      ? cyan
                      : Color(0xFFB9C4D0),
                  width: 1.5,
                ),
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      color: _isDark ? const Color(0xFFF7FAFC) : Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // نافذة إضافة عادة
  // ============================================================

  void _showAddHabitDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              'إضافة عادة جديدة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: _habitDialogField(
              controller: nameController,
              label: 'اسم العادة',
              icon: Icons.repeat,
            ),
            actionsPadding: EdgeInsets.fromLTRB(
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
                        Navigator.pop(dialogContext);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFFF1F4F8),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: _primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSavingHabit
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                return;
                              }

                              setState(() {
                                _isSavingHabit = true;
                              });

                              try {
                                final created =
                                    await _habitService.addHabit(
                                  name: name,
                                  description: '',
                                  completed: false,
                                );

                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  habits.add(_habitMap(created));
                                  _isSavingHabit = false;
                                });

                                if (!dialogContext.mounted) {
                                  return;
                                }

                                Navigator.pop(dialogContext);

                                if (!mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم حفظ العادة بنجاح ✅',
                                    ),
                                  ),
                                );
                              } catch (error) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _isSavingHabit = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تعذر حفظ العادة: $error',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'إضافة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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

  // ============================================================
  // حقل نافذة إضافة العادة
  // ============================================================

  Widget _habitDialogField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller:
          controller,
      textAlign:
          TextAlign.right,
      decoration:
          InputDecoration(
        labelText:
            label,
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
              BorderSide(
            color: blue,
            width: 2,
          ),
        ),
      ),
    );
  }
}
