import 'dart:convert';

class BillItem {
  final int? id;
  final int? billId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double? discount;
  final double? tax;
  final double totalAmount;

  BillItem({
    this.id,
    this.billId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.discount,
    this.tax,
    required this.totalAmount,
  });

  BillItem copyWith({
    int? id,
    int? billId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    double? discount,
    double? tax,
    double? totalAmount,
  }) {
    return BillItem(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billId': billId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      id: map['id'],
      billId: map['billId'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
      discount: map['discount'],
      tax: map['tax'],
      totalAmount: map['totalAmount'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BillItem.fromJson(String source) => BillItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BillItem(id: $id, billId: $billId, productId: $productId, productName: $productName, price: $price, quantity: $quantity, discount: $discount, tax: $tax, totalAmount: $totalAmount)';
  }
}
