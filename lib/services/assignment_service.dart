import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* ===============================
     TEACHER
     =============================== */

  Future<void> createAssignment({
    required String classId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final teacherId = _supabase.auth.currentUser!.id;

    await _supabase.from('assignments').insert({
      'class_id': classId,
      'teacher_id': teacherId, // 🔥 THIS WAS YOUR POSTGRES ERROR
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select('*')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _supabase.from('assignments').delete().eq('id', assignmentId);
  }

  /* ===============================
     STUDENT
     =============================== */

  Future<void> submitAssignment({
    required String assignmentId,
    required File file,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final fileName = file.path.split('/').last;
    final path = '$userId/$assignmentId/$fileName';

    await _supabase.storage.from('assignments').upload(path, file);

    final fileUrl =
        _supabase.storage.from('assignments').getPublicUrl(path);

    await _supabase.from('assignment_submissions').insert({
      'assignment_id': assignmentId,
      'student_id': userId,
      'file_url': fileUrl,
    });
  }

  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
    final res = await _supabase
        .from('assignment_submissions')
        .select('''
          id,
          file_url,
          submitted_at,
          profiles(full_name)
        ''')
        .eq('assignment_id', assignmentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}
