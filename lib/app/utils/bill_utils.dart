import '../data/models/bill_model.dart';

class BillUtils {
  /// Formats the bill number with leading zeros
  static String formatBillNumber(int? billNumber) {
    if (billNumber == null) return 'N/A';
    return billNumber.toString().padLeft(5, '0');
  }

  /// Formats the price with currency symbol
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }


  /// has discount
  static bool hasBillDiscount(Bill bill) {
    return bill.discount > 0;
  }

  /// Checks if the bill has tax
  static bool hasBillTax(Bill bill) {
    return bill.tax > 0;
  }

  /// Gets appropriate status icon for a bill
  static String getBillStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'assets/icons/paid.png';
      case 'pending':
        return 'assets/icons/pending.png';
      case 'cancelled':
        return 'assets/icons/cancelled.png';
      default:
        return 'assets/icons/bill_status.png';
    }
  }

  /// Calculates item total with discount and tax
  static double calculateItemTotal(double price, int quantity, double discount, double tax) {
    double itemSubtotal = price * quantity;
    double itemDiscountAmount = itemSubtotal * (discount / 100);
    double afterDiscount = itemSubtotal - itemDiscountAmount;
    double itemTaxAmount = afterDiscount * (tax / 100);
    return afterDiscount + itemTaxAmount;
  }
}
