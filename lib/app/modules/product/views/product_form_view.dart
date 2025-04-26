import 'dart:io';

import 'package:blingbill/app/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_constants.dart';
import '../controllers/product_controller.dart';

class ProductFormView extends GetView<ProductController> {
  const ProductFormView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is Product) {
        final product = Get.arguments as Product;
        if (controller.editingProductId.value != product.id) {
          controller.setupForEditing(product);
        }
      }
    });
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditing.value ? 'Edit Product' : 'Add Product', style: GoogleFonts.inter())),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: controller.saveProduct)],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Picker
              Center(child: GestureDetector(onTap: controller.pickImage, child: _buildImagePicker(isDarkMode))),
              const SizedBox(height: 24),

              // Product Name
              Text('Product Name', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(hintText: 'Enter product name'),
              ),
              const SizedBox(height: 16),

              // Product Category
              Text('Category', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCategoryDropdown(isDarkMode),
              const SizedBox(height: 16),

              // Product Price
              Text('Price', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.priceController,
                style: GoogleFonts.inter(),

                decoration: InputDecoration(prefixText: '₹ ', filled: true, hintText: 'Enter product price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Optional Fields Heading
              Text('Optional Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // Discount
              Text('Discount (%)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.discountController,
                decoration: InputDecoration(hintText: 'Enter discount percentage (optional)', suffixText: '%'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Tax
              Text('Tax (%)', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.taxController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(hintText: 'Enter tax percentage (optional)', suffixText: '%'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveProduct,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text(
                    controller.isEditing.value ? 'Update Product' : 'Save Product',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ),
              ),

              if (controller.isEditing.value) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.clearForm,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text('Clear Form', style: GoogleFonts.inter(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImagePicker(bool isDarkMode) {
    return Obx(() {
      if (controller.imagePath.value != null && controller.imagePath.value!.isNotEmpty) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
            image: DecorationImage(image: FileImage(File(controller.imagePath.value!)), fit: BoxFit.cover),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: controller.pickImage),
              ),
            ],
          ),
        );
      }

      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? AppConstants.darkSurfaceColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 50, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500),
            const SizedBox(height: 8),
            Text(
              'Add Image',
              style: GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryDropdown(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.darkSurfaceColor : Colors.grey.shade50,
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedCategory.value,
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black),
            dropdownColor: isDarkMode ? AppConstants.darkCardColor : Colors.white,
            iconEnabledColor: isDarkMode ? Colors.white70 : Colors.black87,
            items:
                AppConstants.productCategory.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedCategory.value = value;
              }
            },
          ),
        ),
      ),
    );
  }
}
