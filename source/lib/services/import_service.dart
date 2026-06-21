import 'dart:convert';

import '../models/product.dart';
import 'category_service.dart';
import 'product_service.dart';

class ImportResult {
  const ImportResult({
    required this.categoriesImported,
    required this.productsImported,
  });

  final int categoriesImported;
  final int productsImported;
}

class ImportService {
  ImportService({required this.productService, required this.categoryService});

  final ProductService productService;
  final CategoryService categoryService;

  Future<ImportResult> importInventoryJson(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('El archivo no tiene un formato valido.');
    }

    final categoriesPayload = decoded['categories'];
    final productsPayload = decoded['products'];
    if (productsPayload is! List) {
      throw const FormatException('El archivo no contiene productos.');
    }

    final categoryIdMap = <String, String>{};
    var categoriesImported = 0;

    if (categoriesPayload is List) {
      for (final item in categoriesPayload) {
        if (item is! Map) {
          continue;
        }
        final name = _stringValue(item['nombre'] ?? item['name']);
        if (name == null) {
          continue;
        }
        final category = await categoryService.create(
          name,
          iconKey: _stringValue(item['iconKey']),
        );
        categoriesImported++;
        final sourceId = _stringValue(item['id']);
        if (sourceId != null) {
          categoryIdMap[sourceId] = category.id;
        }
      }
    }

    var productsImported = 0;
    for (final item in productsPayload) {
      if (item is! Map) {
        continue;
      }

      final name = _stringValue(item['nombre'] ?? item['name']);
      if (name == null) {
        continue;
      }

      final category = await categoryService.create(
        _stringValue(item['categoria'] ?? item['category']) ?? 'Mercado',
        iconKey: _stringValue(item['categoryIconKey'] ?? item['iconKey']),
      );
      final sourceCategoryId = _stringValue(
        item['categoriaId'] ?? item['categoryId'],
      );
      final categoryId = sourceCategoryId == null
          ? category.id
          : categoryIdMap[sourceCategoryId] ?? category.id;

      final product = Product(
        id: _stringValue(item['id']) ?? '',
        name: name,
        categoryId: categoryId,
        quantity: _intValue(item['cantidad'] ?? item['quantity']) ?? 1,
        minimumQuantity:
            _intValue(item['cantidadMinima'] ?? item['minimumQuantity']) ?? 0,
        unit: _stringValue(item['unidadMedida'] ?? item['unit']) ?? 'unidades',
        expirationDate: _dateValue(
          item['fechaVencimiento'] ?? item['expirationDate'],
        ),
        createdAt: _dateValue(item['createdAt']) ?? DateTime.now(),
        updatedAt: _dateValue(item['updatedAt']) ?? DateTime.now(),
        imagePath: _stringValue(item['imagePath']),
        observations: _stringValue(
          item['observaciones'] ?? item['observations'],
        ),
      );

      await productService.save(product);
      productsImported++;
    }

    return ImportResult(
      categoriesImported: categoriesImported,
      productsImported: productsImported,
    );
  }

  String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  DateTime? _dateValue(Object? value) {
    final text = _stringValue(value);
    if (text == null) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}
