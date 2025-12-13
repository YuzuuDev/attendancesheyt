import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientInstance {
  static final supabase = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  }
}
