import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getTasks() async {
    final response = await _supabase
        .from('tasks')
        .select()
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addTask({
    required String title,
    String? description,
  }) async {
    await _supabase.from('tasks').insert({
      'title': title,
      'description': description,
    });
  }

  Future<void> completeTask({
    required String taskId,
    required bool completed,
  }) async {
    await _supabase.from('tasks').update({
      'completed': completed,
    }).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabase
        .from('tasks')
        .delete()
        .eq('id', taskId);
  }
}
