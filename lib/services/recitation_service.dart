import 'package:supabase_flutter/supabase_flutter.dart';

class RecitationService {
  final _supabase = Supabase.instance.client;

  // ===============================
  // TEACHER
  // ===============================

  Future<void> addQuestion({
    required String assignmentId,
    required String question,
    required String questionType, // 'text' | 'mcq'
    String? correctAnswer,
    int points = 1,
    List<String>? choices,
  }) async {
    final q = await _supabase.from('recitation_questions').insert({
      'assignment_id': assignmentId,
      'question': question,
      'question_type': questionType,
      'correct_answer': correctAnswer,
      'points': points,
    }).select().single();

    if (questionType == 'mcq' && choices != null) {
      for (final c in choices) {
        await _supabase.from('recitation_choices').insert({
          'question_id': q['id'],
          'choice_text': c,
        });
      }
    }
  }

  // ===============================
  // STUDENT
  // ===============================

  Future<List<Map<String, dynamic>>> getQuestions(String assignmentId) async {
    final res = await _supabase
        .from('recitation_questions')
        .select('*, recitation_choices(*)')
        .eq('assignment_id', assignmentId);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> submitAnswer({
    required String questionId,
    required String answer,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final q = await _supabase
        .from('recitation_questions')
        .select('correct_answer, points')
        .eq('id', questionId)
        .single();

    final correct = q['correct_answer'];
    final isCorrect =
        correct != null && correct.toString().trim() == answer.trim();

    await _supabase.from('recitation_answers').upsert({
      'question_id': questionId,
      'student_id': userId,
      'answer': answer,
      'is_correct': isCorrect,
      'points_awarded': isCorrect ? q['points'] : 0,
    });

    if (isCorrect) {
      // add participation points
      await _supabase.rpc('increment_participation', params: {
        'uid': userId,
        'pts': q['points'],
      });
    }
  }
}
