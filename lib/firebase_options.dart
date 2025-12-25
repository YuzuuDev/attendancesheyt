import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqmIH3nH-m8Zw9r8T5q0vP4G1CLU8Wlds',
    appId: '1:126071149590:android:90513b086053ceb326d137',
    messagingSenderId: '126071149590',
    projectId: 'attendancethings',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqmIH3nH-m8Zw9r8T5q0vP4G1CLU8Wlds',
    appId: '1:126071149590:android:90513b086053ceb326d137',
    messagingSenderId: '126071149590',
    projectId: 'attendancethings',
    iosBundleId: 'XXX',
  );
}
