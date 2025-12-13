void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientInstance.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}
