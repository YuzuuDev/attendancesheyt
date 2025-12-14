import 'package:supabase_flutter/supabase_flutter.dart';

class ClassService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CREATE CLASS
  Future<String?> createClass(String name, String teacherId) async {
    try {
      final code = _generateClassCode();
      await _supabase.from('classes').insert({
        'name': name,
        'code': code,
        'teacher_id': teacherId,
      });
      return code;
    } catch (e) {
      return e.toString();
    }
  }

  // JOIN CLASS
  Future<String?> joinClass(String code, String studentId) async {
    try {
      final cls = await _supabase
          .from('classes')
          .select('id')
          .eq('code', code)
          .maybeSingle();

      if (cls == null) return "Class not found";

      await _supabase.from('class_students').insert({
        'class_id': cls['id'],
        'student_id': studentId,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // GET STUDENTS — WORKING
  Future<List<Map<String, dynamic>>> getStudents(String classId) async {
    final response = await _supabase
        .from('class_students')
        .select('profiles(full_name, role)')
        .eq('class_id', classId);

    return List<Map<String, dynamic>>.from(response);
  }

  // GET TEACHER CLASSES
  Future<List<Map<String, dynamic>>> getTeacherClasses(String teacherId) async {
    final response = await _supabase
        .from('classes')
        .select('id, name, code')
        .eq('teacher_id', teacherId);

    return List<Map<String, dynamic>>.from(response);
  }

  // GET STUDENT CLASSES
  Future<List<Map<String, dynamic>>> getStudentClasses(String studentId) async {
    final response = await _supabase
        .from('class_students')
        .select('classes(name, code)')
        .eq('student_id', studentId);

    return List<Map<String, dynamic>>.from(response);
  }

  String _generateClassCode() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return random.toString().padLeft(6, '0');
  }
}
