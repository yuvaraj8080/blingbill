import 'package:blingbill/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/database_service.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';

class ProductController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final taxController = TextEditingController();

  // Selected category
  final selectedCategory = AppConstants.jewelryCategories.first.obs;

  // Selected product image
  final imagePath = Rxn<String>();

  // Product list
  final products = <Product>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Editing state
  final isEditing = false.obs;
  final editingProductId = RxnInt();

  // Search query
  final searchQuery = ''.obs;

  // Selected category filter
  final categoryFilter = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Product) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setupForEditing(Get.arguments as Product);
      });
    }
    loadProducts();
  }

  @override
  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    taxController.dispose();
    imagePath.value = null;
    selectedCategory.value = AppConstants.jewelryCategories.first;
    isEditing.value = false;
    editingProductId.value = null;
    searchQuery.value = '';
    categoryFilter.value = null;
    products.clear();
    super.dispose();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    taxController.dispose();
    super.onClose();
  }

  void navigateToEdit(Product product) {
    Get.toNamed(Routes.PRODUCT_FORM, arguments: product);
  }

  // Load all products from the database
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await DatabaseService.to.getAllProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filter products by category
  void filterByCategory(String? category) {
    categoryFilter.value = category;
    if (category != null) {
      loadProductsByCategory(category);
    } else {
      loadProducts();
    }
  }

  // Load products by category
  Future<void> loadProductsByCategory(String category) async {
    isLoading.value = true;
    try {
      products.value = await DatabaseService.to.getProductsByCategory(category);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      // Only category filter is active
      if (categoryFilter.value != null) {
        loadProductsByCategory(categoryFilter.value!);
      } else {
        loadProducts();
      }
      return;
    }

    final baseProducts =
        categoryFilter.value != null ? products.where((p) => p.category == categoryFilter.value).toList() : products;

    final filteredProducts =
        baseProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()) ||
                  product.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    products.assignAll(filteredProducts);
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        imagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    priceController.clear();
    discountController.clear();
    taxController.clear();
    selectedCategory.value = AppConstants.jewelryCategories.first;
    imagePath.value = null;
    isEditing.value = false;
    editingProductId.value = null;
  }

  // Set up form for editing a product
  void setupForEditing(Product product) {
    isEditing.value = true;
    editingProductId.value = product.id;

    nameController.text = product.name;
    priceController.text = product.price.toString();
    selectedCategory.value = product.category;

    discountController.text = product.discount?.toString() ?? '';
    taxController.text = product.tax?.toString() ?? '';

    imagePath.value = product.imagePath;
  }

  // Validate form
  bool validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Product name is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
      return false;
    }

    if (priceController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Product price is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
      return false;
    }

    try {
      double.parse(priceController.text);
    } catch (e) {
      Get.snackbar(
        'Validation Error',
        'Product price must be a valid number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
      return false;
    }

    if (discountController.text.isNotEmpty) {
      try {
        double.parse(discountController.text);
      } catch (e) {
        Get.snackbar(
          'Validation Error',
          'Discount must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          colorText: AppConstants.textLight,
        );
        return false;
      }
    }

    if (taxController.text.isNotEmpty) {
      try {
        double.parse(taxController.text);
      } catch (e) {
        Get.snackbar(
          'Validation Error',
          'Tax must be a valid number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          colorText: AppConstants.textLight,
        );
        return false;
      }
    }

    return true;
  }

  // Save product
  Future<void> saveProduct() async {
    if (!validateForm()) return;

    isLoading.value = true;
    try {
      final product = Product(
        id: isEditing.value ? editingProductId.value : null,
        name: nameController.text.trim(),
        price: double.parse(priceController.text),
        category: selectedCategory.value,
        discount: discountController.text.isEmpty ? null : double.parse(discountController.text),
        tax: taxController.text.isEmpty ? null : double.parse(taxController.text),
        imagePath: imagePath.value,
      );

      String message;
      if (isEditing.value) {
        await DatabaseService.to.updateProduct(product);
        message = AppConstants.productUpdated;
        await loadProducts();
      } else {
        await DatabaseService.to.insertProduct(product);
        message = AppConstants.productAdded;
        await loadProducts();
      }

      // Update the product list
      await loadProducts();

      // Update dashboard if available
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshData();
      }

      // Clear form first
      clearForm();

      // Navigate back
      Get.back();

      // Show the success message AFTER navigation
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.successColor,
        colorText: AppConstants.textLight,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    isLoading.value = true;

    try {
      await DatabaseService.to.deleteProduct(id);
      await loadProducts();

      // Update dashboard if available
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshData();
      }

      Get.snackbar(
        'Success',
        AppConstants.productDeleted,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.successColor,
        colorText: AppConstants.textLight,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
