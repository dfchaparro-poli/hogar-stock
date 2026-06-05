import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_form_screen.dart';
import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/product_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    super.key,
    required this.categoryService,
    required this.productService,
  });

  final CategoryService categoryService;
  final ProductService productService;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _query = '';
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductFormScreen(
              categoryService: widget.categoryService,
              productService: widget.productService,
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Product>(
          HiveService.productsBoxName,
        ).listenable(),
        builder: (context, Box<Product> box, _) {
          final categories = widget.categoryService.getAll();
          final products = widget.productService.search(
            query: _query,
            categoryId: _categoryId,
          );

          if (box.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Inventario vacio',
              message: 'Registra tu primer producto para empezar.',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Buscar producto',
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.filter_alt_outlined),
                        labelText: 'Filtrar por categoria',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Todas las categorias'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(
                          () => _categoryId = value?.isEmpty ?? true
                              ? null
                              : value,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_outlined,
                        title: 'Sin resultados',
                        message:
                            'No hay productos que coincidan con la busqueda.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final category = _categoryFor(
                            categories,
                            product.categoryId,
                          );
                          return ProductCard(
                            product: product,
                            category: category,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  productId: product.id,
                                  categoryService: widget.categoryService,
                                  productService: widget.productService,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
