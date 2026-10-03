import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bottom_navigation.dart';
import 'services/task_service.dart';
import 'services/habit_service.dart';
import 'services/flumea_notification_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const Color blue = Color(0xFF1478D4);
  static const Color cyan = Color(0xFF20C7B7);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get navy => _isDark ? const Color(0xFFF2F5F8) : const Color(0xFF102A4C);
  Color get background => _isDark ? const Color(0xFF0B141D) : const Color(0xFFF7FBFF);
  Color get _surface => _isDark ? const Color(0xFF111217) : Colors.white;
  Color get _border => _isDark ? const Color(0xFF34404D) : const Color(0xFFE5EAF0);
  Color get _subtle => _isDark ? const Color(0xFFB5C0CB) : const Color(0xFF52647A);
  Color get _soft => _isDark ? const Color(0xFF151B23) : const Color(0xFFF5F8FC);
  Color get _summary => _isDark ? const Color(0xFF10283A) : const Color(0xFFEAF9F4);
  Color get _taskAdd => _isDark ? const Color(0xFF202A35) : const Color(0xFFEAF4FF);
  Color get _habitDone => _isDark ? const Color(0xFF12302F) : const Color(0xFFF1FBF9);
  Color get _habitDoneBorder => _isDark ? const Color(0xFF24504C) : const Color(0xFFD5F0EB);
  Color get _habitUndone => _isDark ? const Color(0xFF17191E) : const Color(0xFFF8FAFC);
  Color get _habitUndoneBorder => _isDark ? const Color(0xFF303844) : const Color(0xFFE7ECF2);
  Color get _inputBackground => _isDark ? const Color(0xFF1A2028) : const Color(0xFFFBFCFE);
  Color get _inputBorder => _isDark ? const Color(0xFF34414F) : const Color(0xFFDCE3EC);
  Color get _softButton => _isDark ? const Color(0xFF202832) : const Color(0xFFF0F3F8);
  Color get _unselectedControlBorder => _isDark ? const Color(0xFF66727F) : const Color(0xFFB8C2CE);

  final TaskService _taskService = TaskService();
  final HabitService _habitService = HabitService();
  final SupabaseClient _supabase = Supabase.instance.client;
  int selectedDay = DateTime.now().weekday % 7;

  bool _isLoadingTasks = true;
  bool _isSavingTask = false;
  bool _isSavingHabit = false;

  List<Map<String, dynamic>> tasks = [];

  final List<Map<String, dynamic>> habits = [];

  // أهداف الأسبوع تبدأ فارغة، ويمكن إضافة ثلاثة أهداف كحد أقصى.
  final List<Map<String, dynamic>> _weeklyGoals = [];
  int _activeDays = 0;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now().weekday % 7;
    _loadTasks();
    _loadHabits();
    _loadActiveDays();
    _loadWeeklyGoals();
  }

  Future<void> _loadActiveDays() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          setState(() => _activeDays = 0);
        }
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sunday = today.subtract(Duration(days: today.weekday % 7));
      final saturday = sunday.add(const Duration(days: 6));

      // يوم النشاط الحقيقي = أي يوم خلال هذا الأسبوع حدث فيه إنجاز فعلي.
      final activeDates = <String>{};

      final taskResponse = await _supabase
          .from('tasks')
          .select('due_date, completed')
          .eq('user_id', userId)
          .eq('completed', true)
          .gte('due_date', _dateKey(sunday))
          .lte('due_date', _dateKey(saturday));

      for (final row in taskResponse) {
        final date = _safeString(row['due_date']);
        if (date.isNotEmpty) {
          activeDates.add(date.length >= 10 ? date.substring(0, 10) : date);
        }
      }

      // سجلات العادات تعطي التاريخ الحقيقي للإنجازات السابقة، إن كان الجدول موجوداً.
      try {
        final habitLogs = await _supabase
            .from('habit_logs')
            .select('*')
            .eq('user_id', userId);

        for (final row in habitLogs) {
          final completed = row['completed'] == null
              ? true
              : _safeBool(row['completed']);
          if (!completed) continue;

          final rawDate = row['date'] ??
              row['log_date'] ??
              row['completed_at'] ??
              row['created_at'] ??
              row['updated_at'];
          final dateText = _safeString(rawDate);
          if (dateText.length >= 10) {
            final date = dateText.substring(0, 10);
            if (date.compareTo(_dateKey(sunday)) >= 0 &&
                date.compareTo(_dateKey(saturday)) <= 0) {
              activeDates.add(date);
            }
          }
        }
      } catch (_) {
        // جدول habit_logs اختياري؛ لا نوقف حساب الأيام النشطة بسببه.
      }

      // إذا كانت عادة اليوم مكتملة الآن، فهذا نشاط حقيقي لليوم الحالي.
      if (habits.any((habit) => _safeBool(habit['completed']))) {
        activeDates.add(_dateKey(today));
      }

      if (!mounted) return;
      setState(() {
        _activeDays = activeDates.length.clamp(0, 7);
      });
    } catch (_) {
      // لا نوقف الصفحة إذا تعذر حساب الأيام النشطة.
    }
  }

  String get _weeklyGoalsStorageKey {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sunday = today.subtract(Duration(days: today.weekday % 7));
    return 'flumea_weekly_goals_${userId}_${_dateKey(sunday)}';
  }

  Future<void> _loadWeeklyGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_weeklyGoalsStorageKey);

      if (raw == null || raw.isEmpty) {
        if (mounted) {
          setState(() {
            _weeklyGoals.clear();
          });
        }
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final loaded = decoded
          .whereType<Map>()
          .map<Map<String, dynamic>>((item) => {
                'title': _safeString(item['title']),
                'current': int.tryParse(
                      _safeString(item['current'], fallback: '0'),
                    ) ??
                    0,
                'total': 1,
                'color': _safeString(
                  item['color'],
                  fallback: '#1478D4',
                ),
              })
          .where((goal) => _safeString(goal['title']).isNotEmpty)
          .take(3)
          .toList();

      if (!mounted) return;

      setState(() {
        _weeklyGoals
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {
      // لا نوقف الصفحة إذا تعذر تحميل الأهداف المحفوظة.
    }
  }

  Future<void> _saveWeeklyGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _weeklyGoalsStorageKey,
        jsonEncode(_weeklyGoals),
      );
    } catch (_) {
      // الحفظ المحلي لا يجب أن يعطل الصفحة.
    }
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

  // ============================================================
  // SUPABASE - تحميل المهام
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

      // لا ننشئ مهاماً تجريبية للمستخدم الجديد.
      // وإذا كانت النسخ القديمة قد أنشأت المهام الافتراضية لهذا المستخدم،
      // نحذفها فقط عندما تكون كل مهامه من القائمة الافتراضية، حتى تبدأ الخطة فارغة.
      const defaultTaskTitles = {
        'الاستيقاظ',
        'الرياضة',
        'الإفطار',
        'الدراسة',
        'المهام الشخصية',
        'القراءة',
        'مراجعة اليوم',
      };

      if (allTasks.isNotEmpty &&
          allTasks.every((task) =>
              defaultTaskTitles.contains(_safeString(task['title'])))) {
        for (final task in allTasks) {
          final id = _safeString(task['id']);
          if (id.isEmpty) continue;
          try {
            await _taskService.deleteTask(id);
          } catch (_) {}
        }
        allTasks.clear();
      }

      if (allTasks.isEmpty) {
        if (!mounted) return;
        setState(() {
          tasks = [];
          _isLoadingTasks = false;
        });
        return;
      }

      // المهام القديمة التي لا تملك تاريخاً تُربط باليوم الحالي المعروض
      // مرة واحدة حتى لا تختفي من التطبيق بعد إضافة نظام الأيام.
      for (final task in allTasks) {
        final id = _safeString(task['id']);
        final dueDate = _safeString(task['due_date']);

        if (id.isNotEmpty && dueDate.isEmpty) {
          try {
            await _saveTaskDate(id, _selectedDate);
            task['due_date'] = _dateKey(_selectedDate);
          } catch (_) {
            // لا نوقف تحميل بقية المهام إذا تعذر تحديث مهمة قديمة.
          }
        }
      }

      final selectedDateKey = _dateKey(_selectedDate);
      final selectedTasks = allTasks.where((task) {
        return _safeString(task['due_date']) == selectedDateKey;
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

      FlumeaNotificationService.showTopMessage(context, 'تعذر تحميل المهام: $error');
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

      // لا ننشئ عادات افتراضية للمستخدم الجديد.
      // وإذا كانت النسخ القديمة قد أنشأت العادات الافتراضية فقط، نحذفها
      // حتى تبدأ صفحة الخطة فارغة.
      const defaultHabitNames = {
        'شرب الماء',
        'الرياضة',
        'القراءة',
      };

      if (loadedHabits.isNotEmpty &&
          loadedHabits.every((habit) =>
              defaultHabitNames.contains(_safeString(habit['name'])))) {
        for (final habit in loadedHabits) {
          final id = _safeString(habit['id']);
          if (id.isEmpty) continue;
          try {
            await _habitService.deleteHabit(id);
          } catch (_) {}
        }
        loadedHabits.clear();
      }

      if (loadedHabits.isEmpty) {
        if (!mounted) return;
        setState(() {
          habits.clear();
        });
        await _loadActiveDays();
        return;
      }

      setState(() {
        habits.clear();
        for (final habit in loadedHabits) {
          habits.add(_habitMap(habit));
        }
      });
      await _loadActiveDays();
    } catch (error) {
      if (!mounted) {
        return;
      }

      FlumeaNotificationService.showTopMessage(context, 'تعذر تحميل العادات: $error');
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

      await _loadActiveDays();

      if (newValue) {
        await FlumeaNotificationService.instance.show(
          title: 'تم إكمال العادة اليومية! 🎯',
          body: 'أحسنت! استمر على هذا التقدم.',
          type: FlumeaNotificationType.habit,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        habits[index]['completed'] = completed;
      });

      FlumeaNotificationService.showTopMessage(context, 'تعذر تحديث العادة: $error');
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

      FlumeaNotificationService.showTopMessage(context, 'تعذر حذف العادة: $error');
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

      await _loadActiveDays();

      if (newValue) {
        await FlumeaNotificationService.instance.show(
          title: 'تم إكمال المهمة! 📝',
          body: 'أحسنت! استمر في تنفيذ مهامك اليومية.',
          type: FlumeaNotificationType.task,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        tasks[index]['completed'] = oldValue;
      });

      FlumeaNotificationService.showTopMessage(context, 'تعذر تحديث المهمة: $error');
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

      FlumeaNotificationService.showTopMessage(context, 'تم حذف المهمة');
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

      FlumeaNotificationService.showTopMessage(context, 'تعذر حذف المهمة: $error');
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
        backgroundColor: background,
        body: SafeArea(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                (MediaQuery.sizeOf(context).width / 600.0)
                    .clamp(0.76, 1.0)
                    .toDouble(),
              ),
            ),
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
        ),
        bottomNavigationBar:
            const FlumeaBottomNavigation(
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
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'FLUMEA',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.2,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'الخطة',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: navy,
                    size: 25,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'نظم يومك وحقق أهدافك',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _subtle,
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
          MainAxisAlignment.start,
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
              color: _summary,
              borderRadius:
                  BorderRadius.circular(28),
            ),
            child: Row(
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
    // ============================================================
  // أيام الأسبوع
  // ============================================================

  Widget _buildDays() {
    const dayNames = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sunday = today.subtract(Duration(days: today.weekday % 7));
    final days = List.generate(7, (index) {
      final date = sunday.add(Duration(days: index));
      return [dayNames[index], date.day.toString()];
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
            : _soft,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? blue
              : _habitUndoneBorder,
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
                  : _subtle,
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
        color: _summary,
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
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      children: [
                        Text(
                          'خطة اليوم',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                            color: navy,
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
                  '$_activeDays',
                  'يوم نشط',
                  const Color(
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
            color: navy,
          ),
        ),

        Text(
          title,
          textAlign:
              TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: _subtle,
          ),
        ),
      ],
    );
  }

  Widget _progressCircle({
    required int completed,
  }) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final progress = tasks.isEmpty
        ? 0.0
        : completed / tasks.length;

    return SizedBox(
      width: compact ? 62 : 70,
      height: compact ? 62 : 70,
      child: Stack(
        alignment:
            Alignment.center,
        children: [
          SizedBox(
            width: compact ? 58 : 65,
            height: compact ? 58 : 65,
            child:
                CircularProgressIndicator(
              value:
                  progress.clamp(
                0.0,
                1.0,
              ),
              strokeWidth: compact ? 6 : 7,
              backgroundColor:
                  const Color(
                0xFFDDE4ED,
              ),
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
                style:
                    TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight:
                      FontWeight.w800,
                  color: navy,
                ),
              ),
              Text(
                'مكتملة',
                style: TextStyle(
                  fontSize: compact ? 8 : 9,
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
        color: _surface,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: _border,
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
                Expanded(
                  child: Text(
                    'مهام اليوم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                      color: navy,
                    ),
                  ),
                ),
                Icon(
                  Icons.format_list_bulleted,
                  color: navy,
                  size: 27,
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
                  color: _subtle,
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
                  color: _taskAdd,
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
    final compact = MediaQuery.sizeOf(context).width < 600;
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
        horizontal: compact ? 9 : 16,
        vertical: compact ? 9 : 14,
      ),
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _toggleTask(index);
            },
            child: Container(
              width: compact ? 22 : 28,
              height: compact ? 22 : 28,
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
                      : const Color(
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
                      size: compact ? 15 : 20,
                    )
                  : null,
            ),
          ),

          SizedBox(
            width: compact ? 7 : 12,
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
                            fontSize: compact ? 12 : 16,
                            fontWeight:
                                FontWeight.w800,
                            color: completed
                                ? const Color(
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
                        width: compact ? 5 : 8,
                      ),

                      Container(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: compact ? 7 : 10,
                          vertical: compact ? 4 : 6,
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
                                fontSize: compact ? 8 : 11,
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
                                fontSize: compact ? 10 : 13,
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
                      fontSize: compact ? 10 : 12,
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
            width: compact ? 42 : 58,
            child: Text(
              time,
              textAlign:
                  TextAlign.left,
              style:
                  TextStyle(
                fontSize: compact ? 10 : 13,
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
          _showResetTaskDialog(index);
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
                    color: navy,
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
  // معلومات المهمة عند إعادة المهمة
  // ============================================================

  void _showResetTaskDialog(int index) {
    if (index < 0 || index >= tasks.length) return;

    final task = Map<String, dynamic>.from(tasks[index]);
    _showAddTaskDialog(
      initialTask: task,
      taskIndex: index,
    );
  }

  // ============================================================
  // نافذة إضافة مهمة جديدة
  // ============================================================

  void _showAddTaskDialog({
    Map<String, dynamic>? initialTask,
    int? taskIndex,
  }) {
    final nameController = TextEditingController(
      text: _safeString(initialTask?['title']),
    );
    final timeController = TextEditingController(
      text: _safeString(initialTask?['time']),
    );
    final categoryController = TextEditingController(
      text: _safeString(initialTask?['tag']),
    );
    final emojiController = TextEditingController(
      text: _safeString(initialTask?['emoji']),
    );

    String selectedCategory = _safeString(initialTask?['tag']);
    final isReset = initialTask != null && taskIndex != null;

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
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                    maxHeight: 760,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
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
                                          color: navy,
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
                                          color: _subtle,
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
                                  color: _taskAdd,
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
                                          color: Colors.white,
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
                            iconBackground: _taskAdd,
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
                                iconBackground: const Color(0xFFFFEEF0),
                                iconColor: const Color(0xFFEF5350),
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
                                backgroundColor: _surface,
                                shape: const RoundedRectangleBorder(
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
                                                color: const Color(0xFFD9E1EA),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            SizedBox(height: 14),
                                            Text(
                                              'اختر التصنيف',
                                              style: TextStyle(
                                                color: navy,
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
                                                    color: navy,
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
                                iconBackground: const Color(0xFFFFF3DD),
                                iconColor: const Color(0xFFE5A623),
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
                            iconBackground: const Color(0xFFEDEBFF),
                            iconColor: const Color(0xFF6C63C7),
                          ),

                          SizedBox(height: 11),

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
                                        _softButton,
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
                                      color: navy,
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
                                            FlumeaNotificationService.showTopMessage(context, 'اكتب اسم المهمة أولاً');
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
                                          setState(() {
                                            _isSavingTask = true;
                                          });

                                          try {
                                            final userId =
                                                _supabase.auth.currentUser?.id;
                                            if (userId == null) {
                                              throw Exception('يجب تسجيل الدخول أولاً');
                                            }

                                            final values = {
                                              'title': name,
                                              'description': _safeString(
                                                initialTask?['description'],
                                              ),
                                              'time': time.isEmpty
                                                  ? 'بدون وقت'
                                                  : time,
                                              'tag': category.isEmpty
                                                  ? 'عام'
                                                  : category,
                                              'emoji': emoji.isEmpty
                                                  ? '📝'
                                                  : emoji,
                                              'completed': false,
                                            };

                                            if (isReset) {
                                              final id = _safeString(initialTask['id']);
                                              if (id.isEmpty) {
                                                throw Exception('معرّف المهمة غير موجود');
                                              }

                                              final response = await _supabase
                                                  .from('tasks')
                                                  .update(values)
                                                  .eq('id', id)
                                                  .eq('user_id', userId)
                                                  .select()
                                                  .single();

                                              final updatedTask =
                                                  Map<String, dynamic>.from(response);

                                              if (!mounted) return;

                                              setState(() {
                                                tasks[taskIndex] = updatedTask;
                                                _isSavingTask = false;
                                              });

                                              await _loadActiveDays();

                                              if (!mounted) return;
                                              if (!dialogContext.mounted) return;
                                              Navigator.of(dialogContext).pop();

                                              if (!mounted) return;
                                              FlumeaNotificationService.showTopMessage(
                                                context,
                                                'تم تحديث المهمة وإعادتها بنجاح ✅',
                                              );
                                            } else {
                                              final response = await _supabase
                                                  .from('tasks')
                                                  .insert({
                                                'user_id': userId,
                                                ...values,
                                                'color': '#1478D4',
                                                'due_date': _dateKey(_selectedDate),
                                              })
                                                  .select()
                                                  .single();

                                              final newTask =
                                                  Map<String, dynamic>.from(response);

                                              if (!mounted) return;

                                              setState(() {
                                                tasks.add(newTask);
                                                _isSavingTask = false;
                                              });

                                              if (!dialogContext.mounted) return;
                                              Navigator.of(dialogContext).pop();

                                              FlumeaNotificationService.showTopMessage(
                                                context,
                                                'تم حفظ المهمة بنجاح ✅',
                                              );

                                              await FlumeaNotificationService
                                                  .instance
                                                  .show(
                                                title: 'لديك مهمة جديدة! 📝',
                                                body: 'حان وقت تنفيذ مهمتك التالية.',
                                                type: FlumeaNotificationType.task,
                                              );
                                            }
                                          } catch (error) {
                                            if (!mounted) {
                                              return;
                                            }

                                            setState(() {
                                              _isSavingTask = false;
                                            });

                                            FlumeaNotificationService.showTopMessage(context, 'تعذر حفظ المهمة: $error');
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
                                        const Color(0xFFB8CBE0),
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
        color: _inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _inputBorder,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: navy,
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
            color: navy,
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
                  color: navy,
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
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'أهداف الأسبوع',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: navy,
                  fontSize: compact ? 14 : 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                Icons.flag_outlined,
                color: navy,
                size: 21,
              ),
            ],
          ),
          if (_weeklyGoals.isEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'لا توجد أهداف أسبوعية بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _subtle,
                fontSize: 13,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            ...List.generate(
              _weeklyGoals.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == _weeklyGoals.length - 1 ? 0 : 10,
                ),
                child: _goalRow(index, _weeklyGoals[index]),
              ),
            ),
          ],
          SizedBox(height: compact ? 10 : 14),
          OutlinedButton.icon(
            onPressed: _weeklyGoals.length >= 3
                ? null
                : _showAddWeeklyGoalDialog,
            icon: Icon(
              _weeklyGoals.length >= 3
                  ? Icons.block_outlined
                  : Icons.add,
              size: 20,
            ),
            label: Text(
              _weeklyGoals.length >= 3 ? 'الحد الأقصى 3 أهداف' : 'إضافة هدف',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              disabledForegroundColor: _subtle,
              side: BorderSide(color: blue, width: 1.3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalRow(int index, Map<String, dynamic> goal) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final title = _safeString(goal['title'], fallback: 'هدف أسبوعي');
    final current = (goal['current'] as int?) ?? 0;
    const total = 1;
    final completed = current >= total;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: completed ? _habitDone : _habitUndone,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: completed ? _habitDoneBorder : _habitUndoneBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 30 : 38,
            height: compact ? 30 : 38,
            decoration: BoxDecoration(
              color: completed
                  ? cyan.withValues(alpha: 0.12)
                  : blue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.flag_outlined,
              color: completed ? cyan : blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: navy,
                fontSize: compact ? 11 : 14,
                fontWeight: FontWeight.w700,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          SizedBox(width: compact ? 2 : 4),
          PopupMenuButton<String>(
            tooltip: 'خيارات الهدف',
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              color: const Color(0xFF7B8798),
              size: compact ? 17 : 21,
            ),
            onSelected: (value) async {
              if (value == 'reset') {
                _showResetGoalDialog(index);
              } else if (value == 'delete') {
                setState(() {
                  _weeklyGoals.removeAt(index);
                });
                await _saveWeeklyGoals();
                if (mounted) {
                  FlumeaNotificationService.showTopMessage(
                    context,
                    'تم حذف الهدف',
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.refresh_rounded, color: blue),
                    const SizedBox(width: 10),
                    Text(
                      'إعادة الهدف',
                      style: TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.delete_outline_rounded, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'حذف الهدف',
                      style: TextStyle(
                        color: Color(0xFFD64545),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              setState(() {
                _weeklyGoals[index]['current'] = completed ? 0 : 1;
              });
              await _saveWeeklyGoals();
            },
            child: Container(
              width: compact ? 19 : 23,
              height: compact ? 19 : 23,
              decoration: BoxDecoration(
                color: completed ? cyan : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: completed ? cyan : _unselectedControlBorder,
                  width: 1.5,
                ),
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: compact ? 13 : 16,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetGoalDialog(int index) {
    if (index < 0 || index >= _weeklyGoals.length) return;

    _showAddWeeklyGoalDialog(goalIndex: index);
  }

  void _showAddWeeklyGoalDialog({
    int? goalIndex,
  }) {
    final initialTitle = goalIndex != null &&
            goalIndex >= 0 &&
            goalIndex < _weeklyGoals.length
        ? _safeString(_weeklyGoals[goalIndex]['title'])
        : '';
    final titleController = TextEditingController(text: initialTitle);
    final isReset = goalIndex != null;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            title: Text(
              'إضافة هدف أسبوعي',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: TextField(
              controller: titleController,
              textAlign: TextAlign.right,
              style: TextStyle(color: navy),
              decoration: InputDecoration(
                labelText: 'اسم الهدف',
                hintText: 'اسم الهدف',
                hintStyle: TextStyle(color: _subtle),
                labelStyle: TextStyle(color: navy),
                filled: true,
                fillColor: _inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: blue, width: 1.5),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('إلغاء', style: TextStyle(color: _subtle)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    return;
                  }

                  if (isReset) {
                    if (goalIndex < 0 || goalIndex >= _weeklyGoals.length) {
                      return;
                    }

                    setState(() {
                      _weeklyGoals[goalIndex]['title'] = title;
                      _weeklyGoals[goalIndex]['current'] = 0;
                    });

                    await _saveWeeklyGoals();

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);

                    if (mounted) {
                      FlumeaNotificationService.showTopMessage(
                        context,
                        'تم تحديث الهدف وإعادته بنجاح ✅',
                      );
                    }
                    return;
                  }

                  if (_weeklyGoals.length >= 3) {
                    return;
                  }

                  const colors = [
                    blue,
                    cyan,
                    Color(0xFF8E44AD),
                  ];
                  final colorIndex = _weeklyGoals.length.clamp(0, 2);

                  setState(() {
                    _weeklyGoals.add({
                      'title': title,
                      'current': 0,
                      'total': 1,
                      'color': '#${colors[colorIndex].toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                    });
                  });

                  await _saveWeeklyGoals();

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.add),
                label: const Text('إضافة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // عادات اليوم
  // ============================================================

  Widget _buildDailyHabits() {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'عادات اليوم',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: compact ? 5 : 7),
              Icon(
                Icons.repeat,
                color: navy,
                size: compact ? 17 : 21,
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 16),
          if (habits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 8 : 12),
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
              size: compact ? 16 : 20,
            ),
            label: Text(
              _isSavingHabit ? 'جاري الحفظ...' : 'إضافة عادة',
              style: TextStyle(
                fontSize: compact ? 11 : 14,
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
  // معلومات العادة عند إعادة العادة
  // ============================================================

  void _showResetHabitDialog(String id) {
    final index = habits.indexWhere(
      (habit) => _safeString(habit['id']) == id,
    );
    if (index == -1) return;

    final habit = Map<String, dynamic>.from(habits[index]);
    _showAddHabitDialog(
      initialHabit: habit,
      habitId: id,
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
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 13,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: completed
            ? _habitDone
            : _habitUndone,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: completed
              ? _habitDoneBorder
              : _habitUndoneBorder,
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
              size: compact ? 16 : 20,
            ),
          ),
          SizedBox(width: compact ? 7 : 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: navy,
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
                _showResetHabitDialog(id);
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
          SizedBox(width: compact ? 2 : 4),
          GestureDetector(
            onTap: () => _toggleHabit(id, completed),
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: completed ? cyan : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: completed
                      ? cyan
                      : _unselectedControlBorder,
                  width: 1.5,
                ),
              ),
              child: completed
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
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

  void _showAddHabitDialog({
    Map<String, dynamic>? initialHabit,
    String? habitId,
  }) {
    final nameController = TextEditingController(
      text: _safeString(initialHabit?['title']),
    );
    final isReset = initialHabit != null && habitId != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: Text(
              'إضافة عادة جديدة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
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
                        backgroundColor: _softButton,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: navy,
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
                                if (isReset) {
                                  final userId = _supabase.auth.currentUser?.id;
                                  if (userId == null) {
                                    throw Exception('يجب تسجيل الدخول أولاً');
                                  }

                                  final response = await _supabase
                                      .from('habits')
                                      .update({
                                        'name': name,
                                        'completed': false,
                                      })
                                      .eq('id', habitId)
                                      .eq('user_id', userId)
                                      .select()
                                      .single();

                                  final updated = _habitMap(
                                    Map<String, dynamic>.from(response),
                                  );

                                  if (!mounted) return;

                                  final index = habits.indexWhere(
                                    (habit) =>
                                        _safeString(habit['id']) == habitId,
                                  );

                                  setState(() {
                                    if (index != -1) {
                                      habits[index] = updated;
                                    }
                                    _isSavingHabit = false;
                                  });

                                  await _loadActiveDays();

                                  if (!mounted) return;
                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);

                                  if (!mounted) return;
                                  FlumeaNotificationService.showTopMessage(
                                    context,
                                    'تم تحديث العادة وإعادتها بنجاح ✅',
                                  );
                                } else {
                                  final created =
                                      await _habitService.addHabit(
                                    name: name,
                                    description: '',
                                    completed: false,
                                  );

                                  if (!mounted) return;

                                  setState(() {
                                    habits.add(_habitMap(created));
                                    _isSavingHabit = false;
                                  });

                                  if (!dialogContext.mounted) return;
                                  Navigator.pop(dialogContext);

                                  if (!mounted) return;

                                  FlumeaNotificationService.showTopMessage(
                                    context,
                                    'تم حفظ العادة بنجاح ✅',
                                  );

                                  await FlumeaNotificationService.instance.show(
                                    title: 'تذكير بالعادات 📈',
                                    body: 'تمت إضافة عادة جديدة إلى خطتك اليومية.',
                                    type: FlumeaNotificationType.habit,
                                  );
                                }
                              } catch (error) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _isSavingHabit = false;
                                });

                                FlumeaNotificationService.showTopMessage(context, 'تعذر حفظ العادة: $error');
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
