import 'dart:convert';

import 'package:intl/intl.dart';

import 'bill_item_model.dart';

class Bill {
  final int? id;
  final String customerName;
  final DateTime date;
  final List<BillItem> items;
  final double subTotal;
  final double discount;
  final double discountAmount;
  final double tax;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;

  Bill({
    this.id,
    required this.customerName,
    required this.date,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.discountAmount,
    required this.tax,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  Bill copyWith({
    int? id,
    String? customerName,
    DateTime? date,
    List<BillItem>? items,
    double? subTotal,
    double? discount,
    double? discountAmount,
    double? tax,
    double? taxAmount,
    double? totalAmount,
    String? paymentMethod,
  }) {
    return Bill(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      discount: discount ?? this.discount,
      discountAmount: discountAmount ?? this.discountAmount,
      tax: tax ?? this.tax,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'subTotal': subTotal,
      'discount': discount,
      'discountAmount': discountAmount,
      'tax': tax,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }

  // For database storage (flattened without items)
  Map<String, dynamic> toMapForDb() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date.millisecondsSinceEpoch,
      'subTotal': subTotal,
      'discount': discount,
      'discountAmount': discountAmount,
      'tax': tax,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map, List<BillItem> items) {
    return Bill(
      id: map['id'],
      customerName: map['customerName'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      items: items,
      subTotal: map['subTotal'] ?? items.fold(0, (sum, item) => sum + item.totalAmount),
      discount: map['discount'] ?? 0.0,
      discountAmount: map['discountAmount'] ?? 0.0,
      tax: map['tax'] ?? 0.0,
      taxAmount: map['taxAmount'] ?? 0.0,
      totalAmount: map['total'] ?? (map['totalAmount'] ?? 0.0),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Bill(id: $id, customerName: $customerName, date: $date, items: $items, totalAmount: $totalAmount, tax: $tax, discount: $discount, paymentMethod: $paymentMethod)';
  }
}
