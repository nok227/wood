import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:wood/firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<Object?> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return null;
    } on FirebaseException catch (e, st) {
      if (e.code == 'duplicate-app') {
        debugPrint('Firebase already initialized: ${e.code}');
        return null;
      }
      debugPrint('Firebase init error: $e');
      debugPrint('$st');
      return e;
    } catch (e, st) {
      debugPrint('Firebase init error: $e');
      debugPrint('$st');
      return e;
    }
  }
}