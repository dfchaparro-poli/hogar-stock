import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../screens/product_form_screen.dart';
import '../services/category_service.dart';
import '../services/hive_service.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.categoryService,
    required this.productService,
  });

  final String productId;
  final CategoryService categoryService;
  final ProductService productService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Product>(
        HiveService.productsBoxName,
      ).listenable(),
      builder: (context, Box<Product> box, _) {
        final product = productService.getById(productId);

        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Producto')),
            body: const Center(child: Text('El producto ya no existe.')),
          );
        }

        final category = categoryService.getById(product.categoryId);
        final expiration = product.expirationDate == null
            ? 'Sin fecha de vencimiento'
            : DateFormat('dd/MM/yyyy').format(product.expirationDate!);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            actions: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(
                      product: product,
                      categoryService: categoryService,
                      productService: productService,
                    ),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () => _confirmDelete(context, product),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Nombre', value: product.name),
                      _DetailRow(
                        label: 'Categoria',
                        value: category?.name ?? 'Sin categoria',
                      ),
                      _DetailRow(
                        label: 'Cantidad',
                        value: '${product.quantity} ${product.unit}',
                      ),
                      _DetailRow(
                        label: 'Cantidad minima',
                        value: '${product.minimumQuantity}',
                      ),
                      _DetailRow(label: 'Vencimiento', value: expiration),
                      _DetailRow(
                        label: 'Creado',
                        value: DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(product.createdAt),
                      ),
                      _DetailRow(
                        label: 'Actualizado',
                        value: DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(product.updatedAt),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('Se eliminara "${product.name}" del inventario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await productService.delete(product.id);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente.')),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
