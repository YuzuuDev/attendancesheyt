import 'package:flutter/material.dart';
import '../../services/recitation_service.dart';

class CreateRecitationQuestionScreen extends StatefulWidget {
  final String assignmentId;
  const CreateRecitationQuestionScreen({super.key, required this.assignmentId});

  @override
  State<CreateRecitationQuestionScreen> createState() =>
      _CreateRecitationQuestionScreenState();
}

class _CreateRecitationQuestionScreenState
    extends State<CreateRecitationQuestionScreen> {
  final service = RecitationService();
  final questionCtrl = TextEditingController();
  final correctCtrl = TextEditingController();
  final choicesCtrl = TextEditingController();
  String type = 'mcq';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recitation Question')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: questionCtrl, decoration: const InputDecoration(labelText: 'Question')),
            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'mcq', child: Text('Multiple Choice')),
                DropdownMenuItem(value: 'text', child: Text('Text / Essay')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            if (type == 'mcq')
              TextField(
                controller: choicesCtrl,
                decoration: const InputDecoration(labelText: 'Choices (comma separated)'),
              ),
            TextField(
              controller: correctCtrl,
              decoration: const InputDecoration(labelText: 'Correct Answer'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                await service.createQuestion(
                  assignmentId: widget.assignmentId,
                  question: questionCtrl.text,
                  type: type,
                  choices: type == 'mcq'
                      ? choicesCtrl.text.split(',').map((e) => e.trim()).toList()
                      : null,
                  correctAnswer: correctCtrl.text,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
