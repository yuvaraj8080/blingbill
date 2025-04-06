import 'package:blingbill/app/modules/splash/views/splash_view.dart';
import 'package:get/get.dart';

import '../modules/billing/bindings/billing_binding.dart';
import '../modules/billing/views/bill_detail_view.dart';
import '../modules/billing/views/billing_history_view.dart';
import '../modules/billing/views/billing_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/product/bindings/product_binding.dart';
import '../modules/product/views/product_form_view.dart';
import '../modules/product/views/product_list_view.dart';

abstract class Routes {
  static const INITIAL = '/';
  static const DASHBOARD = '/dashboard';
  static const PRODUCTS = '/products';
  static const PRODUCT_FORM = '/product-form';
  static const BILLING = '/billing';
  static const BILLING_HISTORY = '/billing-history';
  static const BILLING_DETAIL = '/billing-detail';
  static const LOGIN = '/login';
}

class AppPages {
  static final pages = [
    GetPage(name: Routes.INITIAL, page: () => const SplashView(), binding: DashboardBinding()),
    GetPage(name: Routes.DASHBOARD, page: () => const DashboardView(), binding: DashboardBinding()),
    GetPage(name: Routes.PRODUCTS, page: () => const ProductListView(), binding: ProductBinding()),
    GetPage(name: Routes.PRODUCT_FORM, page: () => const ProductFormView(), binding: ProductBinding()),
    GetPage(name: Routes.BILLING, page: () => const BillingView(), binding: BillingBinding()),
    GetPage(name: Routes.BILLING_HISTORY, page: () => const BillingHistoryView(), binding: BillingBinding()),
    GetPage(name: Routes.BILLING_DETAIL, page: () => const BillDetailView(), binding: BillingBinding()),
  ];
}
