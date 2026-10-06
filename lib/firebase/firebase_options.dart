import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError('Platform not supported');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJBx_A7Qw3LxdQnt206IrDgGMcRJ8rYKo', 
    appId: '1:209414153146:android:32072fd8a8e2532d0e3383', 
    messagingSenderId: '209414153146',
    projectId: 'wood-4f334',
    storageBucket: 'wood-4f334.appspot.com',
  );
}