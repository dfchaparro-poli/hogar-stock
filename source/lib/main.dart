import 'package:flutter/material.dart';

import 'app/hogar_stock_app.dart';
import 'services/category_service.dart';
import 'services/hive_service.dart';
import 'services/product_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();

  final categoryService = CategoryService();
  await categoryService.seedDefaultsIfNeeded();

  runApp(
    HogarStockApp(
      categoryService: categoryService,
      productService: ProductService(),
    ),
  );
}
