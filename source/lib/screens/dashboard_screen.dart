import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../screens/categories_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/product_list_screen.dart';
import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/product_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.categoryService,
    required this.productService,
  });

  final CategoryService categoryService;
  final ProductService productService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HogarStock')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Product>(
          HiveService.productsBoxName,
        ).listenable(),
        builder: (context, Box<Product> productBox, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Category>(
              HiveService.categoriesBoxName,
            ).listenable(),
            builder: (context, Box<Category> categoryBox, _) {
              final totalProducts = productBox.length;
              final expiringSoon = productService.expiringSoon(days: 15).length;
              final lowStock = productService.lowStock().length;
              final totalCategories = categoryBox.length;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        children: [
                          Center(
                            child: Text(
                              'Resumen del inventario del hogar',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.9,
                            children: [
                              _SummaryTile(
                                title: 'Total productos',
                                value: totalProducts,
                                color: AppColors.success,
                              ),
                              _SummaryTile(
                                title: 'Por vencer',
                                value: expiringSoon,
                                color: AppColors.warning,
                              ),
                              _SummaryTile(
                                title: 'Por reponer',
                                value: lowStock,
                                color: AppColors.error,
                              ),
                              _SummaryTile(
                                title: 'Categorias',
                                value: totalCategories,
                                color: const Color(0xFFB48ADB),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => _open(
                              context,
                              ProductFormScreen(
                                categoryService: categoryService,
                                productService: productService,
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Registrar producto'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: const Color(0xFF1E2938),
                              foregroundColor: const Color(0xFFF8FAFC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Accesos rapidos',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          _QuickAccessButton(
                            label: 'Ver inventario',
                            onTap: () => _open(
                              context,
                              InventoryScreen(
                                categoryService: categoryService,
                                productService: productService,
                              ),
                            ),
                          ),
                          _QuickAccessButton(
                            label: 'Productos proximos a vencer',
                            onTap: () => _open(context, _expiringScreen()),
                          ),
                          _QuickAccessButton(
                            label: 'Productos por reponer',
                            onTap: () => _open(context, _lowStockScreen()),
                          ),
                          _QuickAccessButton(
                            label: 'Gestionar categorias',
                            onTap: () => _open(
                              context,
                              CategoriesScreen(
                                categoryService: categoryService,
                                productService: productService,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _DashboardFooter(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _expiringScreen() {
    return ProductListScreen(
      title: 'Proximos a vencer',
      emptyTitle: 'Nada por vencer pronto',
      emptyMessage: 'No hay productos con vencimiento en los proximos 15 dias.',
      productService: productService,
      categoryService: categoryService,
      loadProducts: () => productService.expiringSoon(days: 15),
    );
  }

  Widget _lowStockScreen() {
    return ProductListScreen(
      title: 'Por reponer',
      emptyTitle: 'Inventario suficiente',
      emptyMessage: 'No hay productos por debajo de la cantidad minima.',
      productService: productService,
      categoryService: categoryService,
      loadProducts: productService.lowStock,
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = Color.alphaBlend(color.withAlpha(190), Colors.white);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  const _QuickAccessButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: const Size.fromHeight(42),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Text(
        'Inicio  Inventario  Alertas  Gestion',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
