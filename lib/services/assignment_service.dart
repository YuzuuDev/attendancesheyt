import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* ===============================
     CREATE ASSIGNMENT (TEACHER)
     =============================== */
  Future<String?> createAssignment({
    required String classId,
    required String teacherId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    try {
      await _supabase.from('assignments').insert({
        'class_id': classId,
        'teacher_id': teacherId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /* ===============================
     FETCH ASSIGNMENTS
     =============================== */
  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select('*')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  /* ===============================
     DELETE ASSIGNMENT
     =============================== */
  Future<void> deleteAssignment(String assignmentId) async {
    await _supabase.from('assignments').delete().eq('id', assignmentId);
  }

  /* ===============================
     SUBMIT ASSIGNMENT (STUDENT)
     =============================== */
  Future<String?> submitAssignment({
    required String assignmentId,
    required File file,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final fileName = file.path.split('/').last;
      final storagePath = '$userId/$assignmentId/$fileName';

      await _supabase.storage
          .from('assignments')
          .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

      final fileUrl =
          _supabase.storage.from('assignments').getPublicUrl(storagePath);

      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentId,
        'student_id': userId,
        'file_url': fileUrl,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /* ===============================
     GET SUBMISSIONS (TEACHER)
     =============================== */
  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
    final res = await _supabase
        .from('assignment_submissions')
        .select('*')
        .eq('assignment_id', assignmentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }
}
