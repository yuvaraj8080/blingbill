import 'package:get/get.dart';
import '../models/product_model.dart';
import 'database_service.dart';

class ProductService extends GetxService {
  static ProductService get to => Get.find();
  final DatabaseService _db = DatabaseService.to;

  Future<List<Product>> getAllProducts() async {
    return await _db.getAllProducts();
  }

  Future<Product?> getProduct(int id) async {
    return await _db.getProduct(id);
  }

  Future<int> createProduct(Product product) async {
    return await _db.insertProduct(product);
  }

  Future<int> updateProduct(Product product) async {
    return await _db.updateProduct(product);
  }

  Future<int> deleteProduct(int id) async {
    return await _db.deleteProduct(id);
  }
} 