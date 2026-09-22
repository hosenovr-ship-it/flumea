import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  static const darkBlue = Color(0xFF102A4C);
  static const blue = Color(0xFF2870B5);
  static const green = Color(0xFF18B56A);
  static const teal = Color(0xFF32C6B4);
  static const grayText = Color(0xFF7B8798);
  static const background = Color(0xFFF8FAFC);

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const darkBlue = Color(0xFF102A4C);
  static const blue = Color(0xFF2870B5);
  static const green = Color(0xFF18B56A);
  static const teal = Color(0xFF32C6B4);
  static const grayText = Color(0xFF7B8798);
  static const background = Color(0xFFF8FAFC);

  final _supabase = Supabase.instance.client;

  bool _loading = true;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _habits = [];
  final Map<String, bool> _habitCompleted = {};

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _loadHomeData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final today = _today();

      final taskResponse = await _supabase
          .from('tasks')
          .select('id,title,description,completed,priority,due_date,user_id,time,tag,emoji,color')
          .eq('user_id', user.id)
          .eq('due_date', today)
          .order('time');

      final habitResponse = await _supabase
          .from('habits')
          .select('id,name,description,created_at,user_id,completed')
          .eq('user_id', user.id)
          .order('created_at');

      final logResponse = await _supabase
          .from('habit_logs')
          .select('habit_id,completed,completed_date')
          .eq('user_id', user.id)
          .eq('completed_date', today);

      final completedMap = <String, bool>{};
      for (final row in logResponse) {
        final habitId = row['habit_id']?.toString();
        if (habitId != null) {
          completedMap[habitId] = row['completed'] == true;
        }
      }

      if (!mounted) return;
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(taskResponse);
        _habits = List<Map<String, dynamic>>.from(habitResponse);
        _habitCompleted
          ..clear()
          ..addAll(completedMap);
        _loading = false;
      });
    } catch (e) {
      debugPrint('FLUMEA home data error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    final id = task['id']?.toString();
    if (id == null) return;

    final oldValue = task['completed'] == true;
    final newValue = !oldValue;

    setState(() {
      task['completed'] = newValue;
    });

    try {
      await _supabase.from('tasks').update({'completed': newValue}).eq('id', id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        task['completed'] = oldValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ حالة المهمة')),
      );
    }
  }

  Future<void> _toggleHabit(Map<String, dynamic> habit) async {
    final user = _supabase.auth.currentUser;
    final habitId = habit['id']?.toString();
    if (user == null || habitId == null) return;

    final oldValue = _habitCompleted[habitId] == true;
    final newValue = !oldValue;
    final today = _today();

    setState(() {
      _habitCompleted[habitId] = newValue;
    });

    try {
      final existing = await _supabase
          .from('habit_logs')
          .select('id')
          .eq('habit_id', habitId)
          .eq('user_id', user.id)
          .eq('completed_date', today)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('habit_logs')
            .update({'completed': newValue})
            .eq('id', existing['id']);
      } else {
        await _supabase.from('habit_logs').insert({
          'habit_id': habitId,
          'user_id': user.id,
          'completed_date': today,
          'completed': newValue,
        });
      }

      await _supabase
          .from('habits')
          .update({'completed': newValue})
          .eq('id', habitId)
          .eq('user_id', user.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _habitCompleted[habitId] = oldValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ حالة العادة')),
      );
    }
  }

  int get _completedTasks =>
      _tasks.where((task) => task['completed'] == true).length;

  int get _completedHabits =>
      _habits.where((habit) => _habitCompleted[habit['id']?.toString()] == true).length;

  double get _dailyProgress {
    final taskRatio = _tasks.isEmpty ? 0.0 : _completedTasks / _tasks.length;
    final habitRatio = _habits.isEmpty ? 0.0 : _completedHabits / _habits.length;
    if (_tasks.isEmpty && _habits.isEmpty) return 0.0;
    if (_tasks.isEmpty) return habitRatio;
    if (_habits.isEmpty) return taskRatio;
    return (taskRatio + habitRatio) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: teal))
              : RefreshIndicator(
                  onRefresh: _loadHomeData,
                  color: teal,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 105),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildDailyProgress(),
                        const SizedBox(height: 20),
                        _buildTodayPlan(),
                        const SizedBox(height: 16),
                        _buildHabitsAndFood(),
                        const SizedBox(height: 16),
                        _buildSmartAssistant(),
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: const FlumeaBottomNavigation(selectedIndex: 0),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;

    final rawName = metadata?['full_name'] ??
        metadata?['name'] ??
        metadata?['display_name'];
    final avatarUrl = metadata?['avatar_url']?.toString();

    String userName = rawName?.toString().trim() ?? '';
    if (userName.isEmpty && user?.email != null) {
      userName = user!.email!.split('@').first.trim();
    }
    if (userName.isEmpty) userName = 'صديقي';

    final hour = DateTime.now().hour;
    final greeting = hour >= 5 && hour < 12 ? 'صباح الخير' : 'مساء الخير';

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'FLUMEA',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 16,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE9EEF5),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(Icons.person_rounded, color: darkBlue, size: 28)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$greeting، $userName 👋',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'يوم جديد، فرصة جديدة لتصبح أفضل نسخة منك.',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              color: grayText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
    final percent = (_dailyProgress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0B2D52), Color(0xFF062548)],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'تقدمك اليوم',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const _ProgressStat(
                        icon: Icons.favorite_border_rounded,
                        value: '1,450',
                        label: 'سعرة حرارية',
                        iconColor: Color(0xFF8C78FF),
                      ),
                      const _VerticalDivider(),
                      _ProgressStat(
                        icon: Icons.local_fire_department_rounded,
                        value: '${_completedHabits}/${_habits.length}',
                        label: 'العادات',
                        iconColor: const Color(0xFF49D59B),
                      ),
                      const _VerticalDivider(),
                      _ProgressStat(
                        icon: Icons.track_changes_rounded,
                        value: '${_completedTasks}/${_tasks.length}',
                        label: 'المهام',
                        iconColor: const Color(0xFF4B9FFF),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DailyProgressRing(
                  progress: _dailyProgress,
                  value: '$percent%',
                  label: 'اليوم',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPlan() {
    final visibleTasks = _tasks.take(5).toList();
    final completed = _completedTasks;
    final total = _tasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return _LargeCard(
      child: Column(
        children: [
          const _CardTitle(
            title: 'خطة اليوم',
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 5),
          if (visibleTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'لا توجد مهام لهذا اليوم',
                style: TextStyle(color: grayText, fontSize: 13),
              ),
            )
          else
            ...visibleTasks.map((task) {
              return _HomeTask(
                time: task['time']?.toString() ?? '--',
                title: task['title']?.toString() ?? 'مهمة',
                category: task['tag']?.toString() ?? 'روتين',
                completed: task['completed'] == true,
                dotColor: _colorFromHex(task['color']?.toString()),
                onTap: () => _toggleTask(task),
              );
            }),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '$completed من $total مكتملة',
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8ECEF),
                    valueColor: const AlwaysStoppedAnimation<Color>(green),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                total > completed ? 'تبقى ${total - completed} مهمة' : 'كل المهام مكتملة',
                style: const TextStyle(
                  color: grayText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsAndFood() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildHabitsCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildFoodCard()),
      ],
    );
  }

  Widget _buildHabitsCard() {
    final visibleHabits = _habits.take(3).toList();

    return _SmallCard(
      title: 'عاداتك',
      icon: Icons.history_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (visibleHabits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'لا توجد عادات بعد',
                textAlign: TextAlign.right,
                style: TextStyle(color: grayText, fontSize: 12),
              ),
            )
          else
            ...visibleHabits.map((habit) {
              final id = habit['id']?.toString();
              return _HomeHabit(
                icon: '✓',
                title: habit['name']?.toString() ?? 'عادة',
                completed: id != null && _habitCompleted[id] == true,
                onTap: () => _toggleHabit(habit),
              );
            }),
          const SizedBox(height: 7),
          const Text(
            'عرض الكل  ←',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard() {
    return _SmallCard(
      title: 'طعامك اليوم',
      icon: Icons.restaurant_rounded,
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              const Expanded(
                child: _CaloriesRing(
                  progress: 1450 / 2200,
                  value: '1,450',
                  subtitle: 'من 2,200\nسعرة حرارية',
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MealLine(
                      name: 'الفطور',
                      calories: '420 سعرة',
                      icon: '☀️',
                    ),
                    _MealLine(
                      name: 'الغداء',
                      calories: '660 سعرة',
                      icon: '☀️',
                    ),
                    _MealLine(
                      name: 'العشاء',
                      calories: '350 سعرة',
                      icon: '🌙',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F3),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'تسجيل وجبة  +',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: green,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAssistant() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '✨ مساعدك الذكي',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'لديك 5 مهام اليوم. هل تريد أن أرتبها حسب الأولوية؟',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: grayText,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF8FD9C0),
                    ),
                    borderRadius: BorderRadius.circular(9),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  child: const Center(
                    child: Text(
                      'رتب الآن',
                      style: TextStyle(
                        color: green,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5EE),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 82,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7F8),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.smart_toy_rounded,
                  color: Color(0xFF0B3E6D),
                  size: 47,
                ),
                const Positioned(
                  left: 24,
                  top: 30,
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFF39D4C1),
                    size: 5,
                  ),
                ),
                const Positioned(
                  right: 24,
                  top: 30,
                  child: Icon(
                    Icons.circle,
                    color: Color(0xFF39D4C1),
                    size: 5,
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

Color _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF4AA4D9);
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return const Color(0xFF4AA4D9);
  final parsed = int.tryParse('FF$value', radix: 16);
  return parsed == null ? const Color(0xFF4AA4D9) : Color(parsed);
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _ProgressStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xBFFFFFFF),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      color: const Color(0x557B9AB5),
    );
  }
}

class _DailyProgressRing extends StatelessWidget {
  final double progress;
  final String value;
  final String label;

  const _DailyProgressRing({
    required this.progress,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 125,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              color: const Color(0x334E83AD),
            ),
          ),
          SizedBox(
            width: 112,
            height: 112,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: const Color(0xFF20B9D4),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF36C7E0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeCard extends StatelessWidget {
  final Widget child;

  const _LargeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CardTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 25,
          color: HomeScreen.darkBlue,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: HomeScreen.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTask extends StatelessWidget {
  final String time;
  final String title;
  final String category;
  final bool completed;
  final Color dotColor;
  final VoidCallback onTap;

  const _HomeTask({
    required this.time,
    required this.title,
    required this.category,
    required this.dotColor,
    required this.onTap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 51),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _categoryColor(category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(color: _categoryColor(category), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HomeScreen.darkBlue,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              completed ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: completed ? HomeScreen.green : const Color(0xFFC6CCD3),
              size: 25,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 56,
              child: Text(time, textAlign: TextAlign.left, style: const TextStyle(fontSize: 11, color: HomeScreen.grayText)),
            ),
          ],
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'صحة':
        return const Color(0xFF3EBB91);
      case 'تطوير ذات':
        return const Color(0xFF8A52B8);
      case 'عمل':
        return const Color(0xFFE3AD1D);
      default:
        return HomeScreen.blue;
    }
  }
}

class _SmallCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SmallCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: HomeScreen.darkBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: HomeScreen.darkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HomeHabit extends StatelessWidget {
  final String icon;
  final String title;
  final bool completed;
  final VoidCallback onTap;

  const _HomeHabit({
    required this.icon,
    required this.title,
    required this.onTap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HomeScreen.darkBlue),
              ),
            ),
            Icon(
              completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 23,
              color: completed ? HomeScreen.green : const Color(0xFFD2D6DC),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesRing extends StatelessWidget {
  final double progress;
  final String value;
  final String subtitle;

  const _CaloriesRing({
    required this.progress,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              color: const Color(0xFFE8ECEF),
            ),
          ),
          SizedBox(
            width: 108,
            height: 108,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: HomeScreen.green,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: HomeScreen.darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: HomeScreen.grayText,
                  fontSize: 9,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealLine extends StatelessWidget {
  final String name;
  final String calories;
  final String icon;

  const _MealLine({
    required this.name,
    required this.calories,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: HomeScreen.darkBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  calories,
                  style: const TextStyle(
                    color: HomeScreen.grayText,
                    fontSize: 8,
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
