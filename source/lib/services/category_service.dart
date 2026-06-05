import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/product.dart';
import 'hive_service.dart';

class CategoryDeleteResult {
  const CategoryDeleteResult({required this.deleted, required this.message});

  final bool deleted;
  final String message;
}

class CategoryService {
  CategoryService({
    Box<Category>? categoryBox,
    Box<Product>? productBox,
    Uuid? uuid,
  }) : _categoryBox =
           categoryBox ?? Hive.box<Category>(HiveService.categoriesBoxName),
       _productBox =
           productBox ?? Hive.box<Product>(HiveService.productsBoxName),
       _uuid = uuid ?? const Uuid();

  final Box<Category> _categoryBox;
  final Box<Product> _productBox;
  final Uuid _uuid;

  List<Category> getAll() {
    final categories = _categoryBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  Category? getById(String id) {
    return _categoryBox.get(id);
  }

  Future<Category> create(String name) async {
    final normalizedName = name.trim();
    final existing = findByName(normalizedName);
    if (existing != null) {
      return existing;
    }

    final category = Category(id: _uuid.v4(), name: normalizedName);
    await _categoryBox.put(category.id, category);
    return category;
  }

  Future<void> update(Category category) async {
    await _categoryBox.put(
      category.id,
      category.copyWith(name: category.name.trim()),
    );
  }

  Future<CategoryDeleteResult> delete(String categoryId) async {
    final hasProducts = _productBox.values.any(
      (product) => product.categoryId == categoryId,
    );
    if (hasProducts) {
      return const CategoryDeleteResult(
        deleted: false,
        message: 'No se puede eliminar una categoria con productos asociados.',
      );
    }

    await _categoryBox.delete(categoryId);
    return const CategoryDeleteResult(
      deleted: true,
      message: 'Categoria eliminada correctamente.',
    );
  }

  Category? findByName(String name) {
    final normalizedName = name.trim().toLowerCase();
    for (final category in _categoryBox.values) {
      if (category.name.toLowerCase() == normalizedName) {
        return category;
      }
    }
    return null;
  }

  Future<void> seedDefaultsIfNeeded() async {
    if (_categoryBox.isNotEmpty) {
      return;
    }

    for (final name in const [
      'Despensa',
      'Refrigerados',
      'Limpieza',
      'Aseo personal',
      'Medicamentos',
    ]) {
      await create(name);
    }
  }
}
