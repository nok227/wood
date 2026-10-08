import 'package:get/get.dart';

import '../../data/datasources/account_remote_data_source.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../controllers/account_controller.dart';
import '../controllers/account_header_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    // ── Data ──
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSource(),
      fenix: true,
    );

    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
      fenix: true,
    );

    // ── Controllers ──
    Get.put<AccountController>(
      AccountController(repository: Get.find<AccountRepository>()),
      permanent: true,
    );

    Get.lazyPut<AccountHeaderController>(
      () => AccountHeaderController(),
      fenix: true,
    );
  }
}