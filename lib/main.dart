import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:wood/core/bootstrap/controller_bootstrap.dart';
import 'package:wood/core/bootstrap/firebase_bootstrap.dart';
import 'package:wood/core/bootstrap/foreground_bootstrap.dart';
import 'package:wood/core/bootstrap/onesignal_bootstrap.dart';
import 'package:wood/core/utils/page_route_notifier.dart';
import 'package:wood/core/theme/app_theme.dart';

import 'package:wood/features/home/presentation/pages/home_shell.dart';
import 'package:wood/features/auth/presentation/pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseError = await FirebaseBootstrap.init();

  if (firebaseError == null) {
    await OneSignalBootstrap.init();
    await ForegroundBootstrap.init();
  }

  ControllerBootstrap.init();

  runApp(MyApp(firebaseInitError: firebaseError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseInitError;
  const MyApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wood App',
      theme: AppTheme.light,
      routingCallback: (_) => PageRouteNotifier.instance.bump(),
      home: firebaseInitError != null
          ? FirebaseErrorPage(error: firebaseInitError!)
          : (FirebaseAuth.instance.currentUser != null
              ? const HomeShell()
              : const RegisterPage()),
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  final Object error;
  const FirebaseErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Firebase initialization failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(error.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}