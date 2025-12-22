import 'package:flutter/material.dart';
import '../../services/recitation_service.dart';

class RecitationScreen extends StatefulWidget {
  final String assignmentId;
  const RecitationScreen({super.key, required this.assignmentId});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  final service = RecitationService();
  Map<String, String> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recitation')),
      body: FutureBuilder(
        future: service.getQuestions(widget.assignmentId),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final questions = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: questions.map((q) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['question_text'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (q['type'] == 'mcq')
                        ...List<String>.from(q['choices']).map((c) {
                          return RadioListTile<String>(
                            value: c,
                            groupValue: answers[q['id']],
                            title: Text(c),
                            onChanged: (v) {
                              setState(() => answers[q['id']] = v!);
                            },
                          );
                        }),

                      if (q['type'] == 'text')
                        TextField(
                          onChanged: (v) => answers[q['id']] = v,
                          decoration: const InputDecoration(labelText: 'Your Answer'),
                        ),

                      ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: () async {
                          await service.submitAnswer(
                            questionId: q['id'],
                            answer: answers[q['id']] ?? '',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Answer submitted')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
