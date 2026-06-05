import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../screens/categories_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/product_list_screen.dart';
import '../services/category_service.dart';
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
    final actions = [
      _DashboardAction(
        title: 'Inventario',
        icon: Icons.inventory_2_outlined,
        color: AppColors.navigation,
        onTap: () => _open(
          context,
          InventoryScreen(
            categoryService: categoryService,
            productService: productService,
          ),
        ),
      ),
      _DashboardAction(
        title: 'Registrar producto',
        icon: Icons.add_box_outlined,
        color: AppColors.success,
        onTap: () => _open(
          context,
          ProductFormScreen(
            categoryService: categoryService,
            productService: productService,
          ),
        ),
      ),
      _DashboardAction(
        title: 'Categorias',
        icon: Icons.category_outlined,
        color: AppColors.warning,
        onTap: () => _open(
          context,
          CategoriesScreen(
            categoryService: categoryService,
            productService: productService,
          ),
        ),
      ),
      _DashboardAction(
        title: 'Proximos a vencer',
        icon: Icons.event_busy_outlined,
        color: AppColors.error,
        onTap: () => _open(
          context,
          ProductListScreen(
            title: 'Proximos a vencer',
            emptyTitle: 'Nada por vencer pronto',
            emptyMessage:
                'No hay productos con vencimiento en los proximos 15 dias.',
            productService: productService,
            categoryService: categoryService,
            loadProducts: () => productService.expiringSoon(days: 15),
          ),
        ),
      ),
      _DashboardAction(
        title: 'Por reponer',
        icon: Icons.production_quantity_limits_outlined,
        color: AppColors.warning,
        onTap: () => _open(
          context,
          ProductListScreen(
            title: 'Por reponer',
            emptyTitle: 'Inventario suficiente',
            emptyMessage: 'No hay productos por debajo de la cantidad minima.',
            productService: productService,
            categoryService: categoryService,
            loadProducts: productService.lowStock,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HogarStock')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventario del hogar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestiona productos, categorias y alertas desde tu dispositivo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: actions.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.08,
                  ),
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: action.onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundColor: action.color.withAlpha(32),
                                foregroundColor: action.color,
                                child: Icon(action.icon),
                              ),
                              Text(
                                action.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
