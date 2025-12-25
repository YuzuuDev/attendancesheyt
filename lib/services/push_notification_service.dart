import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    final token = await _firebaseMessaging.getToken();
    if (token == null) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('profiles')
        .update({'fcm_token': token})
        .eq('id', userId);
  }
}
