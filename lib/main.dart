import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wood/features/wood_products/data/datasources/sales_remote_data_source.dart';
import 'package:wood/features/wood_products/data/repositories/sales_repository_impl.dart';
import 'package:wood/features/wood_products/presentation/controllers/sales_controller.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';

// 🆕 Account — Clean Architecture
import 'package:wood/features/wood_products/data/datasources/account_remote_data_source.dart';
import 'package:wood/features/wood_products/data/repositories/account_repository_impl.dart';
import 'package:wood/features/wood_products/presentation/controllers/account_controller.dart';

import 'package:wood/firebase_options.dart';
import 'package:wood/features/wood_products/presentation/pages/home_shell.dart';
import 'package:wood/features/auth/auth_remote_data_source.dart';
import 'package:wood/features/auth/auth_repository_impl.dart';
import 'package:wood/features/auth/auth_controller.dart';
import 'package:wood/features/auth/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseInitError;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e, st) {
    if (e.code == 'duplicate-app') {
      debugPrint('Firebase already initialized, skipping: ${e.code}');
    } else {
      debugPrint('Firebase init error: $e');
      debugPrint('$st');
      firebaseInitError = e;
    }
  } catch (e, st) {
    debugPrint('Firebase init error: $e');
    debugPrint('$st');
    firebaseInitError = e;
  }

  // ✅ Inject Controllers เดิม
  Get.put(WoodProductController());

  // ✅ Inject Auth Clean Architecture
  final authRemoteDataSource = AuthRemoteDataSource();
  final authRepository =
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  Get.put(AuthController(authRepository: authRepository));

  // 🛒 Inject Sales Clean Architecture
  final salesRemoteDataSource = SalesRemoteDataSource();
  final salesRepository =
      SalesRepositoryImpl(remoteDataSource: salesRemoteDataSource);
  Get.put(SalesController(repository: salesRepository));

  // 🆕 💰 Inject Account (ບັນຊີ ຮັບ-ຈ່າຍ)
  final accountRemoteDataSource = AccountRemoteDataSource();
  final accountRepository =
      AccountRepositoryImpl(remoteDataSource: accountRemoteDataSource);
  Get.put(
    AccountController(repository: accountRepository),
    permanent: true, // ✅ ບໍ່ dispose — ປ້ອງກັນ error '_dependents.isEmpty'
  );

  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseInitError;

  const MyApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wood App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
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
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Firebase initialization failed',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}