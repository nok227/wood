import 'package:get/get.dart';

import 'package:wood/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wood/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wood/features/auth/presentation/controllers/auth_controller.dart';

import 'package:wood/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:wood/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:wood/features/notifications/presentation/controllers/notification_controller.dart';

import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';

import 'package:wood/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:wood/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:wood/features/sales/presentation/controllers/sales_controller.dart';

import 'package:wood/features/account/data/datasources/account_remote_data_source.dart';
import 'package:wood/features/account/data/repositories/account_repository_impl.dart';
import 'package:wood/features/account/presentation/controllers/account_controller.dart';

import 'package:wood/features/recipe/data/datasources/recipe_remote_data_source.dart';
import 'package:wood/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:wood/features/recipe/presentation/controllers/recipe_controller.dart';

class ControllerBootstrap {
  ControllerBootstrap._();

  static void init() {
    // Permanent
    Get.put(
      AuthController(
        authRepository: AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSource(),
        ),
      ),
      permanent: true,
    );

    Get.put(
      NotificationController(
        repository: NotificationRepositoryImpl(
          remote: NotificationRemoteDataSource(),
        ),
      ),
      permanent: true,
    );

    Get.put(
      AccountController(
        repository: AccountRepositoryImpl(
          remoteDataSource: AccountRemoteDataSource(),
        ),
      ),
      permanent: true,
    );

    Get.put(
      RecipeController(
        repository: RecipeRepositoryImpl(remote: RecipeRemoteDataSource()),
      ),
      permanent: true,
    );

    // Lazy
    Get.lazyPut(() => WoodProductController(), fenix: true);

    Get.lazyPut(
      () => SalesController(
        repository: SalesRepositoryImpl(
          remoteDataSource: SalesRemoteDataSource(),
        ),
      ),
      fenix: true,
    );
  }
}