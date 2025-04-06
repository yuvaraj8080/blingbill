import 'package:get/get.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/database_service.dart';

class DashboardController extends GetxController {
  final RxBool isLoading = true.obs;

  // Product stats
  final RxInt totalProducts = 0.obs;
  final RxList<Product> recentProducts = <Product>[].obs;

  // Bill stats
  final RxInt totalBills = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxList<Bill> recentBills = <Bill>[].obs;

  // Today's stats
  final RxDouble todayRevenue = 0.0.obs;
  final RxInt todayBillsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadProducts(), _loadBills(), _loadTodayStats()]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh dashboard: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await DatabaseService.to.getAllProducts();
      totalProducts.value = products.length;
      recentProducts.value = products.take(5).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadBills() async {
    try {
      final bills = await DatabaseService.to.getAllBills();
      totalBills.value = bills.length;
      recentBills.value = bills.take(5).toList();
      totalRevenue.value = bills.fold(0, (sum, bill) => sum + (bill.totalAmount ?? 0));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bills: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadTodayStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final todayBills = await DatabaseService.to.getBillsByDateRange(startOfDay, endOfDay);
      todayBillsCount.value = todayBills.length;
      todayRevenue.value = todayBills.fold(0, (sum, bill) => sum + (bill.totalAmount));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load today\'s stats: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}