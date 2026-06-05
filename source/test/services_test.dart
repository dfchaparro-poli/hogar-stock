import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hogar_stock/models/category.dart';
import 'package:hogar_stock/models/product.dart';
import 'package:hogar_stock/services/category_service.dart';
import 'package:hogar_stock/services/product_service.dart';

void main() {
  late Directory tempDir;
  late Box<Category> categoryBox;
  late Box<Product> productBox;
  late CategoryService categoryService;
  late ProductService productService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hogar_stock_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }

    categoryBox = await Hive.openBox<Category>('categories_test');
    productBox = await Hive.openBox<Product>('products_test');
    categoryService = CategoryService(
      categoryBox: categoryBox,
      productBox: productBox,
    );
    productService = ProductService(
      productBox: productBox,
      now: () => DateTime(2026, 6, 5),
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('crea un producto', () async {
    final category = await categoryService.create('Mercado');
    final product = await productService.save(
      _product(name: 'Arroz', categoryId: category.id),
    );

    expect(product.id, isNotEmpty);
    expect(productService.getAll(), hasLength(1));
    expect(productService.getById(product.id)?.name, 'Arroz');
  });

  test(
    'actualiza cantidad al registrar duplicado por nombre y categoria',
    () async {
      final category = await categoryService.create('Mercado');

      await productService.save(
        _product(name: 'Arroz', categoryId: category.id, quantity: 2),
      );
      await productService.save(
        _product(name: 'arroz', categoryId: category.id, quantity: 3),
      );

      final products = productService.getAll();
      expect(products, hasLength(1));
      expect(products.single.quantity, 5);
    },
  );

  test('filtra productos por categoria', () async {
    final mercado = await categoryService.create('Mercado');
    final limpieza = await categoryService.create('Limpieza');

    await productService.save(_product(name: 'Arroz', categoryId: mercado.id));
    await productService.save(_product(name: 'Jabon', categoryId: limpieza.id));

    final filtered = productService.search(categoryId: limpieza.id);

    expect(filtered, hasLength(1));
    expect(filtered.single.name, 'Jabon');
  });

  test('detecta productos proximos a vencer en 15 dias', () async {
    final category = await categoryService.create('Mercado');

    await productService.save(
      _product(
        name: 'Leche',
        categoryId: category.id,
        expirationDate: DateTime(2026, 6, 20),
      ),
    );
    await productService.save(
      _product(
        name: 'Pasta',
        categoryId: category.id,
        expirationDate: DateTime(2026, 7, 1),
      ),
    );

    final expiring = productService.expiringSoon(days: 15);

    expect(expiring, hasLength(1));
    expect(expiring.single.name, 'Leche');
  });

  test('detecta productos por reponer', () async {
    final category = await categoryService.create('Mercado');

    await productService.save(
      _product(
        name: 'Cafe',
        categoryId: category.id,
        quantity: 1,
        minimumQuantity: 2,
      ),
    );
    await productService.save(
      _product(
        name: 'Azucar',
        categoryId: category.id,
        quantity: 5,
        minimumQuantity: 2,
      ),
    );

    final lowStock = productService.lowStock();

    expect(lowStock, hasLength(1));
    expect(lowStock.single.name, 'Cafe');
  });

  test('bloquea eliminar categoria con productos asociados', () async {
    final category = await categoryService.create('Mercado');
    await productService.save(_product(name: 'Arroz', categoryId: category.id));

    final result = await categoryService.delete(category.id);

    expect(result.deleted, isFalse);
    expect(categoryService.getById(category.id), isNotNull);
  });
}

Product _product({
  required String name,
  required String categoryId,
  int quantity = 1,
  int minimumQuantity = 1,
  DateTime? expirationDate,
}) {
  return Product(
    id: '',
    name: name,
    categoryId: categoryId,
    quantity: quantity,
    minimumQuantity: minimumQuantity,
    unit: 'unidades',
    expirationDate: expirationDate,
    createdAt: DateTime(2026, 6, 5),
    updatedAt: DateTime(2026, 6, 5),
  );
}
