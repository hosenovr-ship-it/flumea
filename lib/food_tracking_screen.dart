import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  static const Color background = Color(0xFFF7F9FC);
  static const Color darkBlue = Color(0xFF142B49);
  static const Color cardBlue = Color(0xFF092D54);
  static const Color green = Color(0xFF0DB58A);
  static const Color softGreen = Color(0xFFE9FBF5);

  final SupabaseClient _supabase = Supabase.instance.client;
  

  DateTime selectedDate = _dateOnly(DateTime.now());
  bool _loading = true;
  bool _saving = false;
  List<MealData> meals = _createEmptyMeals();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static List<MealData> _createEmptyMeals() {
    return [
      MealData(
        title: 'الفطور',
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
        items: [],
      ),
      MealData(
        title: 'الغداء',
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
        items: [],
      ),
      MealData(
        title: 'وجبة خفيفة',
        icon: Icons.brightness_5_outlined,
        iconColor: Colors.pinkAccent,
        items: [],
      ),
      MealData(
        title: 'العشاء',
        icon: Icons.nightlight_round,
        iconColor: Colors.amber,
        items: [],
      ),
    ];
  }

  Future<void> _loadFoods() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        meals = _createEmptyMeals();
        _loading = false;
      });
      return;
    }

    try {
      final date = _dateOnly(selectedDate).toIso8601String().split('T').first;

      final rows = await _supabase
          .from('food_logs')
          .select(
            'id, meal_type, food_name, serving_size, calories, protein, carbs, fat, logged_date, selected',
          )
          .eq('user_id', user.id)
          .eq('logged_date', date)
          .order('created_at', ascending: true);

      final loadedMeals = _createEmptyMeals();
      for (final row in rows) {
        final mealTitle = (row['meal_type'] ?? '').toString();
        final meal = loadedMeals.firstWhere(
          (m) => m.title == mealTitle,
          orElse: () => loadedMeals.first,
        );

        meal.items.add(
          FoodItem(
            id: row['id']?.toString(),
            name: (row['food_name'] ?? '').toString(),
            calories: _toInt(row['calories']),
            amount: (row['serving_size'] ?? '').toString(),
            protein: _toDouble(row['protein']),
            carbs: _toDouble(row['carbs']),
            fat: _toDouble(row['fat']),
            selected: row['selected'] == true,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        meals = loadedMeals;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحميل الطعام: $error')),
      );
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Iterable<FoodItem> get _allFoods sync* {
    for (final meal in meals) {
      for (final item in meal.items) {
        yield item;
      }
    }
  }

  Iterable<FoodItem> get _selectedFoods => _allFoods.where((item) => item.selected);

  int get totalFoodCalories =>
      _allFoods.fold<int>(0, (sum, item) => sum + item.calories);

  int get completedCalories =>
      _selectedFoods.fold<int>(0, (sum, item) => sum + item.calories);

  double get totalProtein =>
      _selectedFoods.fold<double>(0, (sum, item) => sum + item.protein);

  double get totalCarbs =>
      _selectedFoods.fold<double>(0, (sum, item) => sum + item.carbs);

  double get totalFat =>
      _selectedFoods.fold<double>(0, (sum, item) => sum + item.fat);

  String get formattedDate {
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
    return '${selectedDate.day} ${months[selectedDate.month - 1]}';
  }

  String get weekdayName {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[selectedDate.weekday - 1];
  }

  void selectDate(DateTime date) {
    setState(() => selectedDate = _dateOnly(date));
    _loadFoods();
  }

  Future<void> openAddFood(MealData meal) async {
    final FoodItem? result = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomFoodScreen(mealTitle: meal.title),
      ),
    );

    if (result == null) return;
    await _saveFoodToSupabase(meal, result);
  }

  Future<void> _saveFoodToSupabase(MealData meal, FoodItem item) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً لحفظ الطعام.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final date = _dateOnly(selectedDate).toIso8601String().split('T').first;

      final inserted = await _supabase
          .from('food_logs')
          .insert({
            'user_id': user.id,
            'meal_type': meal.title,
            'food_name': item.name,
            'serving_size': item.amount,
            'calories': item.calories,
            'protein': item.protein,
            'carbs': item.carbs,
            'fat': item.fat,
            'logged_date': date,
            'selected': false,
          })
          .select('id')
          .single();

      final savedItem = item.copyWith(id: inserted['id']?.toString(), selected: false);
      if (!mounted) return;
      setState(() {
        meal.items.add(savedItem);
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الطعام بنجاح ❤️‍🔥')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ الطعام: $error')),
      );
    }
  }

  Future<void> _deleteFood(MealData meal, FoodItem item) async {
    if (item.id == null) {
      setState(() => meal.items.remove(item));
      return;
    }

    try {
      await _supabase.from('food_logs').delete().eq('id', item.id!);
      if (!mounted) return;
      setState(() => meal.items.removeWhere((food) => food.id == item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الوجبة.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف الوجبة: $error')),
      );
    }
  }

  Future<void> _repeatFood(MealData meal, FoodItem item) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final date = _dateOnly(selectedDate).toIso8601String().split('T').first;
      final inserted = await _supabase
          .from('food_logs')
          .insert({
            'user_id': user.id,
            'meal_type': meal.title,
            'food_name': item.name,
            'serving_size': item.amount,
            'calories': item.calories,
            'protein': item.protein,
            'carbs': item.carbs,
            'fat': item.fat,
            'logged_date': date,
            'selected': false,
          })
          .select('id')
          .single();

      if (!mounted) return;
      setState(() {
        meal.items.add(item.copyWith(id: inserted['id']?.toString(), selected: false));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إعادة الوجبة.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إعادة الوجبة: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: darkBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تسجيل الطعام',
            style: TextStyle(
              color: darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: green),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      child: Column(
                        children: [
                          _buildDateSelector(),
                          const SizedBox(height: 18),
                          _buildDailySummary(),
                          const SizedBox(height: 18),
                          ...meals.map(
                            (meal) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildMealCard(meal),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _showMealPicker,
                              icon: const Icon(Icons.add, size: 27),
                              label: const Text(
                                'إضافة وجبة / طعام',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: green.withValues(alpha: .55),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_saving)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: Colors.black.withValues(alpha: .04),
                            alignment: Alignment.topCenter,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: LinearProgressIndicator(color: green),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final current = _dateOnly(selectedDate);
    final sunday = current.subtract(Duration(days: current.weekday % 7));
    final dates = List.generate(7, (index) => sunday.add(Duration(days: index)));

    return SizedBox(
      height: 94,
      child: Row(
        children: [
          for (int index = 0; index < dates.length; index++) ...[
            Expanded(child: _buildDateCard(dates[index])),
            if (index != dates.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date) {
    final isSelected = _sameDate(date, selectedDate);

    return GestureDetector(
      onTap: () => selectDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? softGreen : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF66CDAA) : const Color(0xFFE3E8EE),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _shortWeekday(date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? darkBlue : const Color(0xFF7E8997),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected ? darkBlue : const Color(0xFF27384D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _shortMonth(date),
              style: const TextStyle(
                color: Color(0xFF8C96A3),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _shortWeekday(DateTime date) {
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  String _shortMonth(DateTime date) {
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
    return months[date.month - 1];
  }

  Widget _buildDailySummary() {
    final percentage = totalFoodCalories == 0
        ? 0.0
        : (completedCalories / totalFoodCalories).clamp(0.0, 1.0).toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_right, color: Colors.white70),
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ملخص اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$weekdayName، $formattedDate',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _macroItem(
                  'البروتين',
                  '${_formatNumber(totalProtein)} جم',
                  const Color(0xFF65D8B0),
                ),
              ),
              Expanded(
                child: _macroItem(
                  'الكربوهيدرات',
                  '${_formatNumber(totalCarbs)} جم',
                  const Color(0xFF55B7F5),
                ),
              ),
              Expanded(
                child: _macroItem(
                  'الدهون',
                  '${_formatNumber(totalFat)} جم',
                  const Color(0xFFA779F7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withValues(alpha: .12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF52D5B5),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedCalories',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'سعرة',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'السعرات الحرارية',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCalories من $totalFoodCalories',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.white.withValues(alpha: .12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF55D5B2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Widget _macroItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: .65,
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _exampleFoodFor(String mealTitle) {
    switch (mealTitle) {
      case 'الفطور':
        return 'بيض';
      case 'الغداء':
        return 'دجاج مشوي';
      case 'وجبة خفيفة':
        return 'تفاحة';
      case 'العشاء':
        return 'سمك';
      default:
        return 'طعام';
    }
  }

  Widget _buildMealCard(MealData meal) {
    final calories = meal.items.fold<int>(0, (sum, item) => sum + item.calories);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBEF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(meal.icon, color: meal.iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 78,
                child: Text(
                  '$calories سعرة',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Color(0xFF6D7885),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (meal.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'مثال: ${_exampleFoodFor(meal.title)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF9AA3AD),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...meal.items.map((item) => _buildFoodRow(meal, item)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _saving ? null : () => openAddFood(meal),
              icon: const Icon(Icons.add, color: Color(0xFF18A980)),
              label: const Text(
                'إضافة طعام',
                style: TextStyle(
                  color: Color(0xFF18A980),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodRow(MealData meal, FoodItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 42,
            child: PopupMenuButton<String>(
              tooltip: 'خيارات الطعام',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, color: Color(0xFF173B67)),
              onSelected: (value) async {
                if (value == 'repeat') {
                  await _repeatFood(meal, item);
                } else if (value == 'delete') {
                  await _deleteFood(meal, item);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'repeat',
                  child: Row(
                    children: [
                      Icon(Icons.replay, color: Color(0xFF18A980)),
                      SizedBox(width: 10),
                      Text('إعادة الوجبة'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text('حذف الوجبة'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _toggleFoodSelection(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.selected ? green : Colors.white,
                border: Border.all(
                  color: item.selected ? green : const Color(0xFFB8C1CB),
                  width: 2,
                ),
              ),
              child: item.selected
                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.name,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF142B49),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.amount} • ${item.calories} سعرة',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF929BA5),
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

  Future<void> _toggleFoodSelection(FoodItem item) async {
    final nextValue = !item.selected;
    setState(() => item.selected = nextValue);

    if (item.id == null) return;

    try {
      await _supabase
          .from('food_logs')
          .update({'selected': nextValue})
          .eq('id', item.id!);
    } catch (error) {
      if (!mounted) return;
      setState(() => item.selected = !nextValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ حالة الطعام: $error')),
      );
    }
  }

  void _showMealPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اختر الوجبة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...meals.map(
                    (meal) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(meal.icon, color: meal.iconColor),
                      title: Text(
                        meal.title,
                        textAlign: TextAlign.right,
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        Navigator.pop(context);
                        openAddFood(meal);
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
  }
}

class AddCustomFoodScreen extends StatefulWidget {
  final String mealTitle;

  const AddCustomFoodScreen({
    super.key,
    required this.mealTitle,
  });

  @override
  State<AddCustomFoodScreen> createState() => _AddCustomFoodScreenState();
}

class _AddCustomFoodScreenState extends State<AddCustomFoodScreen> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    caloriesController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String _exampleFoodForMeal(String mealTitle) {
    switch (mealTitle) {
      case 'الفطور':
        return 'بيض';
      case 'الغداء':
        return 'دجاج مشوي';
      case 'وجبة خفيفة':
        return 'تفاحة';
      case 'العشاء':
        return 'سمك';
      default:
        return 'طعام';
    }
  }

  void saveFood() {
    final name = nameController.text.trim();
    final calories = int.tryParse(caloriesController.text.trim());
    final amount = amountController.text.trim();

    if (name.isEmpty || calories == null || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل معلومات الطعام أولاً')),
      );
      return;
    }

    // The add-food screen asks only for calories. To keep the daily
    // macro counters useful, estimate macros from the entered calories.
    // These are estimates, not nutrition-label values.
    final protein = calories * 0.25 / 4.0;
    final carbs = calories * 0.50 / 4.0;
    final fat = calories * 0.25 / 9.0;

    Navigator.pop(
      context,
      FoodItem(
        name: name,
        calories: calories,
        amount: amount,
        protein: protein,
        carbs: carbs,
        fat: fat,
        selected: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F9FC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF142B49)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'إضافة طعام مخصص',
            style: TextStyle(
              color: Color(0xFF142B49),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _sectionTitle('معلومات الطعام'),
                const SizedBox(height: 10),
                _field(
                  controller: nameController,
                  label: 'اسم الطعام',
                  hint: 'مثال: ${_exampleFoodForMeal(widget.mealTitle)}',
                  icon: Icons.restaurant_outlined,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: amountController,
                  label: 'حجم الحصة',
                  hint: 'مثال: 150 جرام',
                  icon: Icons.scale_outlined,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: caloriesController,
                  label: 'السعرات الحرارية',
                  hint: 'مثال: 350',
                  icon: Icons.local_fire_department_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 28),
                _sectionTitle('اختر الوجبة'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FBF5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.restaurant_menu, color: Color(0xFF13A67F)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.mealTitle,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFF142B49),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: saveFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0DB58A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'حفظ الطعام',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFF142B49),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF6E7885)),
        prefixIcon: Icon(icon, color: const Color(0xFF13A67F)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7ED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7ED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF13A67F),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class MealData {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<FoodItem> items;

  MealData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });
}

class FoodItem {
  final String? id;
  final String name;
  final int calories;
  final String amount;
  final double protein;
  final double carbs;
  final double fat;
  bool selected;

  FoodItem({
    this.id,
    required this.name,
    required this.calories,
    required this.amount,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.selected = false,
  });

  FoodItem copyWith({String? id, bool? selected}) {
    return FoodItem(
      id: id ?? this.id,
      name: name,
      calories: calories,
      amount: amount,
      protein: protein,
      carbs: carbs,
      fat: fat,
      selected: selected ?? this.selected,
    );
  }
}
