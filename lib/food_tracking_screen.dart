import 'package:flutter/material.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  DateTime selectedDate = DateTime.now();

  final List<MealData> meals = [
    MealData(
      title: 'الفطور',
      icon: Icons.wb_sunny_outlined,
      iconColor: Colors.orange,
      items: [
        FoodItem(name: 'شوفان بالحليب', calories: 250, amount: '1 طبق'),
        FoodItem(name: 'موزة متوسطة', calories: 105, amount: '1 حبة'),
        FoodItem(name: 'قهوة سوداء', calories: 0, amount: '1 كوب'),
      ],
    ),
    MealData(
      title: 'الغداء',
      icon: Icons.wb_sunny_outlined,
      iconColor: Colors.orange,
      items: [
        FoodItem(name: 'دجاج مشوي', calories: 350, amount: '150 جرام'),
        FoodItem(name: 'أرز أبيض', calories: 200, amount: '1 كوب'),
        FoodItem(name: 'سلطة خضراء', calories: 70, amount: '1 طبق'),
      ],
    ),
    MealData(
      title: 'وجبة خفيفة',
      icon: Icons.brightness_5_outlined,
      iconColor: Colors.pinkAccent,
      items: [
        FoodItem(name: 'تفاحة متوسطة', calories: 95, amount: '1 حبة'),
      ],
    ),
    MealData(
      title: 'العشاء',
      icon: Icons.nightlight_round,
      iconColor: Colors.amber,
      items: [],
    ),
  ];

  int get totalCalories {
    return meals.fold(
      0,
      (sum, meal) =>
          sum + meal.items.fold(0, (s, item) => s + item.calories),
    );
  }

  final int dailyGoal = 2200;

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
    setState(() => selectedDate = date);
  }

  Future<void> openAddFood(MealData meal) async {
    final FoodItem? result = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomFoodScreen(mealTitle: meal.title),
      ),
    );

    if (result == null) return;

    setState(() => meal.items.add(result));
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
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF142B49),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تسجيل الطعام',
            style: TextStyle(
              color: Color(0xFF142B49),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
                    onPressed: _showMealPicker,
                    icon: const Icon(Icons.add, size: 27),
                    label: const Text(
                      'إضافة وجبة / طعام',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0DB58A),
                      foregroundColor: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final dates = List.generate(
      5,
      (index) => selectedDate.subtract(Duration(days: 2 - index)),
    );

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 82,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE9FBF5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF66CDAA)
                      : const Color(0xFFE3E8EE),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _shortWeekday(date),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF142B49)
                          : const Color(0xFF7E8997),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF142B49)
                          : const Color(0xFF27384D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _shortMonth(date),
                    style: const TextStyle(
                      color: Color(0xFF8C96A3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
    final percentage = (totalCalories / dailyGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF092D54),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_right, color: Colors.white70),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ملخص اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$weekdayName، $formattedDate',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _macroItem(
                  'البروتين',
                  '0 جم / 120 جم',
                  const Color(0xFF65D8B0),
                ),
              ),
              Expanded(
                child: _macroItem(
                  'الكربوهيدرات',
                  '0 جم / 280 جم',
                  const Color(0xFF55B7F5),
                ),
              ),
              Expanded(
                child: _macroItem(
                  'الدهون',
                  '0 جم / 70 جم',
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
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          Color(0xFF52D5B5),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalCalories',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'سعرة',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalCalories من $dailyGoal',
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
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
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

  Widget _macroItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
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

  Widget _buildMealCard(MealData meal) {
    final calories =
        meal.items.fold<int>(0, (sum, item) => sum + item.calories);

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
              Text(
                '$calories سعرة',
                style: const TextStyle(
                  color: Color(0xFF6D7885),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    meal.title,
                    style: const TextStyle(
                      color: Color(0xFF142B49),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    meal.icon,
                    color: meal.iconColor,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (meal.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'لم تتم إضافة طعام بعد',
                style: TextStyle(color: Color(0xFF9AA3AD)),
              ),
            )
          else
            ...meal.items.map(_buildFoodRow),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => openAddFood(meal),
            icon: const Icon(
              Icons.add,
              color: Color(0xFF18A980),
            ),
            label: const Text(
              'إضافة طعام',
              style: TextStyle(
                color: Color(0xFF18A980),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodRow(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '${item.calories} سعرة',
            style: const TextStyle(
              color: Color(0xFF6E7885),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF27384D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.amount,
                style: const TextStyle(
                  color: Color(0xFF929BA5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMealPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
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
                  const Text(
                    'اختر الوجبة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF142B49),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...meals.map(
                    (meal) => ListTile(
                      leading: Icon(
                        meal.icon,
                        color: meal.iconColor,
                      ),
                      title: Text(meal.title),
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
  State<AddCustomFoodScreen> createState() =>
      _AddCustomFoodScreenState();
}

class _AddCustomFoodScreenState
    extends State<AddCustomFoodScreen> {
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

  void saveFood() {
    final name = nameController.text.trim();
    final calories = int.tryParse(
      caloriesController.text.trim(),
    );
    final amount = amountController.text.trim();

    if (name.isEmpty || calories == null || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل معلومات الطعام أولاً'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      FoodItem(
        name: name,
        calories: calories,
        amount: amount,
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
            icon: const Icon(
              Icons.close,
              color: Color(0xFF142B49),
            ),
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
                  hint: 'مثال: دجاج مشوي',
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
                      const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF13A67F),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.mealTitle,
                        style: const TextStyle(
                          color: Color(0xFF142B49),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF13A67F),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E7ED),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE1E7ED),
          ),
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
  final String name;
  final int calories;
  final String amount;

  FoodItem({
    required this.name,
    required this.calories,
    required this.amount,
  });
}
