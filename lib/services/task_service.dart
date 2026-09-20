import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getTasks() async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> addTask({
    required String title,
    String description = '',
    String time = '',
    String tag = '',
    String emoji = '📝',
    String color = '#1478D4',
    bool completed = false,
    String priority = 'normal',
    DateTime? dueDate,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final data = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'description': description,
      'time': time,
      'tag': tag,
      'emoji': emoji,
      'color': color,
      'completed': completed,
      'priority': priority,
    };

    if (dueDate != null) {
      data['due_date'] =
          dueDate.toIso8601String().split('T').first;
    }

    final response = await _client
        .from('tasks')
        .insert(data)
        .select()
        .single();

    return Map<String, dynamic>.from(response);
  }

  Future<void> updateTask({
    required String id,
    bool? completed,
    String? title,
    String? description,
    String? time,
    String? tag,
    String? emoji,
    String? color,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final data = <String, dynamic>{};

    if (completed != null) {
      data['completed'] = completed;
    }

    if (title != null) {
      data['title'] = title;
    }

    if (description != null) {
      data['description'] = description;
    }

    if (time != null) {
      data['time'] = time;
    }

    if (tag != null) {
      data['tag'] = tag;
    }

    if (emoji != null) {
      data['emoji'] = emoji;
    }

    if (color != null) {
      data['color'] = color;
    }

    if (data.isEmpty) {
      return;
    }

    await _client
        .from('tasks')
        .update(data)
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteTask(String id) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    await _client
        .from('tasks')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
