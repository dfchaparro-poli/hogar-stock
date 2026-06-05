import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import 'hive_service.dart';

class ProductService {
  ProductService({
    Box<Product>? productBox,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _productBox =
           productBox ?? Hive.box<Product>(HiveService.productsBoxName),
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final Box<Product> _productBox;
  final Uuid _uuid;
  final DateTime Function() _now;

  List<Product> getAll() {
    final products = _productBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  Product? getById(String id) {
    return _productBox.get(id);
  }

  Future<Product> save(Product product) async {
    final now = _now();
    final existing = _findDuplicate(
      name: product.name,
      categoryId: product.categoryId,
      excludeId: product.id.isEmpty ? null : product.id,
    );

    if (product.id.isEmpty && existing != null) {
      final updated = existing.copyWith(
        quantity: existing.quantity + product.quantity,
        minimumQuantity: product.minimumQuantity,
        unit: product.unit.trim(),
        expirationDate: product.expirationDate,
        clearExpirationDate: product.expirationDate == null,
        updatedAt: now,
      );
      await _productBox.put(updated.id, updated);
      return updated;
    }

    final productToSave = product.copyWith(
      id: product.id.isEmpty ? _uuid.v4() : product.id,
      name: product.name.trim(),
      unit: product.unit.trim(),
      createdAt: product.id.isEmpty ? now : product.createdAt,
      updatedAt: now,
    );
    await _productBox.put(productToSave.id, productToSave);
    return productToSave;
  }

  Future<void> delete(String id) async {
    await _productBox.delete(id);
  }

  List<Product> search({String query = '', String? categoryId}) {
    final normalizedQuery = query.trim().toLowerCase();
    return getAll().where((product) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery);
      final matchesCategory =
          categoryId == null ||
          categoryId.isEmpty ||
          product.categoryId == categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<Product> expiringSoon({int days = 15}) {
    final today = DateTime(_now().year, _now().month, _now().day);
    final limit = today.add(Duration(days: days));
    return getAll().where((product) {
      final expiration = product.expirationDate;
      if (expiration == null) {
        return false;
      }
      final date = DateTime(expiration.year, expiration.month, expiration.day);
      return !date.isBefore(today) && !date.isAfter(limit);
    }).toList();
  }

  List<Product> lowStock() {
    return getAll()
        .where((product) => product.quantity <= product.minimumQuantity)
        .toList();
  }

  Product? _findDuplicate({
    required String name,
    required String categoryId,
    String? excludeId,
  }) {
    final normalizedName = name.trim().toLowerCase();
    for (final product in _productBox.values) {
      final isSameProduct = excludeId != null && product.id == excludeId;
      if (!isSameProduct &&
          product.name.toLowerCase() == normalizedName &&
          product.categoryId == categoryId) {
        return product;
      }
    }
    return null;
  }
}
