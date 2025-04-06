import 'dart:io';

import 'package:blingbill/app/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/product_model.dart';
import '../../../global_widgets/dashboard_card.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    // layouts
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 900;
    final int gridColumns = isLargeScreen ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(Get.find<ThemeController>().themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            ),
            onPressed: () {
              Get.find<ThemeController>().toggleTheme();
            },
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppConstants.primaryColor,
          backgroundColor: isDarkMode ? AppConstants.darkCardColor : AppConstants.lightCardColor,
          child: ListView(
            padding: EdgeInsets.all(isTablet ? AppConstants.spacing_l : AppConstants.spacing_m),
            children: [
              // Welcome Section
              _buildWelcomeSection(context, isDarkMode, isTablet),
              SizedBox(height: isTablet ? AppConstants.spacing_l : AppConstants.spacing_m),

              // Stats Grid
              _buildStatsGrid(
                context,
                isDarkMode,
                currencyFormat,
                AppConstants.primaryColor,
                AppConstants.secondaryColor,
                gridColumns,
              ),
              SizedBox(height: isTablet ? AppConstants.spacing_xl : AppConstants.spacing_l),

              // Quick Actions
              _buildQuickActions(context, isDarkMode, AppConstants.primaryColor, isTablet),
              SizedBox(height: isTablet ? AppConstants.spacing_xl : AppConstants.spacing_l),

              // Recent Products & Bills
              if (isLargeScreen)
                _buildHorizontalSections(context, isDarkMode, currencyFormat)
              else
                _buildVerticalSections(context, isDarkMode, currencyFormat),

              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDarkMode, bool isTablet) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? AppConstants.spacing_l : AppConstants.spacing_m),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: AppConstants.headingStyle.copyWith(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing_xxs),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: AppConstants.bodyStyle.copyWith(
                      fontSize: isTablet ? 16 : 14,
                      color: isDarkMode ? AppConstants.textLight.withOpacity(0.7) : AppConstants.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing_m),
                  Text(
                    'Track your business performance and create bills for your customers.',
                    style: AppConstants.bodyStyle.copyWith(
                      fontSize: isTablet ? 16 : 14,
                      color: isDarkMode ? AppConstants.textLight.withOpacity(0.8) : AppConstants.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (isTablet)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.analytics_outlined, size: 40, color: AppConstants.primaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    bool isDarkMode,
    NumberFormat currencyFormat,
    Color primaryColor,
    Color secondaryColor,
    int columns,
  ) {
    // Determine if it's a mobile screen for adjusting card height
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width <= 600;

    return Obx(() {
      return GridView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppConstants.spacing_m,
          mainAxisSpacing: AppConstants.spacing_m,
          childAspectRatio: isMobile ? 1.5 : 1.8, // Lower ratio for more height
        ),
        children: [
          // Total Revenue
          DashboardCard(
            isDarkMode: isDarkMode,
            title: 'Total Revenue',
            icon: Icons.account_balance_wallet,
            iconColor: AppConstants.successColor,
            backgroundColor: AppConstants.successColor.withOpacity(0.1),
            value: currencyFormat.format(controller.totalRevenue.value),
            subtitle: 'All time sales',
          ),

          // Products Count
          DashboardCard(
            isDarkMode: isDarkMode,
            title: 'Products',
            icon: Icons.inventory,
            iconColor: AppConstants.accentColor,
            backgroundColor: AppConstants.accentColor.withOpacity(0.1),
            value: controller.totalProducts.value.toString(),
            subtitle: 'Total products',
          ),

          // Today's Revenue
          DashboardCard(
            title: 'Today\'s Sales',
            icon: Icons.today,
            iconColor: AppConstants.successColor,
            backgroundColor: AppConstants.successColor.withOpacity(0.1),
            value: currencyFormat.format(controller.todayRevenue.value),
            subtitle: '${controller.todayBillsCount.value} bills',
            isDarkMode: isDarkMode,
          ),

          // Only add the Bills Count card for larger screens
          if (columns >= 3)
            DashboardCard(
              isDarkMode: isDarkMode,
              title: 'Total Bills',
              icon: Icons.receipt_long,
              iconColor: AppConstants.warningColor,
              backgroundColor: AppConstants.warningColor.withOpacity(0.1),
              value: controller.totalBills.value.toString(),
              subtitle: 'Lifetime bills',
            ),
        ],
      );
    });
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode, Color primaryColor, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppConstants.headingStyle.copyWith(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
          ),
        ),
        const SizedBox(height: AppConstants.spacing_m),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.add_shopping_cart,
                label: 'New Bill',
                onTap: () => Get.toNamed(Routes.BILLING),
                color: AppConstants.successColor,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: isTablet ? AppConstants.spacing_m : AppConstants.spacing_xs),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.add_circle_outline,
                label: 'Add Product',
                onTap: () => Get.toNamed(Routes.PRODUCT_FORM),
                color: AppConstants.primaryColor,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: isTablet ? AppConstants.spacing_m : AppConstants.spacing_xs),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.receipt_long,
                label: 'History',
                onTap: () => Get.toNamed(Routes.BILLING_HISTORY),
                color: AppConstants.accentColor,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: isTablet ? AppConstants.spacing_m : AppConstants.spacing_xs),
            Expanded(
              child: _buildActionButton(
                context: context,
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                onTap: () => Get.toNamed(Routes.PRODUCTS),
                color: AppConstants.secondaryColor,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Function() onTap,
    required Color color,
    required bool isDarkMode,
  }) {
    return Material(
      color: isDarkMode ? AppConstants.darkCardColor : AppConstants.lightCardColor,
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing_xs, vertical: AppConstants.spacing_m),
          decoration: BoxDecoration(
            border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing_xs),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: AppConstants.spacing_xs),
              Text(
                label,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSections(BuildContext context, bool isDarkMode, NumberFormat currencyFormat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Recent Products', 'View All', () => Get.toNamed(Routes.PRODUCTS)),
              const SizedBox(height: 12),
              _buildRecentProductsList(context, isDarkMode),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Recent Bills', 'View All', () => Get.toNamed(Routes.BILLING_HISTORY)),
              const SizedBox(height: 12),
              _buildRecentBillsList(context, isDarkMode, currencyFormat),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalSections(BuildContext context, bool isDarkMode, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Products', 'View All', () => Get.toNamed(Routes.PRODUCTS)),
        const SizedBox(height: 12),
        _buildRecentProductsList(context, isDarkMode),
        const SizedBox(height: 24),
        _buildSectionTitle('Recent Bills', 'View All', () => Get.toNamed(Routes.BILLING_HISTORY)),
        const SizedBox(height: 12),
        _buildRecentBillsList(context, isDarkMode, currencyFormat),
      ],
    );
  }

  Widget _buildRecentProductsList(BuildContext context, bool isDarkMode) {
    return Obx(() {
      final products = controller.recentProducts;

      if (products.isEmpty) {
        return _buildEmptyState(
          'No products added yet',
          'Add your first product to see it here',
          Icons.inventory_2_outlined,
          () => Get.toNamed(Routes.PRODUCT_FORM, arguments: products),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length > 5 ? 5 : products.length,
        itemBuilder: (_, index) {
          final product = products[index];
          return _buildProductItem(context, product, index, isDarkMode);
        },
      );
    });
  }

  Widget _buildRecentBillsList(BuildContext context, bool isDarkMode, NumberFormat currencyFormat) {
    return Obx(() {
      final bills = controller.recentBills;

      if (bills.isEmpty) {
        return _buildEmptyState(
          'No bills created yet',
          'Create your first bill to see it here',
          Icons.receipt_long,
          () => Get.toNamed(Routes.BILLING),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bills.length > 5 ? 5 : bills.length,
        itemBuilder: (_, index) {
          final bill = bills[index];
          return _buildBillItem(context, bill, isDarkMode, currencyFormat);
        },
      );
    });
  }

  Widget _buildSectionTitle(String title, String actionLabel, Function() onTap) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppConstants.headingStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
              ),
            ),
            TextButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.arrow_forward, size: 18, color: AppConstants.primaryColor),
              label: Text(actionLabel, style: AppConstants.bodyStyle.copyWith(color: AppConstants.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductItem(BuildContext context, Product product, int index, bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child:
            product.imagePath != null && product.imagePath!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  child: Image.file(File(product.imagePath!), fit: BoxFit.cover),
                )
                : Icon(Icons.inventory_2, color: AppConstants.primaryColor),
      ),
      title: Text(
        product.name,
        style: AppConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
        ),
      ),
      subtitle: Text(
        product.category,
        style: AppConstants.bodyStyle.copyWith(
          fontSize: 12,
          color: isDarkMode ? AppConstants.textLight.withOpacity(0.7) : AppConstants.textMedium.withOpacity(0.7),
        ),
      ),
      trailing: Text(
        NumberFormat.currency(symbol: '₹').format(product.price),
        style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppConstants.successColor),
      ),
      onTap: () => Get.toNamed(Routes.PRODUCT_FORM, arguments: product),
    );
  }

  Widget _buildBillItem(BuildContext context, Bill bill, bool isDarkMode, NumberFormat currencyFormat) {
    final formatter = DateFormat('dd MMM \'yy, hh:mm a');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppConstants.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        child: Icon(Icons.receipt, color: AppConstants.successColor),
      ),
      title: Text(
        bill.customerName,
        style: AppConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
        ),
      ),
      subtitle: Text(
        formatter.format(bill.date),
        style: AppConstants.bodyStyle.copyWith(
          fontSize: 12,
          color: isDarkMode ? AppConstants.textLight.withOpacity(0.7) : AppConstants.textMedium.withOpacity(0.7),
        ),
      ),
      trailing: Text(
        currencyFormat.format(bill.totalAmount),
        style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppConstants.successColor),
      ),
      onTap: () => Get.toNamed(Routes.BILLING_DETAIL, arguments: bill),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Function() onTap) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacing_l),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: isDarkMode ? AppConstants.textLight.withOpacity(0.5) : AppConstants.textDark.withOpacity(0.5),
              ),
              const SizedBox(height: AppConstants.spacing_m),
              Text(
                title,
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                ),
              ),
              const SizedBox(height: AppConstants.spacing_xs),
              Text(
                subtitle,
                style: AppConstants.bodyStyle.copyWith(
                  fontSize: 14,
                  color:
                      isDarkMode ? AppConstants.textLight.withOpacity(0.7) : AppConstants.textMedium.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacing_m),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.textLight,
                ),
                onPressed: onTap,
                child: Text(
                  'Add',
                  style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppConstants.textLight),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
