import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bottom_navigation.dart';
import 'services/flumea_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<double> _weekTrendValues = const <double>[];
  List<String> _weekTrendLabels = const <String>[];
  List<double> _monthTrendValues = const <double>[];
  List<String> _monthTrendLabels = const <String>[];
  List<double> _weekTaskValues = const <double>[];
  List<String> _weekTaskLabels = const <String>[];
  List<double> _monthTaskValues = const <double>[];
  List<String> _monthTaskLabels = const <String>[];

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

      // The Plan/Home screens also persist daily habit state locally. Merge
      // those daily records into the progress history so the chart and counts
      // reflect completed habits even when a habit_logs write was unavailable.
      final prefs = await SharedPreferences.getInstance();
      final localPrefix = 'flumea_habit_done_${user.id}_';
      final todayDate = _dateOnly(DateTime.now());
      final todayKey = _dateKey(todayDate);

      // حالة اليوم في الخطة محفوظة محليًا لكل عادة. اعتبرها المصدر
      // النهائي لليوم الحالي حتى لا تُظهر سجلات Supabase القديمة عادةً
      // مكتملة بعد أن ألغى المستخدم تحديدها في صفحة الخطة.
      final todayLocalStates = <String, bool>{};
      for (final habit in habits) {
        final habitId = habit['id']?.toString();
        if (habitId == null || habitId.isEmpty) continue;
        final key = '$localPrefix${habitId}_$todayKey';
        final localValue = prefs.getBool(key) ?? false;
        todayLocalStates[habitId] = localValue;
        habit['completed'] = localValue;
      }

      // احتفظ بسجلات الأيام السابقة، لكن أعد بناء سجلات اليوم من الحالة
      // نفسها التي تعرضها الخطة. هذا يمنع اختلاف العدادات والرسم بين الصفحتين.
      habitLogs.removeWhere((log) {
        final habitId = log['habit_id']?.toString();
        final logDate = _readDate(log['completed_date']) ??
            _readDate(log['created_at']);
        return habitId != null &&
            todayLocalStates.containsKey(habitId) &&
            logDate != null &&
            _dateKey(logDate) == todayKey;
      });

      for (final entry in todayLocalStates.entries) {
        if (!entry.value) continue;
        habitLogs.add({
          'id': 'local_${entry.key}_$todayKey',
          'habit_id': entry.key,
          'completed_date': todayKey,
          'completed': true,
          'created_at': todayKey,
          'user_id': user.id,
        });
      }

      // أضف السجلات المحلية التاريخية أيضًا؛ وهي مفيدة إذا تعذر حفظ سجل
      // اليوم في Supabase، مع احترام قيمة false عند إلغاء عادة في أي يوم.
      for (final key in prefs.getKeys()) {
        if (!key.startsWith(localPrefix)) continue;
        final localValue = prefs.getBool(key);
        if (localValue == null) continue;
        final suffix = key.substring(localPrefix.length);
        final match = RegExp(r'^(.+)_([0-9]{4}-[0-9]{2}-[0-9]{2})$')
            .firstMatch(suffix);
        if (match == null) continue;
        final habitId = match.group(1)!;
        final dateKey = match.group(2)!;
        if (dateKey == todayKey) continue;

        final localIdentity = '${habitId}_$dateKey';
        habitLogs.removeWhere((log) {
          final logHabitId = log['habit_id']?.toString();
          final logDate = _readDate(log['completed_date']) ??
              _readDate(log['created_at']);
          return logHabitId == habitId &&
              logDate != null &&
              _dateKey(logDate) == dateKey;
        });
        if (localValue) {
          habitLogs.add({
            'id': 'local_$localIdentity',
            'habit_id': habitId,
            'completed_date': dateKey,
            'completed': true,
            'created_at': dateKey,
            'user_id': user.id,
          });
        }
      }

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

      // احفظ بيانات الشهر كاملة بشكل مستقل عن محدد اليوم/الأسبوع/الشهر.
      // تبقى كل نقطة مبنية على سجلات العادات الفعلية، مع إظهار كل أيام الشهر.
      final todayForMonth = _dateOnly(DateTime.now());
      final monthStart = DateTime(todayForMonth.year, todayForMonth.month, 1);
      final monthEnd = DateTime(todayForMonth.year, todayForMonth.month + 1, 0);
      final todayForTrend = _dateOnly(DateTime.now());
      final weekStart = todayForTrend.subtract(const Duration(days: 6));
      final todayFallbackIds = todayLocalStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toSet();
      final weekTrend = _buildTrendData(
        habits: habits,
        habitLogs: habitLogs,
        range: _DateRange(weekStart, todayForTrend),
        fallbackTodayIds: todayFallbackIds,
      );
      final monthTrend = _buildTrendData(
        habits: habits,
        habitLogs: habitLogs,
        range: _DateRange(monthStart, monthEnd),
        fallbackTodayIds: todayFallbackIds,
      );
      final weekTasksTrend = _buildTaskTrendData(
        tasks,
        _DateRange(weekStart, todayForTrend),
      );
      final monthTasksTrend = _buildTaskTrendData(
        tasks,
        _DateRange(monthStart, monthEnd),
      );

      if (!mounted) return;
      setState(() {
        _data = data;
        _weekTrendValues = weekTrend.values;
        _weekTrendLabels = weekTrend.labels;
        _monthTrendValues = monthTrend.values;
        _monthTrendLabels = monthTrend.labels;
        _weekTaskValues = weekTasksTrend.values;
        _weekTaskLabels = weekTasksTrend.labels;
        _monthTaskValues = monthTasksTrend.values;
        _monthTaskLabels = monthTasksTrend.labels;
        _loading = false;
      });

      await _maybeNotifyAchievement(data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _data = _ProgressData.empty();
        _error = null;
      });
    }
  }

  Future<void> _maybeNotifyAchievement(_ProgressData data) async {
    if (data.achievements.isEmpty) return;

    final achievement = data.achievements.first;
    if (achievement.title == 'ابدأ تسجيل إنجازاتك') return;

    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final key = 'flumea_progress_notification_$today';
    final fingerprint = '${achievement.title}|${achievement.subtitle}';

    if (prefs.getString(key) == fingerprint) return;

    final shown = await FlumeaNotificationService.instance.show(
      title: 'إنجاز جديد! 🏆',
      body: achievement.title,
      type: FlumeaNotificationType.achievement,
      requestPermission: false,
    );

    if (shown) {
      await prefs.setString(key, fingerprint);
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

    final periodAllTasks = tasks.where((task) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end);
    }).toList();

    final periodTasks = periodAllTasks
        .where((task) => _asBool(task['completed']))
        .toList();

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

    // لا نستخدم habits.completed كبديل لحالة اليوم؛ هذا العمود قديم ودائم،
    // بينما شاشة الخطة تعتمد حالة مستقلة لكل يوم. نستخدم سجلات اليوم الفعلية فقط.
    final completedTodayIds = <String>{...completedTodayFromLogs};

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
      timeSummary: _buildTimeSummary(periodAllTasks, periodTasks),
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

    // نستخدم يومًا حقيقيًا لكل نقطة حتى يكون الرسم مطابقًا للفترة:
    // الأسبوع = 7 أيام، والشهر = جميع الأيام المنقضية من الشهر.
    final pointCount = totalDays;
    final values = <double>[];
    final labels = <String>[];

    for (int i = 0; i < pointCount; i++) {
      final date = range.start.add(Duration(days: i));
      final value = _dailyCompletionRate(
        date: date,
        habits: habits,
        habitLogs: habitLogs,
        fallbackTodayIds: date == _dateOnly(DateTime.now())
            ? fallbackTodayIds
            : const <String>{},
      );
      values.add(value);
      labels.add(totalDays > 7 ? '${date.day}' : _shortArabicDate(date));
    }

    if (values.isEmpty) {
      values.add(0);
      labels.add(_shortArabicDate(range.start));
    }

    return _TrendData(values: values, labels: labels);
  }

  _TrendData _buildTaskTrendData(
    List<Map<String, dynamic>> tasks,
    _DateRange range,
  ) {
    final totalDays = _daysBetween(range.start, range.end);
    final completedByDay = List<int>.filled(totalDays, 0);
    final totalByDay = List<int>.filled(totalDays, 0);
    final labels = <String>[];
    final dayIndexes = <String, int>{};

    for (int i = 0; i < totalDays; i++) {
      final date = range.start.add(Duration(days: i));
      dayIndexes[_dateKey(date)] = i;
      labels.add(totalDays > 7 ? '${date.day}' : _shortArabicDate(date));
    }

    // The schema has no completion timestamp, so group each task by due_date,
    // falling back to created_at. Show a daily completion rate, not raw counts.
    for (final task in tasks) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      if (date == null) continue;
      final index = dayIndexes[_dateKey(date)];
      if (index == null) continue;
      totalByDay[index] += 1;
      if (_asBool(task['completed'])) completedByDay[index] += 1;
    }

    final values = List<double>.generate(totalDays, (index) {
      if (totalByDay[index] == 0) return 0.0;
      return completedByDay[index] / totalByDay[index];
    });
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
      return const _ChartData(values: [], names: []);
    }

    final sortedHabits = [...habits]..sort((a, b) {
      final aDate = _readDate(a['created_at']) ?? DateTime(2000);
      final bDate = _readDate(b['created_at']) ?? DateTime(2000);
      return aDate.compareTo(bDate);
    });

    final selected = sortedHabits;
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

    return _ChartData(values: values, names: names);
  }

  _TimeSummary _buildTimeSummary(
    List<Map<String, dynamic>> allTasks,
    List<Map<String, dynamic>> completedTasks,
  ) {
    final tagCounts = <String, int>{};
    for (final task in completedTasks) {
      final tag = task['tag']?.toString().trim();
      if (tag != null && tag.isNotEmpty) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final entries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _TimeSummary(
      totalTasks: allTasks.length,
      completedTasks: completedTasks.length,
      inProgressTasks: allTasks.where((task) => !_asBool(task['completed']) &&
          _readDate(task['due_date']) != null &&
          _readDate(task['due_date'])!.isAfter(_dateOnly(DateTime.now()))).length,
      unfinishedTasks: allTasks.length - completedTasks.length,
      topTags: entries.take(3).toList(),
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

  Color get _circleTrack =>
      _isDark ? const Color(0xFF29323C) : const Color(0xFFE9EEF4);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.sizeOf(context).width < 600 ? 0.90 : 1.0,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
            onRefresh: _loadProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 600;

                                if (isCompact) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _timeCard(),
                                      const SizedBox(height: 14),
                                      _improvementCard(),
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _timeCard()),
                                    const SizedBox(width: 12),
                                    Expanded(child: _improvementCard()),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
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
            Icon(Icons.cloud_off_rounded, color: _primaryText, size: 40.5),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _primaryText, fontSize: 13.5),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.bar_chart_rounded, color: _primaryText, size: 27),
                  const SizedBox(width: 8),
                  Text(
                    'التقدم',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'FLUMEA',
              style: TextStyle(
                color: _primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'رحلتك نحو نسخة أفضل من نفسك',
            style: TextStyle(color: _secondaryText, fontSize: 14.4),
          ),
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
                    fontSize: 13.5,
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
            icon: Icons.task_alt_rounded,
            value: '${_data.timeSummary.completedTasks}',
            title: 'المهام المكتملة',
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
          Icon(icon, color: iconColor, size: 34.2),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: _primaryText,
              fontSize: 24.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: iconColor == blue ? blue : _primaryText,
              fontSize: 12.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitChart() {
    final values = _data.chartValues;
    final names = _data.chartNames;
    final count = values.length;

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
              Icon(Icons.bar_chart_rounded, color: _primaryText, size: 22.5),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'معدل إكمال العادات',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18.9,
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
                        fontSize: 17.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'معدل اليوم',
                      style: TextStyle(color: _primaryText, fontSize: 10.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _progressPeriodDateLabel(),
            textAlign: TextAlign.right,
            style: TextStyle(color: _secondaryText, fontSize: 11.7),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 265,
            child: count == 0
                ? Center(
                    child: Text(
                      'أضف عاداتك لتظهر بيانات التقدم هنا',
                      style: TextStyle(color: _secondaryText, fontSize: 11.7),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(count, (index) {
                      final value = values[index].clamp(0.0, 1.0).toDouble();
                      final habitName = names[index];
                      final barColor = _habitColorFor(habitName);
                      final habitEmoji = _habitEmojiFor(habitName);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _formatPercent(value),
                                style: TextStyle(
                                  color: barColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 44,
                                    height: 175 * value,
                                    decoration: BoxDecoration(
                                      color: barColor.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      height: 175 * value,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            barColor.withValues(alpha: 0.72),
                                            barColor,
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: barColor.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  habitEmoji,
                                  style: const TextStyle(fontSize: 18.9),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                names[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _secondaryText,
                                  fontSize: 9.9,
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

  Color _habitColorFor(String name) {
    final value = name.trim().toLowerCase();

    // لون ثابت لكل اسم عادة حتى لا يتغير عند إعادة فتح صفحة التقدم،
    // مع توزيع الألوان بين مجموعة ألوان جميلة.
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }

    return _habitColors[hash % _habitColors.length];
  }

  String _habitEmojiFor(String name) {
    final value = name.trim().toLowerCase();

    if (value.contains('كرة القدم') ||
        value.contains('كرة قدم') ||
        value.contains('football') ||
        value.contains('soccer')) {
      return '⚽';
    }

    if (value.contains('ماء') ||
        value.contains('شرب') ||
        value.contains('water')) {
      return '💧';
    }

    if (value.contains('دراسة') ||
        value.contains('تعلم') ||
        value.contains('مدرسة') ||
        value.contains('جامعة') ||
        value.contains('study') ||
        value.contains('learn')) {
      return '📚';
    }

    if (value.contains('رياضة') ||
        value.contains('تمرين') ||
        value.contains('جيم') ||
        value.contains('gym') ||
        value.contains('exercise') ||
        value.contains('workout')) {
      return '🏋️';
    }

    if (value.contains('أكل') ||
        value.contains('اكل') ||
        value.contains('طعام') ||
        value.contains('غذاء') ||
        value.contains('food') ||
        value.contains('eat')) {
      return '🍎';
    }

    if (value.contains('نوم') ||
        value.contains('نوم مبكر') ||
        value.contains('sleep')) {
      return '😴';
    }

    if (value.contains('قراءة') ||
        value.contains('قراءه') ||
        value.contains('كتاب') ||
        value.contains('read')) {
      return '📖';
    }

    if (value.contains('مشي') || value.contains('walk')) {
      return '🚶';
    }

    if (value.contains('جري') ||
        value.contains('ركض') ||
        value.contains('run')) {
      return '🏃';
    }

    if (value.contains('صلاة') || value.contains('صلاه')) {
      return '🕌';
    }

    if (value.contains('تأمل') ||
        value.contains('تامل') ||
        value.contains('تنفس')) {
      return '🧘';
    }

    if (value.contains('عمل') || value.contains('وظيفة')) {
      return '💼';
    }

    return '🎯';
  }

  static const List<Color> _habitColors = [
    Color(0xFF1E88E5),
    Color(0xFF7E3FF2),
    Color(0xFFFF8A00),
    Color(0xFF16B978),
    Color(0xFF1E88E5),
    Color(0xFF8E5CF6),
    Color(0xFF18B77A),
  ];

  String _progressPeriodDateLabel() {
    final today = _dateOnly(DateTime.now());
    final range = _periodRange(_selectedPeriod);

    if (_selectedPeriod == 0) {
      return 'اليوم · ${_todayArabicDate()}';
    }

    if (_selectedPeriod == 1) {
      return 'آخر 7 أيام · ${_shortArabicDate(range.start)} - ${_shortArabicDate(range.end)}';
    }

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
    return 'هذا الشهر · ${months[today.month - 1]} ${today.year}';
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
    final summary = _data.timeSummary;
    final total = summary.totalTasks;
    final completed = summary.completedTasks;
    final inProgress = summary.inProgressTasks;
    final unfinished = summary.unfinishedTasks;
    final rate = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0).toDouble();

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
                  'معدل إكمال المهمة',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.access_time_rounded, color: _primaryText),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$completed من $total ${total == 1 ? 'مهمة' : 'مهام'} مكتملة في ${_periodLabel(_selectedPeriod)}',
            style: TextStyle(color: _secondaryText, fontSize: 10.8),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 145,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: CircularProgressIndicator(
                          value: rate,
                          strokeWidth: 18,
                          backgroundColor: _circleTrack,
                          valueColor: const AlwaysStoppedAnimation<Color>(blue),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatPercent(rate),
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 22.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'معدل الإكمال',
                            style: TextStyle(color: _secondaryText, fontSize: 10.8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Legend(color: green, title: 'مكتملة', value: '$completed'),
                      _Legend(color: blue, title: 'قيد التنفيذ', value: '$inProgress'),
                      _Legend(color: Colors.red, title: 'لم تنجز', value: '$unfinished'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _improvementCard() {
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
          Text(
            'تحسنك عبر الوقت',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: _primaryText,
              fontSize: 16.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openWeeklyTrend,
                  icon: const Icon(Icons.calendar_view_week_rounded, size: 15),
                  label: const Text('عرض الكل', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    side: BorderSide(color: blue.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openFullMonthTrend,
                  icon: const Icon(Icons.calendar_month_rounded, size: 15),
                  label: const Text('عرض الشهر', maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: BorderSide(color: green.withValues(alpha: 0.28)),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDark ? const Color(0xFF121D29) : const Color(0xFFF7FAFD),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: _isDark ? 0.18 : 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.insights_rounded, color: _isDark ? const Color(0xFF55D6A3) : green, size: 26),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'كل يوم فرصة لتتقدم',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _primaryText, fontSize: 12.2, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'افتح التقارير لمراجعة إنجازات عاداتك ومهامك',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _secondaryText, fontSize: 10.2, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWeeklyTrend() async {
    await _openTrendHistory(isMonth: false);
  }

  Future<void> _openFullMonthTrend() async {
    await _openTrendHistory(isMonth: true);
  }

  Future<void> _openTrendHistory({required bool isMonth}) async {
    final now = DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final habitValues = isMonth ? _monthTrendValues : _weekTrendValues;
    final habitLabels = isMonth ? _monthTrendLabels : _weekTrendLabels;
    final taskValues = isMonth ? _monthTaskValues : _weekTaskValues;
    final taskLabels = isMonth ? _monthTaskLabels : _weekTaskLabels;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _TrendHistoryScreen(
          title: isMonth ? 'تقدم الشهر' : 'تقدم آخر 7 أيام',
          monthTitle: '${months[now.month - 1]} ${now.year}',
          periodLabel: isMonth ? 'الشهر كاملًا' : 'آخر 7 أيام',
          habitValues: habitValues,
          habitLabels: habitLabels,
          taskValues: taskValues,
          taskLabels: taskLabels,
          isMonth: isMonth,
          isDark: _isDark,
          navy: navy,
          blue: blue,
          green: green,
        ),
      ),
    );
  }

}

class _TrendHistoryScreen extends StatelessWidget {
  final String title;
  final String monthTitle;
  final String periodLabel;
  final List<double> habitValues;
  final List<String> habitLabels;
  final List<double> taskValues;
  final List<String> taskLabels;
  final bool isMonth;
  final bool isDark;
  final Color navy;
  final Color blue;
  final Color green;

  const _TrendHistoryScreen({
    required this.title,
    required this.monthTitle,
    required this.periodLabel,
    required this.habitValues,
    required this.habitLabels,
    required this.taskValues,
    required this.taskLabels,
    required this.isMonth,
    required this.isDark,
    required this.navy,
    required this.blue,
    required this.green,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPhone = screenWidth < 600;
    final background = isDark ? const Color(0xFF08111A) : const Color(0xFFF7FAFD);
    final card = isDark ? const Color(0xFF101923) : Colors.white;
    final primary = isDark ? const Color(0xFFF2F5F7) : navy;
    final secondary = isDark ? const Color(0xFFADB9C8) : const Color(0xFF7B8798);
    final border = isDark ? const Color(0xFF2B3542) : const Color(0xFFE5EBF1);
    final average = habitValues.isEmpty
        ? 0.0
        : habitValues.reduce((a, b) => a + b) / habitValues.length;
    final daysShown = habitValues.length;

    Widget chartCard({
      required String heading,
      required IconData icon,
      required List<double> values,
      required List<String> labels,
      required Color barColor,
      required String legend,
    }) {
      return Container(
        height: isPhone ? (isMonth ? 285 : 265) : (isMonth ? 330 : 310),
        padding: EdgeInsets.fromLTRB(isPhone ? 10 : 12, isPhone ? 11 : 15, isPhone ? 10 : 12, isPhone ? 9 : 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: barColor, size: isPhone ? 18 : 21),
                SizedBox(width: isPhone ? 6 : 8),
                Expanded(child: Text(heading, style: TextStyle(color: primary, fontSize: isPhone ? 13 : 15, fontWeight: FontWeight.w800))),
                Text('${values.length} يوم', style: TextStyle(color: secondary, fontSize: isPhone ? 9 : 10.5)),
              ],
            ),
            SizedBox(height: isPhone ? 8 : 14),
            Expanded(
              child: _TrendBarChart(
                values: values,
                labels: labels,
                isDark: isDark,
                compact: false,
                barColor: barColor,
                legend: legend,
              ),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: primary,
          elevation: 0,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isPhone ? 11 : 16, isPhone ? 5 : 8, isPhone ? 11 : 16, isPhone ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isMonth ? 'نظرة كاملة على إنجازاتك خلال $monthTitle' : 'ملخص يومي مرتب من الأقدم إلى الأحدث ضمن آخر 7 أيام',
                    style: TextStyle(color: secondary, fontSize: isPhone ? 11.5 : 13, height: 1.35)),
                SizedBox(height: isPhone ? 9 : 14),
                Container(
                  padding: EdgeInsets.all(isPhone ? 12 : 16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: green.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(15)),
                        child: Icon(isMonth ? Icons.calendar_month_rounded : Icons.calendar_view_week_rounded, color: green, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isMonth ? monthTitle : periodLabel, style: TextStyle(color: primary, fontSize: isPhone ? 14 : 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text('$daysShown يومًا معروضًا', style: TextStyle(color: secondary, fontSize: isPhone ? 10 : 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(average * 100).round()}%', style: TextStyle(color: green, fontSize: isPhone ? 19 : 22, fontWeight: FontWeight.w900)),
                          Text('معدل إكمال العادات', style: TextStyle(color: secondary, fontSize: isPhone ? 8.5 : 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isPhone ? 9 : 14),
                chartCard(
                  heading: 'إكمال العادات',
                  icon: Icons.check_circle_outline_rounded,
                  values: habitValues,
                  labels: habitLabels,
                  barColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF193B57),
                  legend: 'نسبة إكمال العادات يوميًا',
                ),
                SizedBox(height: isPhone ? 9 : 14),
                chartCard(
                  heading: 'إنجاز المهام',
                  icon: Icons.task_alt_rounded,
                  values: taskValues,
                  labels: taskLabels,
                  barColor: isDark ? const Color(0xFF34D399) : const Color(0xFF18A875),
                  legend: 'نسبة إكمال المهام يوميًا',
                ),
                SizedBox(height: isPhone ? 8 : 12),
                Container(
                  padding: EdgeInsets.all(isPhone ? 10 : 13),
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'يعرض المخططان نسبة إكمال العادات والمهام يوميًا. تُحتسب المهام حسب تاريخ الاستحقاق، أو تاريخ الإنشاء إذا لم يوجد موعد استحقاق.',
                          style: TextStyle(color: secondary, fontSize: isPhone ? 10 : 11.5, height: 1.45),
                        ),
                      ),
                    ],
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

class _TrendBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final bool isDark;
  final bool compact;
  final Color? barColor;
  final String legend;

  const _TrendBarChart({
    required this.values,
    required this.labels,
    required this.isDark,
    required this.compact,
    this.barColor,
    this.legend = 'نسبة إكمال العادات يوميًا',
  });

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? const <double>[0] : values;
    final safeLabels = labels.length == safeValues.length
        ? labels
        : List<String>.generate(safeValues.length, (i) => '${i + 1}');
    final primary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF102A4C);
    final secondary = isDark ? const Color(0xFFB8C5D4) : const Color(0xFF7B8798);
    final grid = isDark ? const Color(0xFF344252) : const Color(0xFFE8EEF4);
    final bar = barColor ?? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF193B57));
    final isLongPeriod = safeValues.length > 14;
    final axisFontSize = compact ? 7.5 : (isLongPeriod ? 8.0 : 9.0);
    final labelFontSize = compact ? 7.5 : (isLongPeriod ? 7.0 : 9.0);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: compact ? 22 : 29,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('100%', style: TextStyle(color: secondary, fontSize: axisFontSize)),
                    Text('75%', style: TextStyle(color: secondary, fontSize: axisFontSize)),
                    Text('50%', style: TextStyle(color: secondary, fontSize: axisFontSize)),
                    Text('25%', style: TextStyle(color: secondary, fontSize: axisFontSize)),
                    Text('0%', style: TextStyle(color: secondary, fontSize: axisFontSize)),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, viewport) {
                    final pointWidth = compact ? 13.0 : (isLongPeriod ? 17.0 : 24.0);
                    final chartWidth = isLongPeriod
                        ? (safeValues.length * pointWidth).clamp(viewport.maxWidth, 100000.0).toDouble()
                        : viewport.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: chartWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, plotConstraints) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(5, (_) => Container(height: 1, color: grid)),
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(safeValues.length, (index) {
                                          final value = safeValues[index].clamp(0.0, 1.0).toDouble();
                                          final barHeight = (plotConstraints.maxHeight - 2).clamp(0.0, double.infinity) * value;
                                          return Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: isLongPeriod ? 1.0 : 2.0),
                                              child: Align(
                                                alignment: Alignment.bottomCenter,
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 250),
                                                  width: double.infinity,
                                                  height: barHeight,
                                                  constraints: BoxConstraints(minHeight: value > 0 ? 3 : 0),
                                                  decoration: BoxDecoration(
                                                    color: bar,
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                                    boxShadow: value > 0
                                                        ? [BoxShadow(color: bar.withValues(alpha: isDark ? 0.24 : 0.12), blurRadius: 5, offset: const Offset(0, 2))]
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: compact ? 6 : 8),
                            SizedBox(
                              height: compact ? 15 : 19,
                              child: Row(
                                children: List.generate(safeLabels.length, (index) {
                                  return Expanded(
                                    child: Center(
                                      child: Text(
                                        safeLabels[index],
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(color: secondary, fontSize: labelFontSize),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 9, height: 9, decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Flexible(child: Text(legend, textAlign: TextAlign.center, style: TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ],
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
        timeSummary: _TimeSummary(totalTasks: 0, completedTasks: 0, inProgressTasks: 0, unfinishedTasks: 0, topTags: []),
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
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int unfinishedTasks;
  final List<MapEntry<String, int>> topTags;

  const _TimeSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.unfinishedTasks,
    required this.topTags,
  });
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
                fontSize: 11.7,
                color: Color(0xFF102A4C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
               fontSize: 10.8,
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
