import 'package:get/get.dart';

import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../controllers/recipe_controller.dart';

class RecipeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecipeRemoteDataSource>(
      () => RecipeRemoteDataSource(),
      fenix: true,
    );

    Get.lazyPut<RecipeRepository>(
      () => RecipeRepositoryImpl(remote: Get.find<RecipeRemoteDataSource>()),
      fenix: true,
    );

    Get.put<RecipeController>(
      RecipeController(repository: Get.find<RecipeRepository>()),
      permanent: true,
    );
  }
}