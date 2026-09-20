import 'package:supabase_flutter/supabase_flutter.dart';

class HabitService {
  final SupabaseClient _client =
      Supabase.instance.client;

  String? get _userId =>
      _client.auth.currentUser?.id;

  // ============================================================
  // جلب عادات المستخدم
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getHabits() async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final response = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order(
          'created_at',
          ascending: true,
        );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }

  // ============================================================
  // إضافة عادة جديدة
  // ============================================================

  Future<Map<String, dynamic>> addHabit({
    required String name,
    String description = '',
    bool completed = false,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final data =
        <String, dynamic>{
      'user_id': userId,
      'name': name,
      'description': description,
      'completed': completed,
    };

    final response = await _client
        .from('habits')
        .insert(data)
        .select()
        .single();

    return Map<String, dynamic>.from(
      response,
    );
  }

  // ============================================================
  // تحديث حالة العادة
  // ============================================================

  Future<void> updateHabit({
    required String id,
    bool? completed,
    String? name,
    String? description,
  }) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final data =
        <String, dynamic>{};

    if (completed != null) {
      data['completed'] =
          completed;
    }

    if (name != null) {
      data['name'] = name;
    }

    if (description != null) {
      data['description'] =
          description;
    }

    if (data.isEmpty) {
      return;
    }

    await _client
        .from('habits')
        .update(data)
        .eq('id', id)
        .eq(
          'user_id',
          userId,
        );
  }

  // ============================================================
  // حذف عادة
  // ============================================================

  Future<void> deleteHabit(
    String id,
  ) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    await _client
        .from('habits')
        .delete()
        .eq('id', id)
        .eq(
          'user_id',
          userId,
        );
  }

  // ============================================================
  // إعادة العادة إلى غير مكتملة
  // ============================================================

  Future<void> resetHabit(
    String id,
  ) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'يجب تسجيل الدخول أولاً',
      );
    }

    await _client
        .from('habits')
        .update({
      'completed': false,
    })
        .eq('id', id)
        .eq(
          'user_id',
          userId,
        );
  }
}
