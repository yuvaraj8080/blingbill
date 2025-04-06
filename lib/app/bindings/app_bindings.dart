import 'package:blingbill/app/services/theme_controller.dart';
import 'package:get/get.dart';

import '../data/services/database_service.dart';
import '../data/services/product_service.dart';
import '../modules/billing/controllers/billing_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/product/controllers/product_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
    Get.put(DatabaseService(), permanent: true);
    // Services
    Get.lazyPut<ProductService>(() => ProductService(), fenix: true);
    // Controllers
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<BillingController>(() => BillingController(), fenix: true);
  }
}
