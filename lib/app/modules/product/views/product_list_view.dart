import 'dart:io';

import 'package:blingbill/app/data/models/product_model.dart';
import 'package:blingbill/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../controllers/product_controller.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Widget content = Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              hintStyle: GoogleFonts.inter(),
            ),
            style: GoogleFonts.inter(),
            onChanged: controller.searchProducts,
          ),
        ),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Row(
            children: [
              Obx(
                () => FilterChip(
                  label: Text('All', style: GoogleFonts.inter()),
                  selected: controller.categoryFilter.value == null,
                  onSelected: (_) => controller.filterByCategory(null),
                ),
              ),
              const SizedBox(width: 8),
              ...AppConstants.jewelryCategories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(
                    () => FilterChip(
                      label: Text(category, style: GoogleFonts.inter()),
                      selected: controller.categoryFilter.value == category,
                      onSelected: (_) => controller.filterByCategory(category),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Product List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No products found', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first product by tapping the + button',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: controller.products.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return ProductListItem(
                  controller: controller,
                  isDarkMode: isDarkMode,
                  product: product,
                  currencyFormat: currencyFormat,
                  onEdit: () => controller.navigateToEdit(product),
                  onDelete: () => _confirmDelete(context, product),
                );
              },
            );
          }),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('Products', style: GoogleFonts.inter())),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.PRODUCT_FORM),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.deleteProduct(product.id!);
                },
                child: const Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
              ),
            ],
          ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final ProductController controller;
  final bool isDarkMode;
  final Product product;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
    required this.isDarkMode,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            NumberFormat.currency(symbol: '₹').format(product.price),
            style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppConstants.successColor),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppConstants.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: AppConstants.bodyStyle.copyWith(
                            color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text('Delete', style: AppConstants.bodyStyle.copyWith(color: Colors.red.shade400)),
                      ],
                    ),
                  ),
                ],
            onSelected: (String value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            color: isDarkMode ? AppConstants.darkCardColor : AppConstants.lightCardColor,
          ),
        ],
      ),
    );
  }
}