import 'package:get/get.dart';
import 'package:wood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wood/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wood/features/auth/domain/repositories/auth_repository.dart';
import 'package:wood/features/auth/presentation/controllers/admin_users_controller.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wood/features/auth/presentation/controllers/auth_form_controller.dart';


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