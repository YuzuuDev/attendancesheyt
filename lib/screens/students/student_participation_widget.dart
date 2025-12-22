import 'package:flutter/material.dart';
import '../../services/participation_service.dart';
import '../../supabase_client.dart';

class StudentParticipationWidget extends StatefulWidget {
  @override
  State<StudentParticipationWidget> createState() =>
      _StudentParticipationWidgetState();
}

class _StudentParticipationWidgetState
    extends State<StudentParticipationWidget> {
  final ParticipationService service = ParticipationService();
  int points = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = SupabaseClientInstance.supabase.auth.currentUser!.id;
    points = await service.getStudentPoints(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text("Participation Points"),
        trailing: Text(
          points.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
