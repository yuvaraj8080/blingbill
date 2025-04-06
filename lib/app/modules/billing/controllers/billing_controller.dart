import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../constants/app_constants.dart';
import '../../../data/models/bill_item_model.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/database_service.dart';
import '../../../utils/bill_utils.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class BillingController extends GetxController {
  final _databaseService = DatabaseService.to;

  // Text controllers
  final customerNameController = TextEditingController();
  final globalDiscountController = TextEditingController(text: '0');
  final globalTaxController = TextEditingController(text: '0');

  final selectedProduct = Rx<Product?>(null);
  final quantity = 1.obs;
  final selectedPaymentMethod = 'Cash'.obs;

  final billItems = <BillItem>[].obs;
  final bills = <Bill>[].obs;

  final isLoading = true.obs;

  // Available products
  final availableProducts = <Product>[].obs;

  // Bill calculation values
  final subTotal = 0.0.obs;
  final globalDiscount = 0.0.obs;
  final globalTax = 0.0.obs;
  final discountAmount = 0.0.obs;
  final taxAmount = 0.0.obs;
  final totalAmount = 0.0.obs;

  // Filtering
  final searchQuery = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  // Confetti animation
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    loadBills();
    confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    customerNameController.dispose();
    globalDiscountController.dispose();
    globalTaxController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    globalDiscountController.dispose();
    globalTaxController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      availableProducts.value = await _databaseService.getAllProducts();

      if (availableProducts.isNotEmpty) {
        selectedProduct.value = availableProducts.first;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateSelectedProduct(Product? product) {
    selectedProduct.value = product;
    quantity.value = 1;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addItemToBill() {
    if (selectedProduct.value == null) {
      Get.snackbar(
        'Error',
        'Please select a product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final product = selectedProduct.value!;

    // Check if product already exists in bill
    final existingItemIndex = billItems.indexWhere((item) => item.productId == product.id);

    if (existingItemIndex != -1) {
      // Update quantity if product already in bill
      final existingItem = billItems[existingItemIndex];
      final updatedItem = BillItem(
        id: existingItem.id,
        billId: existingItem.billId,
        productId: product.id!,
        productName: product.name,
        price: product.price,
        quantity: existingItem.quantity + quantity.value,
        discount: product.discount,
        tax: product.tax,
        totalAmount: BillUtils.calculateItemTotal(
          product.price,
          existingItem.quantity + quantity.value,
          product.discount ?? 0,
          product.tax ?? 0,
        ),
      );

      billItems[existingItemIndex] = updatedItem;

      Get.snackbar(
        'Success',
        'Updated ${product.name} quantity to ${updatedItem.quantity}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      // Add new item
      final newItem = BillItem(
        productId: product.id!,
        productName: product.name,
        price: product.price,
        quantity: quantity.value,
        discount: product.discount,
        tax: product.tax,
        totalAmount: BillUtils.calculateItemTotal(
          product.price,
          quantity.value,
          product.discount ?? 0,
          product.tax ?? 0,
        ),
      );

      billItems.add(newItem);

      Get.snackbar(
        'Success',
        'Added ${product.name} to bill',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }

    // Reset quantity
    quantity.value = 1;
    // Reset selected product
    selectedProduct.value = availableProducts.isNotEmpty ? availableProducts[0] : null;
    _recalculateTotals();
  }

  void removeItemFromBill(int index) {
    if (index >= 0 && index < billItems.length) {
      final item = billItems[index];
      billItems.removeAt(index);

      Get.snackbar(
        'Item Removed',
        '${item.productName} has been removed from the bill',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      _recalculateTotals();
    }
  }

  void updateGlobalDiscount(String value) {
    double? parsedValue = double.tryParse(value);
    if (parsedValue != null && parsedValue >= 0 && parsedValue <= 100) {
      globalDiscount.value = parsedValue;
      _recalculateTotals();
    }
  }

  void updateGlobalTax(String value) {
    double? parsedValue = double.tryParse(value);
    if (parsedValue != null && parsedValue >= 0 && parsedValue <= 100) {
      globalTax.value = parsedValue;
      _recalculateTotals();
    }
  }

  void _recalculateTotals() {
    // Calculate subtotal
    subTotal.value = billItems.fold(0, (total, item) => total + item.totalAmount);

    // Calculate discount
    final discountValue = double.tryParse(globalDiscountController.text) ?? 0;
    globalDiscount.value = discountValue;
    discountAmount.value = (subTotal.value * discountValue / 100);

    // Calculate tax
    final taxValue = double.tryParse(globalTaxController.text) ?? 0;
    globalTax.value = taxValue;
    taxAmount.value = (subTotal.value - discountAmount.value) * taxValue / 100;

    // Calculate total
    totalAmount.value = subTotal.value - discountAmount.value + taxAmount.value;
  }

  // Clear all bill items
  void clearBillItems() {
    billItems.clear();
    _recalculateTotals();
    Get.snackbar(
      'Bill Cleared',
      'All items have been removed from the bill',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Clear the entire bill form
  void clearBill() {
    billItems.clear();
    customerNameController.clear();
    globalDiscountController.text = '0';
    globalTaxController.text = '0';
    _recalculateTotals();
    Get.snackbar(
      'Form Reset',
      'Bill form has been reset',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> saveBill() async {
    if (billItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one item to the bill',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Create bill
      final bill = Bill(
        customerName:
            customerNameController.text.trim().isNotEmpty ? customerNameController.text.trim() : 'Walk-in Customer',
        date: DateTime.now(),
        subTotal: subTotal.value,
        discount: globalDiscount.value,
        discountAmount: discountAmount.value,
        tax: globalTax.value,
        taxAmount: taxAmount.value,
        totalAmount: totalAmount.value,
        paymentMethod: selectedPaymentMethod.value,
        items: billItems.toList(),
      );

      // Save bill to database
      final billId = await _databaseService.insertBill(bill);
      final savedBill = await _databaseService.getBill(billId);

      if (savedBill != null) {
        // Reset the form
        customerNameController.clear();
        globalDiscountController.text = '0';
        globalTaxController.text = '0';
        globalDiscount.value = 0;
        globalTax.value = 0;
        billItems.clear();
        _recalculateTotals();

        // Refresh dashboard
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.refreshData();
        }
        // Refresh bill list
        await loadBills();
        confettiController.play();

        // Show success message
        Get.snackbar(
          'Success',
          'Bill saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Ask to generate PDF
        Get.defaultDialog(
          title: '🎉 Bill Saved!',
          titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent),
          middleText: 'Do you want to view or share this bill?',
          middleTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
          textConfirm: 'Yes',
          textCancel: 'No',
          confirmTextColor: Colors.white,
          cancelTextColor: Colors.white,
          buttonColor: AppConstants.primaryColor,
          backgroundColor: Colors.grey.shade900,
          radius: 12,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          onConfirm: () {
            Get.back();
            Future.delayed(const Duration(milliseconds: 200), () {
              generateInvoice(savedBill);
            });
          },
          onCancel: () {
            Get.back();
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save bill: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete bill
  Future<void> deleteBill(int billId) async {
    try {
      isLoading.value = true;
      final success = await _databaseService.deleteBill(billId);

      if (success > 0) {
        // Remove from local list
        bills.removeWhere((bill) => bill.id == billId);

        // Refresh dashboard
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.refreshData();
        }
        loadBills();
        Get.back();
        Get.snackbar(
          'Success',
          'Bill deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Bill not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete bill: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load all bills
  Future<void> loadBills() async {
    isLoading.value = true;
    try {
      bills.value = await DatabaseService.to.getAllBills();
    } catch (e) {
      debugPrint('Error loading bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search bills by customer name
  Future<void> searchBills(String query) async {
    if (query.isEmpty) {
      await loadBills();
      return;
    }

    isLoading.value = true;
    try {
      bills.value = await DatabaseService.to.searchBills(query);
    } catch (e) {
      debugPrint('Error searching bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter bills by date range
  Future<void> filterBillsByDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;

    isLoading.value = true;
    try {
      bills.value = await DatabaseService.to.getBillsByDateRange(start, end);
    } catch (e) {
      debugPrint('Error filtering bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset date filter
  Future<void> resetDateFilter() async {
    startDate.value = null;
    endDate.value = null;
    await loadBills();
  }

  // Generate invoice PDF
  Future<void> generateInvoice(Bill bill) async {
    try {
      final pdf = pw.Document(author: 'Ankit', title: 'BlingBill Invoice');
      final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '\u{20B9}');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildInvoiceHeader(bill),
          build:
              (context) => [
                // Invoice title
                pw.Center(child: pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 20),

                // Bill info
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text(bill.customerName, style: pw.TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildInvoiceInfoRow('Invoice #', '${bill.id}'),
                          _buildInvoiceInfoRow('Date', bill.formattedDate),
                          _buildInvoiceInfoRow('Payment Method', bill.paymentMethod),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Items table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Table header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('Item', isHeader: true),
                        _buildTableCell('Price', isHeader: true, align: pw.TextAlign.right),
                        _buildTableCell('Qty', isHeader: true, align: pw.TextAlign.center),
                        _buildTableCell('Total', isHeader: true, align: pw.TextAlign.right),
                      ],
                    ),

                    // Table rows
                    ...bill.items.map(
                      (item) => pw.TableRow(
                        children: [
                          _buildTableCell(item.productName),
                          _buildTableCell(currencyFormat.format(item.price), align: pw.TextAlign.right),
                          _buildTableCell('${item.quantity}', align: pw.TextAlign.center),
                          _buildTableCell(currencyFormat.format(item.totalAmount), align: pw.TextAlign.right),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Summary
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _buildSummaryRow('Subtotal', currencyFormat.format(bill.subTotal)),
                      _buildSummaryRow('Discount', '- ${currencyFormat.format(bill.discountAmount)}'),
                      _buildSummaryRow('Tax', '+ ${currencyFormat.format(bill.taxAmount)}'),
                      pw.Divider(),
                      _buildSummaryRow('TOTAL', currencyFormat.format(bill.totalAmount), isBold: true, fontSize: 16),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Made by Ankit',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.normal, color: PdfColors.grey700),
                  ),
                ),
              ],
        ),
      );

      // Show print preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'BlingBill_Invoice_${bill.id}.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        colorText: AppConstants.textLight,
      );
    }
  }

  // PDF Helper methods
  pw.Widget _buildInvoiceHeader(Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              AppConstants.appName,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.amber700),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Jewelry Billing', style: pw.TextStyle(color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Text(value),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : null), textAlign: align),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 12}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, fontSize: fontSize)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, fontSize: fontSize)),
        ],
      ),
    );
  }
}
