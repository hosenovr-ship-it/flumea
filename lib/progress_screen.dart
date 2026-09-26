import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bottom_navigation.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  static const Color navy = Color(0xFF102A4C);
  static const Color blue = Color(0xFF1976D2);
  static const Color green = Color(0xFF18B77A);
  static const Color lightBlue = Color(0xFFEAF4FF);
  static const Color lightGreen = Color(0xFFEAF9F2);
  static const Color lightYellow = Color(0xFFFFF8E8);
  final SupabaseClient _supabase = Supabase.instance.client;
  int _selectedPeriod = 0;
  bool _loading = true;
  String? _error;
  _ProgressData _data = _ProgressData.empty();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _data = _ProgressData.empty();
          _loading = false;
          _error = 'يجب تسجيل الدخول لعرض تقدمك.';
        });
        return;
      }

      // نحمّل كل جدول بشكل مستقل حتى لا تتعطل صفحة التقدم بالكامل
      // إذا كان أحد الجداول فارغًا أو كانت سياساته مختلفة.
      final habits = await _safeSelect(
        table: 'habits',
        columns: 'id, name, created_at, completed, user_id',
        userId: user.id,
      );

      final habitLogs = await _safeSelect(
        table: 'habit_logs',
        columns: 'id, habit_id, completed_date, completed, created_at, user_id',
        userId: user.id,
      );

      final tasks = await _safeSelect(
        table: 'tasks',
        columns: 'id, title, completed, due_date, created_at, user_id, tag',
        userId: user.id,
      );

      final goals = await _safeSelect(
        table: 'goals',
        columns: 'id, title, description, target_date, completed, created_at, user_id',
        userId: user.id,
      );

      final data = _buildProgressData(
        habits: habits,
        habitLogs: habitLogs,
        tasks: tasks,
        goals: goals,
      );

      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _data = _ProgressData.empty();
        _error = null;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _safeSelect({
    required String table,
    required String columns,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .select(columns)
          .eq('user_id', userId);
      return _asMaps(response);
    } catch (_) {
      // إذا فشل جدول واحد، لا نمنع بقية صفحة التقدم من الظهور.
      return <Map<String, dynamic>>[];
    }
  }

  List<Map<String, dynamic>> _asMaps(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  _ProgressData _buildProgressData({
    required List<Map<String, dynamic>> habits,
    required List<Map<String, dynamic>> habitLogs,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> goals,
  }) {
    final range = _periodRange(_selectedPeriod);
    final previous = _previousPeriodRange(_selectedPeriod);

    final periodLogs = habitLogs.where((log) {
      final date =
          _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end) &&
          _asBool(log['completed']);
    }).toList();

    final periodTasks = tasks.where((task) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end) &&
          _asBool(task['completed']);
    }).toList();

    // الصفحة الرئيسية تعتمد على قيمة completed الموجودة في habits،
    // بينما habit_logs يسجل إكمال كل يوم. نستخدم المصدرين معًا حتى
    // تبقى صفحة التقدم متطابقة مع الصفحة الرئيسية حتى لو لم يوجد log.
    final today = _dateOnly(DateTime.now());

    final completedTodayFromLogs = <String>{};
    for (final log in habitLogs) {
      final date =
          _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      final id = log['habit_id']?.toString();
      if (id != null &&
          date != null &&
          _dateOnly(date) == today &&
          _asBool(log['completed'])) {
        completedTodayFromLogs.add(id);
      }
    }

    final completedTodayFromHabits = <String>{};
    for (final habit in habits) {
      final id = habit['id']?.toString();
      if (id != null && _asBool(habit['completed'])) {
        final created = _readDate(habit['created_at']);
        if (created == null || !created.isAfter(today)) {
          completedTodayFromHabits.add(id);
        }
      }
    }

    final completedTodayIds = <String>{
      ...completedTodayFromLogs,
      ...completedTodayFromHabits,
    };

    final availableHabitsToday = habits.where((habit) {
      final created = _readDate(habit['created_at']);
      return created == null || !created.isAfter(today);
    }).length;

    final todayCompletedCount = completedTodayIds.length;

    // في اليوم نعرض عدد العادات المكتملة فعليًا، وفي الفترات الأطول
    // نعرض عدد سجلات الإكمال الفريدة (عادة + تاريخ) حتى لا نكرر نفس السجل.
    int completedHabitCount;
    if (_selectedPeriod == 0) {
      completedHabitCount = todayCompletedCount;
    } else {
      final uniqueHabitDays = <String>{};
      for (final log in periodLogs) {
        final habitId = log['habit_id']?.toString();
        final date =
            _readDate(log['completed_date']) ?? _readDate(log['created_at']);
        if (habitId != null && date != null) {
          uniqueHabitDays.add('${habitId}_${_dateKey(date)}');
        }
      }

      // إذا كانت العادة مكتملة اليوم ولكن لم يُحفظ سجلها التاريخي بعد،
      // نستخدم حالة habits.completed حتى لا تظهر الإحصائيات الأسبوعية/الشهرية
      // بصفر بينما الصفحة الرئيسية تعرض العادة مكتملة.
      for (final habit in habits) {
        final id = habit['id']?.toString();
        if (id != null &&
            _asBool(habit['completed']) &&
            !today.isBefore(range.start) &&
            !today.isAfter(range.end)) {
          uniqueHabitDays.add('${id}_${_dateKey(today)}');
        }
      }
      completedHabitCount = uniqueHabitDays.length;
    }

    final activityDates = <String>{};
    for (final log in periodLogs) {
      final date =
          _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      if (date != null) activityDates.add(_dateKey(date));
    }
    for (final task in periodTasks) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      if (date != null) activityDates.add(_dateKey(date));
    }
    if (todayCompletedCount > 0 &&
        !today.isBefore(range.start) &&
        !today.isAfter(range.end)) {
      activityDates.add(_dateKey(today));
    }

    final goalsInProgress =
        goals.where((goal) => !_asBool(goal['completed'])).length;

    final dailyRate = availableHabitsToday == 0
        ? 0.0
        : (todayCompletedCount / availableHabitsToday)
            .clamp(0.0, 1.0)
            .toDouble();

    final chart = _buildHabitChart(habits, periodLogs, range);

    final currentRate = _periodCompletionRate(
      habits: habits,
      logs: habitLogs,
      start: range.start,
      end: range.end,
      fallbackTodayIds: completedTodayIds,
    );

    final previousRate = _periodCompletionRate(
      habits: habits,
      logs: habitLogs,
      start: previous.start,
      end: previous.end,
      fallbackTodayIds: const <String>{},
    );

    double improvement = 0;
    if (previousRate > 0) {
      improvement = ((currentRate - previousRate) / previousRate) * 100;
    } else if (currentRate > 0) {
      improvement = 100;
    }

    final trend = _buildTrendData(
      habits: habits,
      habitLogs: habitLogs,
      range: range,
      fallbackTodayIds: completedTodayIds,
    );

    return _ProgressData(
      activityDays: activityDates.length,
      completedHabitLogs: completedHabitCount,
      goalsInProgress: goalsInProgress,
      dailyRate: dailyRate,
      chartValues: chart.values,
      chartNames: chart.names,
      trendValues: trend.values,
      trendLabels: trend.labels,
      periodLabel: _periodLabel(_selectedPeriod),
      improvement: improvement,
      improvementLabel: previousRate == 0 && currentRate == 0
          ? 'لا توجد بيانات كافية للمقارنة'
          : 'مقارنة بالفترة السابقة',
      achievements: _buildAchievements(
        habitLogs: habitLogs,
        tasks: tasks,
        goals: goals,
        habits: habits,
        completedTodayIds: completedTodayIds,
      ),
      timeSummary: _buildTimeSummary(tasks, range),
    );
  }

  double _periodCompletionRate({
    required List<Map<String, dynamic>> habits,
    required List<Map<String, dynamic>> logs,
    required DateTime start,
    required DateTime end,
    required Set<String> fallbackTodayIds,
  }) {
    if (habits.isEmpty) return 0;

    final availableHabits = habits.where((habit) {
      final created = _readDate(habit['created_at']);
      return created == null || !created.isAfter(end);
    }).length;

    if (availableHabits == 0) return 0;

    final uniqueCompletions = <String>{};
    for (final log in logs) {
      if (!_asBool(log['completed'])) continue;
      final habitId = log['habit_id']?.toString();
      final date =
          _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      if (habitId == null ||
          date == null ||
          date.isBefore(start) ||
          date.isAfter(end)) {
        continue;
      }
      uniqueCompletions.add('${habitId}_${_dateKey(date)}');
    }

    if (start == _dateOnly(DateTime.now()) &&
        end == _dateOnly(DateTime.now())) {
      for (final id in fallbackTodayIds) {
        uniqueCompletions.add('${id}_${_dateKey(start)}');
      }
    }

    final possible = _daysBetween(start, end) * availableHabits;
    if (possible <= 0) return 0;
    return (uniqueCompletions.length / possible).clamp(0.0, 1.0).toDouble();
  }

  _TrendData _buildTrendData({
    required List<Map<String, dynamic>> habits,
    required List<Map<String, dynamic>> habitLogs,
    required _DateRange range,
    required Set<String> fallbackTodayIds,
  }) {
    if (range.start == range.end) {
      final value = _dailyCompletionRate(
        date: range.start,
        habits: habits,
        habitLogs: habitLogs,
        fallbackTodayIds: fallbackTodayIds,
      );
      return _TrendData(
        values: [value],
        labels: ['اليوم'],
      );
    }

    final totalDays = _daysBetween(range.start, range.end);
    int step = 1;

    // نحافظ على الرسم مقروءًا بدل إنشاء عشرات النقاط في "كل الوقت".
    if (totalDays > 31) {
      step = (totalDays / 7).ceil();
    }

    final values = <double>[];
    final labels = <String>[];

    for (int offset = 0; offset < totalDays; offset += step) {
      final date = range.start.add(Duration(days: offset));
      final value = _dailyCompletionRate(
        date: date,
        habits: habits,
        habitLogs: habitLogs,
        fallbackTodayIds: date == _dateOnly(DateTime.now())
            ? fallbackTodayIds
            : const <String>{},
      );
      values.add(value);
      labels.add(_shortArabicDate(date));
    }

    if (values.isEmpty) {
      values.add(0);
      labels.add(_shortArabicDate(range.start));
    }

    return _TrendData(values: values, labels: labels);
  }

  double _dailyCompletionRate({
    required DateTime date,
    required List<Map<String, dynamic>> habits,
    required List<Map<String, dynamic>> habitLogs,
    required Set<String> fallbackTodayIds,
  }) {
    final day = _dateOnly(date);
    final available = habits.where((habit) {
      final created = _readDate(habit['created_at']);
      return created == null || !created.isAfter(day);
    }).length;

    if (available == 0) return 0;

    final completed = <String>{};
    for (final log in habitLogs) {
      if (!_asBool(log['completed'])) continue;
      final habitId = log['habit_id']?.toString();
      final logDate =
          _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      if (habitId != null && logDate != null && _dateOnly(logDate) == day) {
        completed.add(habitId);
      }
    }

    if (day == _dateOnly(DateTime.now())) {
      completed.addAll(fallbackTodayIds);
    }

    return (completed.length / available).clamp(0.0, 1.0).toDouble();
  }

  String _shortArabicDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  _ChartData _buildHabitChart(
    List<Map<String, dynamic>> habits,
    List<Map<String, dynamic>> logs,
    _DateRange range,
  ) {
    if (habits.isEmpty) {
      return const _ChartData(
        values: [0, 0, 0, 0, 0, 0, 0],
        names: ['الصحة', 'الرياضة', 'الدراسة', 'القراءة', 'العمل', 'الماء', 'التأمل'],
      );
    }

    final sortedHabits = [...habits]..sort((a, b) {
      final aDate = _readDate(a['created_at']) ?? DateTime(2000);
      final bDate = _readDate(b['created_at']) ?? DateTime(2000);
      return aDate.compareTo(bDate);
    });

    final selected = sortedHabits.take(7).toList();
    final today = _dateOnly(DateTime.now());
    final values = <double>[];
    final names = <String>[];

    for (final habit in selected) {
      final id = habit['id']?.toString();
      if (id == null) {
        values.add(0);
        names.add('عادة');
        continue;
      }

      final created = _readDate(habit['created_at']);
      final habitStart = created != null && created.isAfter(range.start)
          ? created
          : range.start;
      final possibleDays = _daysBetween(habitStart, range.end).clamp(1, 366);

      // نجمع أيام الإكمال الفعلية لهذا المستخدم والعادة داخل الفترة،
      // ونمنع تكرار نفس اليوم إذا كان هناك أكثر من سجل.
      final completedDays = <String>{};
      for (final log in logs) {
        if (log['habit_id']?.toString() != id || !_asBool(log['completed'])) {
          continue;
        }
        final date =
            _readDate(log['completed_date']) ?? _readDate(log['created_at']);
        if (date == null || date.isBefore(habitStart) || date.isAfter(range.end)) {
          continue;
        }
        completedDays.add(_dateKey(date));
      }

      // habits.completed يمثل حالة اليوم الحالية في التطبيق. لذلك نستخدمه
      // كاحتياط لليوم الحالي إذا لم يكن سجل اليوم موجودًا في habit_logs.
      if (_asBool(habit['completed']) &&
          !today.isBefore(habitStart) &&
          !today.isAfter(range.end)) {
        completedDays.add(_dateKey(today));
      }

      final rate = (completedDays.length / possibleDays)
          .clamp(0.0, 1.0)
          .toDouble();
      values.add(rate);
      names.add((habit['name']?.toString().trim().isNotEmpty ?? false)
          ? habit['name'].toString()
          : 'عادة');
    }

    while (values.length < 7) {
      values.add(0);
      names.add('');
    }

    return _ChartData(values: values, names: names);
  }

  _TimeSummary _buildTimeSummary(
    List<Map<String, dynamic>> tasks,
    _DateRange range,
  ) {
    final periodTasks = tasks.where((task) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end) &&
          _asBool(task['completed']);
    }).toList();

    // The current tasks table stores `time` as a clock-time text (for example
    // "11:29 ص"), not as a duration. Therefore we do not turn clock times into
    // fake hours. We show the completed-task count until a duration column exists.
    final tagCounts = <String, int>{};
    for (final task in periodTasks) {
      final tag = task['tag']?.toString().trim();
      if (tag != null && tag.isNotEmpty) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final entries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _TimeSummary(
      completedTasks: periodTasks.length,
      topTags: entries.take(5).toList(),
    );
  }

  List<_AchievementData> _buildAchievements({
    required List<Map<String, dynamic>> habitLogs,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> habits,
    required Set<String> completedTodayIds,
  }) {
    final result = <_AchievementData>[];

    final completedLogs =
        habitLogs.where((log) => _asBool(log['completed'])).toList();
    final completedTasks =
        tasks.where((task) => _asBool(task['completed'])).toList();
    final completedGoals =
        goals.where((goal) => _asBool(goal['completed'])).length;

    final currentStreak = _currentStreak(habitLogs);

    if (completedTodayIds.isNotEmpty) {
      result.add(_AchievementData(
        Icons.check_circle_rounded,
        green,
        'أكملت ${completedTodayIds.length} من ${habits.length} عادات اليوم',
        'استمر على نفس الإيقاع وحافظ على تقدمك.',
      ));
    }

    if (currentStreak > 0) {
      result.add(_AchievementData(
        Icons.local_fire_department_rounded,
        green,
        'سلسلة عادات: $currentStreak ${currentStreak == 1 ? 'يوم' : 'أيام'}',
        'استمر يومًا بعد يوم لبناء عادة أقوى.',
      ));
    }

    final studyTasks = completedTasks.where((task) {
      final value =
          '${task['title'] ?? ''} ${task['tag'] ?? ''}'.toLowerCase();
      return value.contains('دراسة') ||
          value.contains('قراءة') ||
          value.contains('تعليم');
    }).length;

    if (studyTasks > 0) {
      result.add(_AchievementData(
        Icons.school_rounded,
        blue,
        'أنجزت $studyTasks ${studyTasks == 1 ? 'مهمة' : 'مهام'} مرتبطة بالتعلم',
        'كل جلسة مكتملة تقرّبك من هدفك.',
      ));
    } else if (completedTasks.isNotEmpty) {
      result.add(_AchievementData(
        Icons.task_alt_rounded,
        blue,
        'أنجزت ${completedTasks.length} ${completedTasks.length == 1 ? 'مهمة' : 'مهام'}',
        'تقدمك في المهام يظهر هنا تلقائيًا.',
      ));
    }

    if (completedGoals > 0) {
      result.add(_AchievementData(
        Icons.flag_rounded,
        Colors.orange,
        'أكملت $completedGoals ${completedGoals == 1 ? 'هدفًا' : 'أهدافًا'}',
        'إنجاز حقيقي يُضاف إلى رحلتك.',
      ));
    }

    if (result.isEmpty && completedLogs.isNotEmpty) {
      result.add(_AchievementData(
        Icons.track_changes_rounded,
        blue,
        'سجلت ${completedLogs.length} إكمالات للعادات',
        'كل تسجيل جديد يساعدك على رؤية تقدمك بوضوح.',
      ));
    }

    if (result.isEmpty) {
      result.add(const _AchievementData(
        Icons.auto_awesome_rounded,
        green,
        'ابدأ تسجيل إنجازاتك',
        'أكمل عادة أو مهمة لتظهر إنجازاتك هنا.',
      ));
    }

    return result.take(3).toList();
  }

  int _currentStreak(List<Map<String, dynamic>> logs) {
    final dates = <String>{};
    for (final log in logs) {
      if (!_asBool(log['completed'])) continue;
      final date = _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      if (date != null) dates.add(_dateKey(_dateOnly(date)));
    }

    if (dates.isEmpty) return 0;

    var day = _dateOnly(DateTime.now());
    if (!dates.contains(_dateKey(day))) {
      day = day.subtract(const Duration(days: 1));
      if (!dates.contains(_dateKey(day))) return 0;
    }

    var streak = 0;
    while (dates.contains(_dateKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  _DateRange _periodRange(int period) {
    final today = _dateOnly(DateTime.now());
    if (period == 0) return _DateRange(today, today);
    if (period == 1) {
      return _DateRange(today.subtract(const Duration(days: 6)), today);
    }
    return _DateRange(DateTime(today.year, today.month, 1), today);
  }

  _DateRange _previousPeriodRange(int period) {
    final current = _periodRange(period);
    final length = _daysBetween(current.start, current.end);
    final end = current.start.subtract(const Duration(days: 1));
    return _DateRange(end.subtract(Duration(days: length - 1)), end);
  }

  String _periodLabel(int period) {
    switch (period) {
      case 0:
        return 'اليوم';
      case 1:
        return 'آخر 7 أيام';
      default:
        return 'هذا الشهر';
    }
  }

  DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return _dateOnly(value);
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    return parsed == null ? null : _dateOnly(parsed);
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  String _dateKey(DateTime date) {
    final d = _dateOnly(date);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  int _daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
  }

  String _formatImprovement(double value) {
    final rounded = value.round();
    if (rounded == 0) return '0%';
    return rounded > 0 ? '+$rounded%' : '$rounded%';
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _pageBackground =>
      _isDark ? const Color(0xFF08111A) : const Color(0xFFF7FAFD);

  Color get _cardBackground =>
      _isDark ? const Color(0xFF101116) : Colors.white;

  Color get _primaryText =>
      _isDark ? const Color(0xFFF2F5F7) : navy;

  Color get _secondaryText =>
      _isDark ? const Color(0xFF9AA7B8) : const Color(0xFF7B8798);

  Color get _borderColor =>
      _isDark ? const Color(0xFF2B3542) : const Color(0xFFE5EBF1);

  Color get _periodBackground =>
      _isDark ? const Color(0xFF172A3A) : const Color(0xFFEAF4FF);

  Color get _greenBackground =>
      _isDark ? const Color(0xFF103833) : lightGreen;

  Color get _blueBackground =>
      _isDark ? const Color(0xFF102A42) : lightBlue;

  Color get _yellowBackground =>
      _isDark ? const Color(0xFF3A2F18) : lightYellow;

  Color get _progressTrack =>
      _isDark ? const Color(0xFF28343D) : const Color(0xFFE5EEE9);

  Color get _circleTrack =>
      _isDark ? const Color(0xFF29323C) : const Color(0xFFE9EEF4);

  Color get _dividerColor =>
      _isDark ? const Color(0xFF303844) : const Color(0xFFE9EEF4);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: _loading
                  ? const SizedBox(
                      height: 650,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _error != null
                      ? _errorView()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _header(),
                            const SizedBox(height: 18),
                            _periodSelector(),
                            const SizedBox(height: 18),
                            _statsRow(),
                            const SizedBox(height: 16),
                            _habitChart(),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _timeCard()),
                                const SizedBox(width: 12),
                                Expanded(child: _improvementCard()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _achievementsCard(),
                          ],
                        ),
            ),
          ),
        ),
        bottomNavigationBar: const FlumeaBottomNavigation(selectedIndex: 2),
      ),
    );
  }

  Widget _errorView() {
    return SizedBox(
      height: 650,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: _primaryText, size: 45),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _primaryText, fontSize: 15),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadProgress,
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: _primaryText, size: 30),
            const SizedBox(width: 8),
            Text(
              'التقدم',
              style: TextStyle(
                color: _primaryText,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'رحلتك نحو نسخة أفضل من نفسك',
          style: TextStyle(color: _secondaryText, fontSize: 16),
        ),
      ],
    );
  }

  Widget _periodSelector() {
    const titles = ['اليوم', 'الأسبوع', 'الشهر'];
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: List.generate(titles.length, (index) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (_selectedPeriod == index) return;
                setState(() => _selectedPeriod = index);
                _loadProgress();
              },
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _selectedPeriod == index
                      ? _periodBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  titles[index],
                  style: TextStyle(
                    color: _selectedPeriod == index ? blue : _primaryText,
                    fontSize: 15,
                    fontWeight: _selectedPeriod == index
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department_rounded,
            value: '${_data.activityDays}',
            title: 'أيام النشاط',
            background: _greenBackground,
            iconColor: green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.track_changes_rounded,
            value: '${_data.completedHabitLogs}',
            title: 'العادات المكتملة',
            background: _blueBackground,
            iconColor: blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.flag_rounded,
            value: '${_data.goalsInProgress}',
            title: 'الأهداف قيد العمل',
            background: _yellowBackground,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 38),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: _primaryText,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: iconColor == blue ? blue : _primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitChart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: _primaryText, size: 25),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'معدل إكمال العادات',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: _greenBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatPercent(_data.dailyRate),
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'معدل اليوم',
                      style: TextStyle(color: _primaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_periodLabel(_selectedPeriod)} · ${_todayArabicDate()}',
            textAlign: TextAlign.right,
            style: TextStyle(color: _secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _habitOverallProgressBar(),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_data.chartValues.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 28,
                              height: 130 * _data.chartValues[index],
                              decoration: BoxDecoration(
                                color: green,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _data.chartNames[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitOverallProgressBar() {
    final value = _data.dailyRate.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'معدل إكمال العادة اليوم',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _formatPercent(value),
              style: TextStyle(
                color: green,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: _progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(green),
          ),
        ),
      ],
    );
  }

  String _todayArabicDate() {
    final now = DateTime.now();
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  Widget _timeCard() {
    final entries = _data.timeSummary.topTags;
    final labels = <String>[];
    final values = <String>[];
    for (final entry in entries.take(5)) {
      labels.add(entry.key);
      values.add('${entry.value} مهمة');
    }
    while (labels.length < 5) {
      labels.add('');
      values.add('');
    }

    return Container(
      height: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'معدل إكمال المهام',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.access_time_rounded, color: _primaryText),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _data.timeSummary.completedTasks == 0
                ? 'لا توجد مهام مكتملة في ${_periodLabel(_selectedPeriod)}'
                : '${_data.timeSummary.completedTasks} مهام مكتملة في ${_periodLabel(_selectedPeriod)}',
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 125,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: _data.timeSummary.completedTasks == 0 ? 0 : 1,
                          strokeWidth: 20,
                          backgroundColor: _circleTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(blue),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_data.timeSummary.completedTasks}',
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'مهام',
                            style: TextStyle(color: _secondaryText, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(5, (index) {
                      if (labels[index].isEmpty) return const SizedBox(height: 31);
                      return _Legend(
                        color: _legendColors[index],
                        title: labels[index],
                        value: values[index],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const List<Color> _legendColors = [
    blue,
    green,
    Colors.orange,
    Colors.purple,
    Color(0xFF9AA7B8),
  ];

  Widget _improvementCard() {
    final improvement = _data.improvement;
    final color = improvement >= 0 ? green : Colors.redAccent;

    return Container(
      height: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'تحسنك عبر الوقت',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.trending_up_rounded, color: _primaryText),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _data.improvementLabel,
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                improvement >= 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
                size: 25,
              ),
              const SizedBox(width: 5),
              Text(
                _formatImprovement(improvement),
                style: TextStyle(
                  color: color,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            improvement == 0 ? 'لا يوجد تغير' : 'تغير في معدل الإكمال',
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(
                values: _data.trendValues,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _data.trendLabels.isEmpty ? 'البداية' : _data.trendLabels.first,
                style: TextStyle(fontSize: 11, color: _secondaryText),
              ),
              Text(
                _data.trendLabels.length < 2
                    ? 'الآن'
                    : _data.trendLabels.last,
                style: TextStyle(fontSize: 11, color: _secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: _primaryText, size: 25),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'أبرز إنجازاتك',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._data.achievements.map(
            (item) => _achievement(item.icon, item.color, item.title, item.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _achievement(
    IconData icon,
    Color color,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF7B8798),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressData {
  final int activityDays;
  final int completedHabitLogs;
  final int goalsInProgress;
  final double dailyRate;
  final List<double> chartValues;
  final List<String> chartNames;
  final List<double> trendValues;
  final List<String> trendLabels;
  final String periodLabel;
  final double improvement;
  final String improvementLabel;
  final List<_AchievementData> achievements;
  final _TimeSummary timeSummary;

  const _ProgressData({
    required this.activityDays,
    required this.completedHabitLogs,
    required this.goalsInProgress,
    required this.dailyRate,
    required this.chartValues,
    required this.chartNames,
    required this.trendValues,
    required this.trendLabels,
    required this.periodLabel,
    required this.improvement,
    required this.improvementLabel,
    required this.achievements,
    required this.timeSummary,
  });

  factory _ProgressData.empty() => const _ProgressData(
        activityDays: 0,
        completedHabitLogs: 0,
        goalsInProgress: 0,
        dailyRate: 0,
        chartValues: [0, 0, 0, 0, 0, 0, 0],
        chartNames: ['الصحة', 'الرياضة', 'الدراسة', 'القراءة', 'العمل', 'الماء', 'التأمل'],
        trendValues: [0],
        trendLabels: ['اليوم'],
        periodLabel: 'اليوم',
        improvement: 0,
        improvementLabel: 'لا توجد بيانات كافية للمقارنة',
        achievements: [
          _AchievementData(
            Icons.auto_awesome_rounded,
            Color(0xFF18B77A),
            'ابدأ تسجيل إنجازاتك',
            'أكمل عادة أو مهمة لتظهر إنجازاتك هنا.',
          ),
        ],
        timeSummary: _TimeSummary(completedTasks: 0, topTags: []),
      );
}

class _ChartData {
  final List<double> values;
  final List<String> names;

  const _ChartData({required this.values, required this.names});
}

class _TrendData {
  final List<double> values;
  final List<String> labels;

  const _TrendData({
    required this.values,
    required this.labels,
  });
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange(this.start, this.end);
}

class _AchievementData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AchievementData(this.icon, this.color, this.title, this.subtitle);
}

class _TimeSummary {
  final int completedTasks;
  final List<MapEntry<String, int>> topTags;

  const _TimeSummary({required this.completedTasks, required this.topTags});
}

class _Legend extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _Legend({
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF102A4C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
               fontSize: 12,
               color: Theme.of(context).brightness == Brightness.dark
                   ? const Color(0xFF9AA7B8)
                   : const Color(0xFF7B8798),
             ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final bool isDark;

  const _LineChartPainter({
    required this.values,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark
          ? const Color(0xFF27313B)
          : const Color(0xFFE8EEF4)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final safeValues = values.isEmpty ? [0.0] : values;
    final points = <Offset>[];
    for (int i = 0; i < safeValues.length; i++) {
      final x = safeValues.length == 1
          ? size.width / 2
          : size.width * i / (safeValues.length - 1);
      final normalized = safeValues[i].clamp(0.0, 1.0).toDouble();
      final y = size.height * (0.85 - normalized * 0.65);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    if (oldDelegate.isDark != isDark) return true;
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
