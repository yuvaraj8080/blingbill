import 'package:blingbill/app/constants/app_constants.dart';
import 'package:blingbill/app/modules/billing/views/billing_history_view.dart';
import 'package:blingbill/app/modules/dashboard/views/dashboard_view.dart';
import 'package:blingbill/app/modules/product/views/product_list_view.dart';
import 'package:blingbill/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _currentIndex = 0;
  String? categoryFilter;
  DateTime? startDate;
  DateTime? endDate;

  final List<Widget> _screens = [const DashboardView(), const ProductListView(), const BillingHistoryView()];

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton:
          _currentIndex == 1
              ? FloatingActionButton(
                onPressed: () => Get.toNamed(Routes.PRODUCT_FORM),
                backgroundColor: AppConstants.primaryColor,
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppConstants.darkCardColor : AppConstants.lightCardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeRadius),
            topRight: Radius.circular(AppConstants.largeRadius),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeRadius),
            topRight: Radius.circular(AppConstants.largeRadius),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: changePage,
            backgroundColor: isDarkMode ? AppConstants.darkCardColor : AppConstants.lightCardColor,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: isDarkMode ? AppConstants.textLight.withOpacity(0.5) : AppConstants.textMedium,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_rounded),
                activeIcon: Icon(Icons.receipt_rounded),
                label: 'Bills',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
