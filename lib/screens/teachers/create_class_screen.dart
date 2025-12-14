import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';

class CreateClassScreen extends StatefulWidget {
  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final TextEditingController nameController = TextEditingController();
  final ClassService classService = ClassService();
  bool isLoading = false;

  void _createClass() async {
    setState(() => isLoading = true);

    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final code = await classService.createClass(nameController.text, teacherId);

    setState(() => isLoading = false);

    if (code != null && code.length == 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Class created! Code: $code")));
      nameController.clear();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(code ?? "Error creating class")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Class")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Class Name"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _createClass, child: Text("Create Class")),
          ],
        ),
      ),
    );
  }
}
