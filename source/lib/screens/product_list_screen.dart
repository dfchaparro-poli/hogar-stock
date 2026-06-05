import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/product_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.categoryService,
    required this.productService,
    required this.loadProducts,
  });

  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final CategoryService categoryService;
  final ProductService productService;
  final List<Product> Function() loadProducts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Product>(
          HiveService.productsBoxName,
        ).listenable(),
        builder: (context, Box<Product> box, _) {
          final products = loadProducts();
          final categories = categoryService.getAll();

          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle_outline,
              title: emptyTitle,
              message: emptyMessage,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                category: _categoryFor(categories, product.categoryId),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      productId: product.id,
                      categoryService: categoryService,
                      productService: productService,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Category? _categoryFor(List<Category> categories, String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}
