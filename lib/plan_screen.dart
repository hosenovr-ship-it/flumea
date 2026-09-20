import 'package:flutter/material.dart';
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

  int selectedDay = 0;

  bool _isLoadingTasks = true;
  bool _isSavingTask = false;
  bool _isSavingHabit = false;

  List<Map<String, dynamic>> tasks = [];

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

  // ============================================================
  // SUPABASE - تحميل المهام
  // ============================================================

  Future<void> _loadTasks() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final loadedTasks = await _taskService.getTasks();

      if (!mounted) {
        return;
      }

      if (loadedTasks.isEmpty) {
        await _createInitialTasks();
      } else {
        setState(() {
          tasks = loadedTasks;
          _isLoadingTasks = false;
        });
      }
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
        final initialHabits = [
          {
            'name': 'شرب الماء',
            'description': '',
          },
          {
            'name': 'الرياضة',
            'description': '',
          },
          {
            'name': 'القراءة',
            'description': '',
          },
        ];

        final createdHabits = <Map<String, dynamic>>[];

        for (final habit in initialHabits) {
          final created = await _habitService.addHabit(
            name: habit['name'] as String,
            description: habit['description'] as String,
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
            habits.add({
              'id': habit['id'],
              'title': habit['name'] ?? '',
              'description': habit['description'] ?? '',
              'completed': habit['completed'] ?? false,
              'icon': _habitIconForName(
                habit['name'] ?? '',
              ),
            });
          }
        });

        return;
      }

      setState(() {
        habits.clear();

        for (final habit in loadedHabits) {
          habits.add({
            'id': habit['id'],
            'title': habit['name'] ?? '',
            'description': habit['description'] ?? '',
            'completed': habit['completed'] ?? false,
            'icon': _habitIconForName(
              habit['name'] ?? '',
            ),
          });
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

  IconData _habitIconForName(String name) {
    switch (name.trim()) {
      case 'شرب الماء':
        return Icons.water_drop_outlined;
      case 'الرياضة':
        return Icons.fitness_center_outlined;
      case 'القراءة':
        return Icons.menu_book_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
    // ============================================================
  // المهام - تغيير حالة المهمة
  // ============================================================

  Future<void> _toggleTask(
    String id,
    bool completed,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _taskService.updateTask(
        id: id,
        completed: !completed,
      );

      if (!mounted) {
        return;
      }

      final index = tasks.indexWhere(
        (task) => _safeString(task['id']) == id,
      );

      if (index != -1) {
        setState(() {
          tasks[index]['completed'] = !completed;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // المهام - حذف مهمة
  // ============================================================

  Future<void> _deleteTask(
    String id,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _taskService.deleteTask(id);

      if (!mounted) {
        return;
      }

      setState(() {
        tasks.removeWhere(
          (task) => _safeString(task['id']) == id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حذف المهمة 🗑️',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // المهام - إعادة المهمة إلى غير مكتملة
  // ============================================================

  Future<void> _resetTask(
    String id,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _taskService.updateTask(
        id: id,
        completed: false,
      );

      if (!mounted) {
        return;
      }

      final index = tasks.indexWhere(
        (task) => _safeString(task['id']) == id,
      );

      if (index != -1) {
        setState(() {
          tasks[index]['completed'] = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إعادة المهمة 🔄',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // المهام - إضافة مهمة جديدة
  // ============================================================

  Future<void> _addTask({
    required String title,
    String description = '',
    String time = '',
    String tag = '',
    String emoji = '📝',
    String color = '#1478D4',
  }) async {
    if (title.trim().isEmpty) {
      return;
    }

    if (_isSavingTask) {
      return;
    }

    setState(() {
      _isSavingTask = true;
    });

    try {
      final newTask = await _taskService.addTask(
        title: title.trim(),
        description: description.trim(),
        time: time.trim(),
        tag: tag.trim(),
        emoji: emoji.trim(),
        color: color,
        completed: false,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        tasks.add(newTask);
        _isSavingTask = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إضافة المهمة وحفظها ✅',
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر حفظ المهمة: $error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // العادات - تغيير حالة العادة
  // ============================================================

  Future<void> _toggleHabit(
    String id,
    bool completed,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _habitService.updateHabit(
        id: id,
        completed: !completed,
      );

      if (!mounted) {
        return;
      }

      final index = habits.indexWhere(
        (habit) => _safeString(habit['id']) == id,
      );

      if (index != -1) {
        setState(() {
          habits[index]['completed'] = !completed;
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // العادات - حذف عادة
  // ============================================================

  Future<void> _deleteHabit(
    String id,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _habitService.deleteHabit(id);

      if (!mounted) {
        return;
      }

      setState(() {
        habits.removeWhere(
          (habit) => _safeString(habit['id']) == id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حذف العادة 🗑️',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // العادات - إعادة العادة
  // ============================================================

  Future<void> _resetHabit(
    String id,
  ) async {
    if (id.isEmpty) {
      return;
    }

    try {
      await _habitService.resetHabit(id);

      if (!mounted) {
        return;
      }

      final index = habits.indexWhere(
        (habit) => _safeString(habit['id']) == id,
      );

      if (index != -1) {
        setState(() {
          habits[index]['completed'] = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إعادة العادة 🔄',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
  // العادات - إضافة عادة جديدة وحفظها في Supabase
  // ============================================================

  Future<void> _addHabit({
    required String name,
    String description = '',
  }) async {
    if (name.trim().isEmpty) {
      return;
    }

    if (_isSavingHabit) {
      return;
    }

    setState(() {
      _isSavingHabit = true;
    });

    try {
      final newHabit = await _habitService.addHabit(
        name: name.trim(),
        description: description.trim(),
        completed: false,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        habits.add({
          'id': newHabit['id'],
          'title': newHabit['name'] ?? name.trim(),
          'description':
              newHabit['description'] ?? description.trim(),
          'completed':
              newHabit['completed'] ?? false,
          'icon': _habitIconForName(
            newHabit['name'] ?? name.trim(),
          ),
        });

        _isSavingHabit = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إضافة العادة وحفظها ✅',
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
  }

  // ============================================================
  // الأيام
  // ============================================================

  List<String> _weekDays() {
    return const [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
  }

  // ============================================================
  // حساب عدد المهام المكتملة
  // ============================================================

  int _completedTasksCount() {
    return tasks.where(
      (task) => task['completed'] == true,
    ).length;
  }

  // ============================================================
  // حساب عدد العادات المكتملة
  // ============================================================

  int _completedHabitsCount() {
    return habits.where(
      (habit) => habit['completed'] == true,
    ).length;
  }

  // ============================================================
  // إجمالي العناصر المكتملة
  // ============================================================

  int _completedTotalCount() {
    return _completedTasksCount() +
        _completedHabitsCount();
  }

  // ============================================================
  // إجمالي العناصر
  // ============================================================

  int _totalItemsCount() {
    return tasks.length + habits.length;
  }

  // ============================================================
  // نسبة الإنجاز
  // ============================================================

  double _progressValue() {
    final total = _totalItemsCount();

    if (total == 0) {
      return 0;
    }

    return _completedTotalCount() / total;
  }
    // ============================================================
  // تغيير اليوم المحدد
  // ============================================================

  void _selectDay(int index) {
    if (index < 0 || index >= 7) {
      return;
    }

    setState(() {
      selectedDay = index;
    });
  }

  // ============================================================
  // نافذة إضافة مهمة
  // ============================================================

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController =
        TextEditingController();
    final timeController =
        TextEditingController();
    final tagController =
        TextEditingController();

    String selectedEmoji = '📝';
    String selectedColor = '#1478D4';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24),
              ),
              title: const Text(
                'إضافة مهمة',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: navy,
                ),
              ),
              content: SingleChildScrollView(
                child: Directionality(
                  textDirection:
                      TextDirection.rtl,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextField(
                        controller:
                            titleController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            InputDecoration(
                          labelText:
                              'اسم المهمة',
                          hintText:
                              'مثال: قراءة كتاب',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller:
                            descriptionController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            InputDecoration(
                          labelText:
                              'الوصف',
                          hintText:
                              'وصف مختصر للمهمة',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller:
                            timeController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            InputDecoration(
                          labelText:
                              'الوقت',
                          hintText:
                              'مثال: 5:00 م',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller:
                            tagController,
                        decoration:
                            InputDecoration(
                          labelText:
                              'التصنيف',
                          hintText:
                              'مثال: دراسة',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: const Text(
                          'اختر الرمز',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: navy,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          '📝',
                          '📚',
                          '🏋️',
                          '🍽️',
                          '💼',
                          '📖',
                          '🎯',
                          '💡',
                          '🧠',
                          '☀️',
                        ].map(
                          (emoji) {
                            final isSelected =
                                selectedEmoji ==
                                    emoji;

                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedEmoji =
                                      emoji;
                                });
                              },
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      180,
                                ),
                                width: 44,
                                height: 44,
                                alignment:
                                    Alignment.center,
                                decoration:
                                    BoxDecoration(
                                  color: isSelected
                                      ? blue.withOpacity(
                                          0.12,
                                        )
                                      : Colors.grey
                                          .withOpacity(
                                          0.08,
                                        ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        isSelected
                                            ? blue
                                            : Colors
                                                .transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: const Text(
                          'اختر اللون',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: navy,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          '#1478D4',
                          '#20C7B7',
                          '#EF5350',
                          '#FFA726',
                          '#8E44AD',
                          '#E57C72',
                        ].map(
                          (color) {
                            final isSelected =
                                selectedColor ==
                                    color;

                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedColor =
                                      color;
                                });
                              },
                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      180,
                                ),
                                width: 34,
                                height: 34,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      _safeColor(
                                    color,
                                  ),
                                  shape:
                                      BoxShape.circle,
                                  border:
                                      Border.all(
                                    color:
                                        isSelected
                                            ? navy
                                            : Colors
                                                .transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
                            actionsPadding:
                  const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
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
                  onPressed: _isSavingTask
                      ? null
                      : () async {
                          final title =
                              titleController
                                  .text
                                  .trim();

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'اكتب اسم المهمة أولاً',
                                ),
                              ),
                            );
                            return;
                          }

                          await _addTask(
                            title: title,
                            description:
                                descriptionController
                                    .text
                                    .trim(),
                            time:
                                timeController
                                    .text
                                    .trim(),
                            tag:
                                tagController
                                    .text
                                    .trim(),
                            emoji: selectedEmoji,
                            color: selectedColor,
                          );

                          if (!mounted) {
                            return;
                          }

                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: _isSavingTask
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'إضافة',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // نافذة إضافة عادة
  // ============================================================

  void _showAddHabitDialog() {
    final nameController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Text(
            'إضافة عادة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              color: navy,
            ),
          ),
          content: Directionality(
            textDirection:
                TextDirection.rtl,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      nameController,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      InputDecoration(
                    labelText:
                        'اسم العادة',
                    hintText:
                        'مثال: شرب الماء',
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  controller:
                      descriptionController,
                  maxLines: 2,
                  decoration:
                      InputDecoration(
                    labelText:
                        'الوصف',
                    hintText:
                        'وصف مختصر للعادة',
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),.
                    actionsPadding:
              const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
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
              onPressed: _isSavingHabit
                  ? null
                  : () async {
                      final name =
                          nameController
                              .text
                              .trim();

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'اكتب اسم العادة أولاً',
                            ),
                          ),
                        );
                        return;
                      }

                      await _addHabit(
                        name: name,
                        description:
                            descriptionController
                                .text
                                .trim(),
                      );

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );
                    },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: _isSavingHabit
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'إضافة',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // نافذة خيارات المهمة
  // ============================================================

  void _showTaskOptions(
    String id,
    bool completed,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'خيارات المهمة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  if (completed)
                    ListTile(
                      leading:
                          const Icon(
                        Icons
                            .refresh_rounded,
                        color: blue,
                      ),
                      title:
                          const Text(
                        'إعادة المهمة',
                      ),
                      onTap: () async {
                        Navigator.pop(
                          sheetContext,
                        );

                        await _resetTask(
                          id,
                        );
                      },
                    ),
                  ListTile(
                    leading:
                        const Icon(
                      Icons
                          .delete_outline_rounded,
                      color: Colors.red,
                    ),
                    title:
                        const Text(
                      'حذف المهمة',
                    ),
                    onTap: () async {
                      Navigator.pop(
                        sheetContext,
                      );

                      await _deleteTask(
                        id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
    // ============================================================
  // نافذة خيارات العادة
  // ============================================================

  void _showHabitOptions(
    String id,
    bool completed,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'خيارات العادة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  if (completed)
                    ListTile(
                      leading:
                          const Icon(
                        Icons
                            .refresh_rounded,
                        color: blue,
                      ),
                      title:
                          const Text(
                        'إعادة العادة',
                      ),
                      onTap: () async {
                        Navigator.pop(
                          sheetContext,
                        );

                        await _resetHabit(
                          id,
                        );
                      },
                    ),
                  ListTile(
                    leading:
                        const Icon(
                      Icons
                          .delete_outline_rounded,
                      color: Colors.red,
                    ),
                    title:
                        const Text(
                      'حذف العادة',
                    ),
                    onTap: () async {
                      Navigator.pop(
                        sheetContext,
                      );

                      await _deleteHabit(
                        id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // بناء الصفحة الرئيسية
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Directionality(
          textDirection:
              TextDirection.rtl,
          child: CustomScrollView(
            physics:
                const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              SliverToBoxAdapter(
                child: _buildWeekSelector(),
              ),

              SliverToBoxAdapter(
                child: _buildProgressCard(),
              ),

              SliverToBoxAdapter(
                child: _buildDailyTasks(),
              ),

              SliverToBoxAdapter(
                child: _buildDailyHabits(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 110,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          const BottomNavigation(),
    );
  }
