import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';

class HiveService {
  static const categoriesBoxName = 'categories';
  static const productsBoxName = 'products';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }

    await Hive.openBox<Category>(categoriesBoxName);
    await Hive.openBox<Product>(productsBoxName);
  }
}
