import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_class_screen.dart';

class TeacherDashboard extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher Dashboard')),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => CreateClassScreen())),
              child: Text('Create Class')),
          Expanded(
            child: FutureBuilder(
              future: supabase.from('classes').select().execute(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final classes = snapshot.data as List<dynamic>;
                return ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classData = classes[index];
                    return ListTile(
                      title: Text(classData['class_name']),
                      subtitle: Text('Code: ${classData['class_code']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
