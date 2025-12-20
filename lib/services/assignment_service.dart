import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* ===============================
     TEACHER FUNCTIONS
     =============================== */

  // Create assignment
  Future<void> createAssignment({
    required String classId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    await _supabase.from('assignments').insert({
      'class_id': classId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
    });
  }

  // Get assignments for a class (teacher & student)
  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select('*')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    await _supabase
        .from('assignments')
        .delete()
        .eq('id', assignmentId);
  }

  /* ===============================
     STUDENT FUNCTIONS
     =============================== */

  // Submit assignment (FILE + DB ROW)
  Future<void> submitAssignment({
    required String assignmentId,
    required String filePath,
  }) async {
    final user = _supabase.auth.currentUser!;
    final userId = user.id;

    final fileName = filePath.split('/').last;
    final storagePath = '$userId/$assignmentId/$fileName';

    // Upload file
    await _supabase.storage
        .from('assignments')
        .upload(storagePath, File(filePath));

    // Get public URL
    final fileUrl = _supabase.storage
        .from('assignments')
        .getPublicUrl(storagePath);

    // Insert submission row
    await _supabase.from('assignment_submissions').insert({
      'assignment_id': assignmentId,
      'student_id': userId,
      'file_url': fileUrl,
    });
  }

  // Get submissions for ONE assignment (teacher)
  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
    final res = await _supabase
        .from('assignment_submissions')
        .select('''
          id,
          file_url,
          submitted_at,
          profiles (
            full_name
          )
        ''')
        .eq('assignment_id', assignmentId)
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  // Check if student already submitted
  Future<bool> hasSubmitted(String assignmentId) async {
    final userId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('assignment_submissions')
        .select('id')
        .eq('assignment_id', assignmentId)
        .eq('student_id', userId)
        .maybeSingle();

    return res != null;
  }
}
