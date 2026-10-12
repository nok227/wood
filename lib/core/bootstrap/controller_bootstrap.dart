import 'package:get/get.dart';

import 'package:wood/core/theme/app_color_service.dart';   // ⭐ ใหม่
import 'package:wood/features/account/presentation/bindings/account_binding.dart';
import 'package:wood/features/auth/presentation/bindings/auth_binding.dart';
import 'package:wood/features/notifications/presentation/bindings/notification_binding.dart';
import 'package:wood/features/recipe/presentation/bindings/recipe_binding.dart';
import 'package:wood/features/sales/presentation/bindings/sales_binding.dart';

import 'package:wood/features/wood_products/data/datasources/wood_remote_data_source.dart';
import 'package:wood/features/wood_products/data/repositories/wood_repository_impl.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';

class ControllerBootstrap {
  ControllerBootstrap._();

  static void init() {
    // ⭐ Theme service (permanent)
    Get.put<AppColorService>(AppColorService(), permanent: true);

    AuthBinding().dependencies();
    AccountBinding().dependencies();
    NotificationBinding().dependencies();
    RecipeBinding().dependencies();
    SalesBinding().dependencies();

    Get.lazyPut(
      () => WoodProductController(
        repository: WoodRepositoryImpl(
          remoteDataSource: WoodRemoteDataSource(),
        ),
      ),
      fenix: true,
    );
  }
}