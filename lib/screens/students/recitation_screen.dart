import 'package:flutter/material.dart';
import '../../services/recitation_service.dart';

class RecitationScreen extends StatelessWidget {
  final String assignmentId;

  const RecitationScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    final service = RecitationService();

    return Scaffold(
      appBar: AppBar(title: const Text("Recitation")),
      body: FutureBuilder(
        future: service.getQuestions(assignmentId),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final questions = snap.data as List<Map<String, dynamic>>;

          if (questions.isEmpty) {
            return const Center(child: Text("No questions"));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (_, i) {
              final q = questions[i];
              final ctrl = TextEditingController();

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q['question'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (q['question_type'] == 'text')
                        TextField(controller: ctrl),

                      if (q['question_type'] == 'mcq')
                        ...(q['recitation_choices'] as List)
                            .map((c) => RadioListTile(
                                  value: c['choice_text'],
                                  groupValue: ctrl.text,
                                  onChanged: (v) => ctrl.text = v!,
                                  title: Text(c['choice_text']),
                                )),

                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text("Submit"),
                        onPressed: () async {
                          await service.submitAnswer(
                            questionId: q['id'],
                            answer: ctrl.text,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Answer submitted")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
