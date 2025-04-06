import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final double price;
  final String category;
  final double? discount;
  final double? tax;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    this.discount,
    this.tax,
    this.imagePath,
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
    double? discount,
    double? tax,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'discount': discount,
      'tax': tax,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      category: map['category'],
      discount: map['discount'],
      tax: map['tax'],
      imagePath: map['imagePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category, discount: $discount, tax: $tax, imagePath: $imagePath)';
  }
}
