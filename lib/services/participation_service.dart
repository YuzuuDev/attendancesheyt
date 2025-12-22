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
    // 1️⃣ Get enrolled student IDs
    final res = await _supabase
        .from('class_students')
        .select('student_id')
        .eq('class_id', classId);

    final students = List<Map<String, dynamic>>.from(res);

    // 2️⃣ Manually attach profiles (PROVEN WORKING PATTERN)
    for (int i = 0; i < students.length; i++) {
      final studentId = students[i]['student_id'];

      final profile = await _supabase
          .from('profiles')
          .select('id, full_name, participation_points')
          .eq('id', studentId)
          .maybeSingle();

      students[i]['profiles'] = profile;
    }

    return students;
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
