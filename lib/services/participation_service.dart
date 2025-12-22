import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipationService {
  final _supabase = Supabase.instance.client;

  Future<void> addPoints({
    required String studentId,
    required int delta,
  }) async {
    final res = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .single();

    final current = res['participation_points'] ?? 0;

    await _supabase.from('profiles').update({
      'participation_points': current + delta,
    }).eq('id', studentId);
  }

  Future<int> getPoints(String studentId) async {
    final res = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();

    return res?['participation_points'] ?? 0;
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
