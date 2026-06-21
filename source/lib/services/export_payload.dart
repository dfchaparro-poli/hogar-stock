import 'dart:convert';

import '../models/category.dart';
import '../models/product.dart';
import 'category_service.dart';
import 'product_service.dart';

class ExportPayload {
  ExportPayload({
    required this.productService,
    required this.categoryService,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const appVersion = '1.1.0';

  final ProductService productService;
  final CategoryService categoryService;
  final DateTime Function() _now;

  bool get hasProducts => productService.getAll().isNotEmpty;

  String buildInventoryJson() {
    final categories = categoryService.getAll();
    final categoryById = {
      for (final category in categories) category.id: category,
    };

    final payload = {
      'app': 'HogarStock',
      'version': appVersion,
      'exportedAt': _now().toIso8601String(),
      'products': productService
          .getAll()
          .map(
            (product) =>
                _productToJson(product, categoryById[product.categoryId]),
          )
          .toList(),
      'categories': categories.map(_categoryToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Map<String, dynamic> _productToJson(Product product, Category? category) {
    return {
      'id': product.id,
      'nombre': product.name,
      'categoriaId': product.categoryId,
      'categoria': category?.name ?? 'Sin categoria',
      'cantidad': product.quantity,
      'unidadMedida': product.unit,
      'fechaVencimiento': product.expirationDate?.toIso8601String(),
      'cantidadMinima': product.minimumQuantity,
      'observaciones': product.observations ?? '',
      if (product.imagePath != null && product.imagePath!.trim().isNotEmpty)
        'imagePath': product.imagePath,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _categoryToJson(Category category) {
    return {'id': category.id, 'nombre': category.name};
  }

  String fileStamp() {
    final date = _now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}${two(date.month)}${two(date.day)}-'
        '${two(date.hour)}${two(date.minute)}${two(date.second)}';
  }
}
