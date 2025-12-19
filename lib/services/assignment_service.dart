import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';


class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  
  /// Teacher creates assignment
  Future<String?> createAssignment({
    required String classId,
    required String teacherId,
    required String title,
    String? description,
    DateTime? dueDate,
    int maxPoints = 100,
    }) async {
    try {
    await _supabase.from('assignments').insert({
    'class_id': classId,
    'teacher_id': teacherId,
    'title': title,
    'description': description,
    'due_date': dueDate?.toIso8601String(),
    'max_points': maxPoints,
    });
    return null;
    } catch (e) {
    return e.toString();
    }
  }
  
  
  /// Fetch assignments for a class
  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
    .from('assignments')
    .select('*')
    .eq('class_id', classId)
    .order('created_at', ascending: false);
    
    
    return List<Map<String, dynamic>>.from(res);
  }
  
  Future<String?> submitAssignment({
    required String assignmentId,
    required String studentId,
    required File file,
  }) async {
    try {
      // 1️⃣ Check assignment due date
      final assignment = await _supabase
          .from('assignments')
          .select('due_date')
          .eq('id', assignmentId)
          .maybeSingle();
  
      if (assignment == null) return "Assignment not found";
  
      final due = assignment['due_date'];
      if (due != null &&
          DateTime.now().isAfter(DateTime.parse(due))) {
        return "Submission closed (past due date)";
      }
  
      // 2️⃣ Upload file
      final filePath =
          '$assignmentId/$studentId-${DateTime.now().millisecondsSinceEpoch}';
  
      await _supabase.storage
          .from('assignment_uploads')
          .upload(filePath, file);
  
      final fileUrl = _supabase.storage
          .from('assignment_uploads')
          .getPublicUrl(filePath);
  
      // 3️⃣ Insert submission
      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentId,
        'student_id': studentId,
        'file_url': fileUrl,
      });
  
      return null;
    } catch (e) {
      if (e.toString().contains('unique')) {
        return "You already submitted this assignment";
      }
      return e.toString();
    }
  }

  /// Student submits assignment
  /*Future<String?> submitAssignment({
    required String assignmentId,
    required String studentId,
    required File file,
    }) async {
    try {
    final filePath = '$assignmentId/$studentId-${DateTime.now().millisecondsSinceEpoch}';
    
    
    await _supabase.storage
    .from('assignment_uploads')
    .upload(filePath, file);
    
    
    final fileUrl = _supabase.storage
    .from('assignment_uploads')
    .getPublicUrl(filePath);
    
    
    await _supabase.from('assignment_submissions').insert({
    'assignment_id': assignmentId,
    'student_id': studentId,
    'file_url': fileUrl,
    });
    
    
    return null;
    } catch (e) {
    return e.toString();
    }
  }*/
  
  
  /// Teacher views submissions
  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
  final res = await _supabase
    .from('assignment_submissions')
    .select('*, profiles(full_name)')
    .eq('assignment_id', assignmentId);
    
    
    return List<Map<String, dynamic>>.from(res);
  }
}
