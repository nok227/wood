import 'package:get/get.dart';

import '../../data/datasources/sales_remote_data_source.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/repositories/sales_repository.dart';
import '../controllers/sales_controller.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesRemoteDataSource>(
      () => SalesRemoteDataSource(),
      fenix: true,
    );

    Get.lazyPut<SalesRepository>(
      () => SalesRepositoryImpl(
        remoteDataSource: Get.find<SalesRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.put<SalesController>(
      SalesController(repository: Get.find<SalesRepository>()),
      permanent: true,
    );
  }
}