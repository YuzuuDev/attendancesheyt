import 'package:flutter/material.dart';
import '../../services/recitation_service.dart';

class CreateRecitationQuestionScreen extends StatefulWidget {
  final String assignmentId;

  const CreateRecitationQuestionScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<CreateRecitationQuestionScreen> createState() =>
      _CreateRecitationQuestionScreenState();
}

class _CreateRecitationQuestionScreenState
    extends State<CreateRecitationQuestionScreen> {
  final service = RecitationService();
  final qCtrl = TextEditingController();
  final aCtrl = TextEditingController();
  final pointsCtrl = TextEditingController(text: "1");
  String type = 'text';
  List<TextEditingController> choices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Recitation Question")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: qCtrl,
              decoration: const InputDecoration(labelText: "Question"),
            ),

            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text')),
                DropdownMenuItem(value: 'mcq', child: Text('Multiple Choice')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),

            if (type == 'mcq')
              ...choices.map((c) => TextField(
                    controller: c,
                    decoration:
                        const InputDecoration(labelText: "Choice"),
                  )),

            if (type == 'mcq')
              TextButton(
                onPressed: () =>
                    setState(() => choices.add(TextEditingController())),
                child: const Text("Add Choice"),
              ),

            TextField(
              controller: aCtrl,
              decoration:
                  const InputDecoration(labelText: "Correct Answer"),
            ),
            TextField(
              controller: pointsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Points"),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await service.addQuestion(
                  assignmentId: widget.assignmentId,
                  question: qCtrl.text,
                  questionType: type,
                  correctAnswer: aCtrl.text,
                  points: int.parse(pointsCtrl.text),
                  choices:
                      type == 'mcq' ? choices.map((c) => c.text).toList() : null,
                );
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
