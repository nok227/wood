import 'package:get/get.dart';

import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSource(),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remote: Get.find<NotificationRemoteDataSource>(),
      ),
      fenix: true,
    );

    // permanent เพราะ feature อื่น (Account, Sales ฯลฯ) push() ข้าม
    Get.put<NotificationController>(
      NotificationController(repository: Get.find<NotificationRepository>()),
      permanent: true,
    );
  }
}