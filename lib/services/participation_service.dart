import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ===============================
  // STUDENT SIDE
  // ===============================

  Future<int> getStudentPoints(String studentId) async {
    final res = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();

    return res?['participation_points'] ?? 0;
  }

  // ===============================
  // TEACHER SIDE
  // ===============================

  Future<List<Map<String, dynamic>>> getClassStudents(String classId) async {
    final res = await _supabase
        .from('class_students')
        .select('student_id, profiles(id, full_name, participation_points)')
        .eq('class_id', classId);

    return List<Map<String, dynamic>>.from(res);
  }

  /// 🔥 THIS IS WHAT WAS MISSING
  Future<void> addPoints({
    required String classId,
    required String studentId,
    required int points,
    required String reason,
  }) async {
    final teacherId = _supabase.auth.currentUser!.id;

    // 1️⃣ Get current points
    final profile = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();

    final currentPoints = profile?['participation_points'] ?? 0;
    final newPoints = currentPoints + points;

    // 2️⃣ Update total points
    await _supabase
        .from('profiles')
        .update({'participation_points': newPoints})
        .eq('id', studentId);

    // 3️⃣ Log participation action
    await _supabase.from('participation_logs').insert({
      'class_id': classId,
      'student_id': studentId,
      'teacher_id': teacherId,
      'points': points,
      'reason': reason,
    });
  }
}

/*import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addPoints({
    required String classId,
    required String studentId,
    required int points,
    required String reason,
  }) async {
    final teacherId = _supabase.auth.currentUser!.id;

    // 1. Log participation
    await _supabase.from('participation_logs').insert({
      'class_id': classId,
      'student_id': studentId,
      'teacher_id': teacherId,
      'points': points,
      'reason': reason,
    });

    // 2. Update cached total
    final profile = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();

    final current = profile?['participation_points'] ?? 0;

    await _supabase.from('profiles').update({
      'participation_points': current + points,
    }).eq('id', studentId);
  }

  Future<int> getStudentPoints(String studentId) async {
    final res = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();

    return res?['participation_points'] ?? 0;
  }

  Future<List<Map<String, dynamic>>> getClassStudents(String classId) async {
    return await _supabase
        .from('class_students')
        .select('student_id, profiles(full_name, participation_points)')
        .eq('class_id', classId);
  }
}*/
