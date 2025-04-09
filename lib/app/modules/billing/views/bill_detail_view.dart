import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // Add this import for PdfPageFormat

import '../../../constants/app_constants.dart';
import '../../../data/models/bill_model.dart';
import '../controllers/billing_controller.dart';

class BillDetailView extends GetView<BillingController> {
  const BillDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Bill bill = Get.arguments;
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill #${bill.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Invoice',
            onPressed: () => controller.generateInvoice(bill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 24, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        const Text('Bill Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(title: 'Customer', value: bill.customerName, icon: Icons.person),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            title: 'Date',
                            value: dateFormat.format(bill.date),
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            title: 'Payment Method',
                            value: bill.paymentMethod,
                            icon: bill.paymentMethod == 'Cash' ? Icons.money : Icons.credit_card,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            title: 'Items',
                            value: '${bill.items.length} item${bill.items.length > 1 ? 's' : ''}',
                            icon: Icons.shopping_bag,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Products Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, size: 24, color: AppConstants.accentColor),
                        const SizedBox(width: 8),
                        const Text('Purchased Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bill.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = bill.items[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity} × ${currencyFormat.format(item.price)}'),
                              if (item.discount != null && item.discount! > 0)
                                Text(
                                  'Discount: ${item.discount}%',
                                  style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                                ),
                              if (item.tax != null && item.tax! > 0)
                                Text('Tax: ${item.tax}%', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                          trailing: Text(
                            currencyFormat.format(item.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.summarize, size: 24, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        const Text('Bill Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow('Sub-Total', currencyFormat.format(bill.subTotal)),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Discount (${bill.discount.toStringAsFixed(2)}%)',
                      '- ${currencyFormat.format(bill.discountAmount)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Tax (${bill.tax.toStringAsFixed(2)}%)',
                      '+ ${currencyFormat.format(bill.taxAmount)}',
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL', style: AppConstants.headingStyle.copyWith(fontSize: 18)),
                        Text(
                          currencyFormat.format(bill.totalAmount),
                          style: GoogleFonts.lato(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Invoice Generation Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildInvoiceGenerationSection(bill),
              ),
            ),

            const SizedBox(height: 16),

            // Delete Button
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Delete Bill'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Bill'),
                    content: Text('Are you sure you want to delete "${bill.id}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.deleteBill(bill.id!);
                        },
                        child: const Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String title, required String value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    Color? valueColor,
    TextStyle? titleStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(title, style: titleStyle ?? const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: valueStyle ?? TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Added methods for invoice generation
  Widget buildInvoiceGenerationSection(Bill bill) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Invoice Format',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFormatOption(
                'A4 Portrait',
                Icons.portrait,
                () => controller.generateInvoice(bill, pageFormat: PdfPageFormat.a4),
              ),
              _buildFormatOption(
                'A4 Landscape',
                Icons.landscape,
                () => controller.generateInvoice(bill, pageFormat: PdfPageFormat.a4.landscape),
              ),
              _buildFormatOption(
                'Letter',
                Icons.description,
                () => controller.generateInvoice(bill, pageFormat: PdfPageFormat.letter),
              ),
              _buildFormatOption(
                'Compact',
                Icons.receipt,
                () => controller.generateInvoice(bill, pageFormat: PdfPageFormat.standard),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}