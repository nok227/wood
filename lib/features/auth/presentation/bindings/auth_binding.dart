import 'package:get/get.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/admin_users_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_form_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ── Data ──
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
      ),
      fenix: true,
    );

    // ── Controllers ──
    Get.put<AuthController>(
      AuthController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );

    // ⭐ เปลี่ยนจาก lazyPut(fenix) → put(permanent)
    Get.put<AuthFormController>(
      AuthFormController(),
      permanent: true,
    );

    Get.lazyPut<AdminUsersController>(
      () => AdminUsersController(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );
  }
}