import 'package:blingbill/app/routes/app_pages.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/bill_item_model.dart';
import '../../../data/models/product_model.dart';
import '../controllers/billing_controller.dart';

class BillingView extends GetView<BillingController> {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final surfaceColor = isDarkMode ? AppConstants.darkSurfaceColor : Colors.grey.shade50;
    final cardColor = isDarkMode ? AppConstants.darkCardColor : Colors.white;

    // Enhanced colors
    final accentColor = isDarkMode ? Colors.tealAccent.shade400 : Colors.teal;
    final headingStyle = GoogleFonts.poppins(fontWeight: FontWeight.w600);
    final subtitleStyle = GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 3, color: accentColor)),
                const SizedBox(height: 24),
                Text("Loading products...", style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
          ),
        );
      }

      if (controller.availableProducts.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Create Bill', style: headingStyle),
            centerTitle: true,
            elevation: isDarkMode ? 0 : 2,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 100,
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                const SizedBox(height: 32),
                Text('No products available', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Please add products before creating a bill',
                    textAlign: TextAlign.center,
                    style: subtitleStyle.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('Add Products', style: GoogleFonts.poppins(fontSize: 16)),
                  onPressed: () => Get.toNamed(Routes.PRODUCT_FORM),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                    backgroundColor: accentColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Create Bill', style: headingStyle),
          centerTitle: true,
          elevation: isDarkMode ? 0 : 1,
          actions: [
            Tooltip(
              message: 'Reset Form',
              child: IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: controller.clearBill),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient:
                    isDarkMode
                        ? null
                        : LinearGradient(
                          colors: [Colors.grey.shade50, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
              ),
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      children: [
                        // Customer Information Card
                        _buildSectionCard(
                          context,
                          title: 'Customer Information',
                          icon: Icons.person,
                          iconColor: primaryColor,
                          cardColor: cardColor,
                          isDarkMode: isDarkMode,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: controller.customerNameController,
                                style: GoogleFonts.inter(),
                                decoration: InputDecoration(
                                  hintText: 'Enter customer name',
                                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                  ),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: surfaceColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: controller.selectedPaymentMethod.value,
                                style: GoogleFonts.inter(),
                                decoration: InputDecoration(
                                  labelText: 'Payment Method',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                  ),
                                  prefixIcon: const Icon(Icons.payment),
                                  filled: true,
                                  fillColor: surfaceColor,
                                ),
                                items:
                                    AppConstants.paymentMethods
                                        .map(
                                          (method) => DropdownMenuItem(
                                            value: method,
                                            child: Text(method, style: GoogleFonts.inter()),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  if (value != null) controller.selectedPaymentMethod.value = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Product Selection Card
                        _buildSectionCard(
                          context,
                          title: 'Add Products',
                          icon: Icons.shopping_cart,
                          iconColor: secondaryColor,
                          cardColor: cardColor,
                          isDarkMode: isDarkMode,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Dropdown
                              DropdownButtonFormField<Product>(
                                value: controller.selectedProduct.value,
                                isExpanded: true,
                                style: GoogleFonts.inter(),
                                decoration: InputDecoration(
                                  labelText: 'Select Product',
                                  labelStyle: GoogleFonts.inter(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                  ),
                                  prefixIcon: const Icon(Icons.inventory),
                                  filled: true,
                                  fillColor: surfaceColor,
                                ),
                                dropdownColor: cardColor,
                                items:
                                    controller.availableProducts
                                        .map(
                                          (product) => DropdownMenuItem<Product>(
                                            value: product,
                                            child: Text(
                                              '${product.name} - ${currencyFormat.format(product.price)}',
                                              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: controller.updateSelectedProduct,
                              ),
                              const SizedBox(height: 24),

                              // Quantity selection
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                  border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildQuantityButton(
                                          onTap: controller.decrementQuantity,
                                          icon: Icons.remove,
                                          color: primaryColor,
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Obx(
                                              () => Text(
                                                controller.quantity.value.toString(),
                                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        _buildQuantityButton(
                                          onTap: controller.incrementQuantity,
                                          icon: Icons.add,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Add to bill button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: controller.addItemToBill,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: Text('Add to Bill', style: GoogleFonts.poppins(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: secondaryColor,
                                    elevation: isDarkMode ? 0 : 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Bill Items Section
                        Obx(() {
                          if (controller.billItems.isEmpty) {
                            return _buildEmptyBillState(surfaceColor, isDarkMode);
                          }

                          return _buildSectionCard(
                            context,
                            title: 'Bill Summary',
                            icon: Icons.receipt,
                            iconColor: primaryColor,
                            cardColor: cardColor,
                            isDarkMode: isDarkMode,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Clear all items',
                                onPressed: () => _showClearBillDialog(context, isDarkMode),
                              ),
                            ],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bill items
                                ...controller.billItems.asMap().entries.map(
                                  (entry) =>
                                      _buildBillItem(entry.value, entry.key, currencyFormat, isDarkMode, context),
                                ),

                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),

                                // Global discount and tax
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        controller: controller.globalDiscountController,
                                        label: 'Discount %',
                                        suffix: '%',
                                        surfaceColor: surfaceColor,
                                        onChanged: controller.updateGlobalDiscount,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        controller: controller.globalTaxController,
                                        label: 'Tax %',
                                        suffix: '%',
                                        surfaceColor: surfaceColor,
                                        onChanged: controller.updateGlobalTax,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Bill totals
                                _buildBillTotalsContainer(
                                  isDarkMode: isDarkMode,
                                  surfaceColor: surfaceColor,
                                  currencyFormat: currencyFormat,
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Bottom action bar
                  Obx(
                    () =>
                        controller.billItems.isNotEmpty
                            ? _buildBottomActionBar(
                              isDarkMode: isDarkMode,
                              cardColor: cardColor,
                              primaryColor: primaryColor,
                              currencyFormat: currencyFormat,
                            )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),
            // Confetti effect
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: controller.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 50,
                gravity: 0.2,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Enhanced UI Components

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required bool isDarkMode,
    required Widget child,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: cardColor,
      shadowColor: iconColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (actions != null) ...actions,
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required VoidCallback onTap, required IconData icon, required Color color}) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(padding: const EdgeInsets.all(16), child: Icon(icon, color: color, size: 24)),
      ),
    );
  }

  Widget _buildEmptyBillState(Color surfaceColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No items added to bill yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select products and add them to your bill',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required Color surfaceColor,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: surfaceColor,
        suffixText: suffix,
        suffixStyle: GoogleFonts.inter(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildBillTotalsContainer({
    required bool isDarkMode,
    required Color surfaceColor,
    required NumberFormat currencyFormat,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', controller.subTotal.value, currencyFormat, isDarkMode, false),
          const SizedBox(height: 10),
          _buildTotalRow('Discount', controller.discountAmount.value, currencyFormat, isDarkMode, true),
          const SizedBox(height: 10),
          _buildTotalRow('Tax', controller.taxAmount.value, currencyFormat, isDarkMode, false),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          _buildTotalRow('Total', controller.totalAmount.value, currencyFormat, isDarkMode, false, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar({
    required bool isDarkMode,
    required Color cardColor,
    required Color primaryColor,
    required NumberFormat currencyFormat,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
        ],
        border: Border(top: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormat.format(controller.totalAmount.value),
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            width: 160,
            child: ElevatedButton.icon(
              onPressed: () {
                if (controller.customerNameController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Validation Error',
                    'Please enter customer name before creating the bill',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    borderRadius: 10,
                    margin: const EdgeInsets.all(10),
                  );
                  return;
                }
                controller.saveBill();
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text('Create Bill', style: GoogleFonts.poppins(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                elevation: isDarkMode ? 0 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearBillDialog(BuildContext context, bool isDarkMode) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Bill', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove all items from this bill?', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel', style: GoogleFonts.inter())),
          ElevatedButton(
            onPressed: () {
              Get.back();

              controller.clearBillItems();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: Text('Clear', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(BillItem item, int index, NumberFormat formatter, bool isDarkMode, BuildContext context) {
    final bool hasDiscount = item.discount != null && item.discount! > 0;
    final bool hasTax = item.tax != null && item.tax! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.red.shade400, size: 20),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () => controller.removeItemFromBill(index),
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatter.format(item.price)} × ${item.quantity}',
                style: GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 14),
              ),
              Text(
                formatter.format(item.totalAmount),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (hasDiscount || hasTax) const SizedBox(height: 8),
          if (hasDiscount || hasTax)
            Row(
              children: [
                if (hasDiscount)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Discount: ${item.discount}%',
                      style: GoogleFonts.inter(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (hasDiscount && hasTax) const SizedBox(width: 8),
                if (hasTax)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tax: ${item.tax}%',
                      style: GoogleFonts.inter(
                        color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    NumberFormat formatter,
    bool isDarkMode,
    bool isNegative, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            isNegative ? '- ${formatter.format(amount)}' : formatter.format(amount),
            style: GoogleFonts.poppins(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color:
                  isNegative
                      ? Colors.red
                      : isTotal
                      ? isDarkMode
                          ? Colors.white
                          : Colors.black
                      : isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
