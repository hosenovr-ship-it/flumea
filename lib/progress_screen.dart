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
  static const TextStyle _smallText = TextStyle(
    fontSize: 11,
    color: Color(0xFF7B8798),
  );

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
      final date = _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end) &&
          _asBool(log['completed']);
    }).toList();

    final previousLogs = habitLogs.where((log) {
      final date = _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      return date != null &&
          !date.isBefore(previous.start) &&
          !date.isAfter(previous.end) &&
          _asBool(log['completed']);
    }).toList();

    final periodTasks = tasks.where((task) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      return date != null &&
          !date.isBefore(range.start) &&
          !date.isAfter(range.end) &&
          _asBool(task['completed']);
    }).toList();

    final activityDates = <String>{};
    for (final log in periodLogs) {
      final date = _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      if (date != null) activityDates.add(_dateKey(date));
    }
    for (final task in periodTasks) {
      final date = _readDate(task['due_date']) ?? _readDate(task['created_at']);
      if (date != null) activityDates.add(_dateKey(date));
    }

    final goalsInProgress = goals.where((goal) => !_asBool(goal['completed'])).length;

    final today = _dateOnly(DateTime.now());
    final todayLogs = habitLogs.where((log) {
      final date = _readDate(log['completed_date']) ?? _readDate(log['created_at']);
      return date != null && _dateOnly(date) == today && _asBool(log['completed']);
    }).length;

    final availableHabitsToday = habits.where((habit) {
      final created = _readDate(habit['created_at']);
      return created == null || !created.isAfter(today);
    }).length;

    final dailyRate = availableHabitsToday == 0
        ? 0.0
        : (todayLogs / availableHabitsToday).clamp(0.0, 1.0).toDouble();

    final chart = _buildHabitChart(habits, periodLogs, range);

    final previousRate = _completionRate(
      previousLogs.length,
      _daysBetween(previous.start, previous.end),
      habits.length,
    );
    final currentRate = _completionRate(
      periodLogs.length,
      _daysBetween(range.start, range.end),
      habits.length,
    );

    double improvement = 0;
    if (previousRate > 0) {
      improvement = ((currentRate - previousRate) / previousRate) * 100;
    } else if (currentRate > 0) {
      improvement = 100;
    }

    return _ProgressData(
      activityDays: activityDates.length,
      completedHabitLogs: periodLogs.length,
      goalsInProgress: goalsInProgress,
      dailyRate: dailyRate,
      chartValues: chart.values,
      chartNames: chart.names,
      periodLabel: _periodLabel(_selectedPeriod),
      improvement: improvement,
      improvementLabel: previousRate == 0 && currentRate == 0
          ? 'لا توجد بيانات كافية للمقارنة'
          : 'مقارنة بالفترة السابقة',
      achievements: _buildAchievements(
        habitLogs: habitLogs,
        tasks: tasks,
        goals: goals,
      ),
      timeSummary: _buildTimeSummary(tasks, range),
    );
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
    final periodDays = _daysBetween(range.start, range.end).clamp(1, 366);
    final values = <double>[];
    final names = <String>[];

    for (final habit in selected) {
      final id = habit['id']?.toString();
      final count = logs.where((log) => log['habit_id']?.toString() == id).length;
      final rate = (count / periodDays).clamp(0.0, 1.0).toDouble();
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

  double _completionRate(int completed, int days, int habitCount) {
    if (days <= 0 || habitCount <= 0) return 0;
    return (completed / (days * habitCount)).clamp(0.0, 1.0).toDouble();
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
  }) {
    final result = <_AchievementData>[];
    final completedLogs = habitLogs.where((log) => _asBool(log['completed'])).toList();
    final completedTasks = tasks.where((task) => _asBool(task['completed'])).toList();
    final completedGoals = goals.where((goal) => _asBool(goal['completed'])).length;

    if (completedLogs.isNotEmpty) {
      final streak = _currentStreak(habitLogs);
      result.add(_AchievementData(
        Icons.local_fire_department_rounded,
        green,
        'أكملت $streak ${streak == 1 ? 'يوم' : 'أيام'} متتالية',
        'استمر في بناء عاداتك يومًا بعد يوم!',
      ));
    }

    final studyTasks = completedTasks.where((task) {
      final text = '${task['title'] ?? ''} ${task['tag'] ?? ''}'.toLowerCase();
      return text.contains('دراسة') || text.contains('قراءة') || text.contains('تعليم');
    }).length;
    if (studyTasks > 0) {
      result.add(_AchievementData(
        Icons.school_rounded,
        blue,
        'أنجزت $studyTasks مهام مرتبطة بالتعلم',
        'كل جلسة مكتملة تقرّبك من هدفك!',
      ));
    }

    if (completedGoals > 0) {
      result.add(_AchievementData(
        Icons.flag_rounded,
        Colors.orange,
        'أكملت $completedGoals ${completedGoals == 1 ? 'هدفًا' : 'أهدافًا'}',
        'إنجاز حقيقي يُضاف إلى رحلتك!',
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
    if (period == 2) {
      return _DateRange(DateTime(today.year, today.month, 1), today);
    }
    return _DateRange(DateTime(2020, 1, 1), today);
  }

  _DateRange _previousPeriodRange(int period) {
    final current = _periodRange(period);
    final length = _daysBetween(current.start, current.end);
    if (period == 3) {
      return _DateRange(DateTime(2019, 1, 1), DateTime(2019, 12, 31));
    }
    final end = current.start.subtract(const Duration(days: 1));
    return _DateRange(end.subtract(Duration(days: length - 1)), end);
  }

  String _periodLabel(int period) {
    switch (period) {
      case 0:
        return 'اليوم';
      case 1:
        return 'آخر 7 أيام';
      case 2:
        return 'هذا الشهر';
      default:
        return 'كل الوقت';
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAFD),
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
            const Icon(Icons.cloud_off_rounded, color: navy, size: 45),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: navy, fontSize: 15),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadProgress,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: navy, size: 30),
            SizedBox(width: 8),
            Text(
              'التقدم',
              style: TextStyle(
                color: navy,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'رحلتك نحو نسخة أفضل من نفسك',
          style: TextStyle(color: Color(0xFF7B8798), fontSize: 16),
        ),
      ],
    );
  }

  Widget _periodSelector() {
    const titles = ['اليوم', 'الأسبوع', 'الشهر', 'الكل'];
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
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
                      ? const Color(0xFFEAF4FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  titles[index],
                  style: TextStyle(
                    color: _selectedPeriod == index ? blue : navy,
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
            background: lightGreen,
            iconColor: green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.track_changes_rounded,
            value: '${_data.completedHabitLogs}',
            title: 'العادات المكتملة',
            background: lightBlue,
            iconColor: blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            icon: Icons.flag_rounded,
            value: '${_data.goalsInProgress}',
            title: 'الأهداف قيد العمل',
            background: lightYellow,
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
            style: const TextStyle(
              color: navy,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: iconColor == blue ? blue : navy,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: navy, size: 25),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'معدل إكمال العادات',
                  style: TextStyle(
                    color: navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatPercent(_data.dailyRate),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'معدل اليوم',
                      style: TextStyle(color: navy, fontSize: 12),
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
            style: const TextStyle(color: Color(0xFF7B8798), fontSize: 13),
          ),
          const SizedBox(height: 20),
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
                          style: const TextStyle(
                            color: Color(0xFF66758A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'توزيع وقتك اليومي',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.access_time_rounded, color: navy),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _data.timeSummary.completedTasks == 0
                ? 'لا توجد مهام مكتملة في ${_periodLabel(_selectedPeriod)}'
                : '${_data.timeSummary.completedTasks} مهام مكتملة في ${_periodLabel(_selectedPeriod)}',
            style: const TextStyle(color: Color(0xFF7B8798), fontSize: 12),
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
                          backgroundColor: const Color(0xFFE9EEF4),
                          valueColor: const AlwaysStoppedAnimation<Color>(blue),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_data.timeSummary.completedTasks}',
                            style: const TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'مهام',
                            style: TextStyle(color: Color(0xFF7B8798), fontSize: 12),
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
          const Text(
            'ملاحظة: جدول المهام الحالي يحفظ وقت المهمة كوقت بدء، وليس مدة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9AA7B8), fontSize: 9),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'تحسنك عبر الوقت',
                  style: TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.trending_up_rounded, color: navy),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _data.improvementLabel,
            style: const TextStyle(color: Color(0xFF7B8798), fontSize: 12),
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
            style: const TextStyle(color: Color(0xFF7B8798), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(
                values: _data.chartValues,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('البداية', style: _smallText),
              Text('الآن', style: _smallText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _achievementsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EBF1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: navy, size: 25),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'أبرز إنجازاتك',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(color: blue, fontWeight: FontWeight.w700),
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
        border: Border(top: BorderSide(color: Color(0xFFE9EEF4))),
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
                  style: const TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF7B8798)),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  const _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE8EEF4)
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
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}
