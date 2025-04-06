import 'package:blingbill/app/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/bill_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/billing_controller.dart';

class BillingHistoryView extends GetView<BillingController> {
  const BillingHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.themeMode == ThemeMode.dark; // Reactive theme from ThemeController
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final cardColor = isDarkMode ? AppConstants.darkCardColor : Colors.white;
    final surfaceColor = isDarkMode ? AppConstants.darkSurfaceColor : Colors.grey.shade50;

    if (controller.bills.isEmpty && !controller.isLoading.value) {
      controller.loadBills();
    }

    final Widget content = SafeArea(
      child: Column(
        children: [
          // Search and filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
              border: Border(bottom: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by customer name',
                      hintStyle: GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                      suffixIcon:
                          controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  controller.searchQuery.value = '';
                                  FocusScope.of(context).unfocus();
                                  controller.loadBills();
                                },
                              )
                              : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      constraints: const BoxConstraints(maxHeight: 48),
                    ),
                    style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                      if (value.isNotEmpty) {
                        controller.searchBills(value);
                      } else {
                        controller.loadBills();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),
                // Filter Button
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _showDateFilterDialog(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 20,
                          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active filters
          Obx(() {
            if (controller.startDate.value != null && controller.endDate.value != null) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue.withOpacity(0.15) : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  border: Border.all(color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filtered: ${DateFormat('dd MMM yyyy').format(controller.startDate.value!)} - ${DateFormat('dd MMM yyyy').format(controller.endDate.value!)}',
                        style: GoogleFonts.inter(color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                        size: 18,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: controller.resetDateFilter,
                      tooltip: 'Clear filter',
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Search status text
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty && !controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Search results for "${controller.searchQuery.value}"',
                      style: GoogleFonts.inter(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${controller.bills.length} result${controller.bills.length != 1 ? 's' : ''}',
                      style: GoogleFonts.inter(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Bills list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.bills.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No bills found for "${controller.searchQuery.value}"'
                            : controller.startDate.value != null
                            ? 'No bills found in selected date range'
                            : 'No billing history available',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.searchQuery.value.isNotEmpty || controller.startDate.value != null
                            ? 'Try adjusting your search or filters'
                            : 'Start creating bills to see them here',
                        style: GoogleFonts.inter(
                          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (controller.searchQuery.value.isNotEmpty || controller.startDate.value != null) ...[
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: Text(
                            'Clear Filters',
                            style: GoogleFonts.inter(fontSize: 16, color: AppConstants.textLight),
                          ),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.resetDateFilter();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.bills.length,
                itemBuilder: (context, index) {
                  final bill = controller.bills[index];
                  return _buildBillCard(bill, currencyFormat, dateFormat, context, isDarkMode, cardColor);
                },
              );
            }),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing History',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(child: content),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.BILLING),
        backgroundColor: isDarkMode ? Colors.green.shade700 : Colors.green,
        tooltip: 'Create new bill',
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildBillCard(
    Bill bill,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
    BuildContext context,
    bool isDarkMode,
    Color cardColor,
  ) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(Routes.BILLING_DETAIL, arguments: bill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppConstants.primaryColor.withOpacity(0.2)
                              : AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.receipt, color: AppConstants.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bill.customerName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.green.shade900 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isDarkMode ? Colors.green.shade700 : Colors.green.shade300),
                              ),
                              child: Text(
                                'PAID',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(bill.date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
              const SizedBox(height: 12),

              // Bill details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items & Payment info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Payment', bill.paymentMethod, isDarkMode, Icons.payment),
                        const SizedBox(height: 8),
                        _buildDetailRow('Items', '${bill.items.length}', isDarkMode, Icons.shopping_bag),
                        if (bill.discount > 0) ...[
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Discount',
                            '${bill.discount}%',
                            isDarkMode,
                            Icons.discount,
                            valueColor: Colors.green,
                          ),
                        ],
                        if (bill.tax > 0) ...[
                          const SizedBox(height: 8),
                          _buildDetailRow('Tax', '${bill.tax}%', isDarkMode, Icons.receipt_long),
                        ],
                      ],
                    ),
                  ),

                  // Amount info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(bill.totalAmount),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Get.toNamed(Routes.BILLING_DETAIL, arguments: bill),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(
                          'View',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 13, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? (isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.themeMode == ThemeMode.dark;
    final now = DateTime.now();
    DateTime? startDate = controller.startDate.value;
    DateTime? endDate = controller.endDate.value;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  'Filter by Date Range',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                  ),
                ),
                backgroundColor: isDarkMode ? AppConstants.darkCardColor : Colors.white,
                content: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                        ),
                        title: Text(
                          'Start Date',
                          style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                        ),
                        subtitle: Text(
                          startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : 'Not set',
                          style: GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? now,
                            firstDate: DateTime(now.year - 5),
                            lastDate: now,
                            builder:
                                (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme:
                                        isDarkMode
                                            ? const ColorScheme.dark(
                                              primary: AppConstants.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: AppConstants.darkCardColor,
                                              onSurface: Colors.white,
                                            )
                                            : const ColorScheme.light(
                                              primary: AppConstants.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black87,
                                            ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: isDarkMode ? AppConstants.darkCardColor : Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                          );
                          if (picked != null) {
                            setState(() => startDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: isDarkMode ? AppConstants.textLight : AppConstants.textDark,
                        ),
                        title: Text(
                          'End Date',
                          style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                        ),
                        subtitle: Text(
                          endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'Not set',
                          style: GoogleFonts.inter(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? now,
                            firstDate: startDate ?? DateTime(now.year - 5),
                            lastDate: now,
                            builder:
                                (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme:
                                        isDarkMode
                                            ? const ColorScheme.dark(
                                              primary: AppConstants.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: AppConstants.darkCardColor,
                                              onSurface: Colors.white,
                                            )
                                            : const ColorScheme.light(
                                              primary: AppConstants.primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black87,
                                            ),
                                    dialogTheme: DialogThemeData(
                                      backgroundColor: isDarkMode ? AppConstants.darkCardColor : Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                          );

                          if (picked != null) {
                            setState(() => endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (startDate != null && endDate != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.blue.withOpacity(0.15) : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Bills from ${DateFormat('dd MMM').format(startDate!)} to ${DateFormat('dd MMM').format(endDate!)}',
                                  style: GoogleFonts.inter(
                                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        startDate = null;
                        endDate = null;
                      });
                      controller.resetDateFilter();
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(color: isDarkMode ? AppConstants.textLight : AppConstants.textDark),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        startDate != null && endDate != null
                            ? () {
                              Navigator.pop(context);
                              controller.filterBillsByDateRange(startDate!, endDate!);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: AppConstants.textLight,
                    ),
                    child: Text('Apply', style: GoogleFonts.inter(color: AppConstants.textLight)),
                  ),
                ],
              );
            },
          ),
    );
  }
}
