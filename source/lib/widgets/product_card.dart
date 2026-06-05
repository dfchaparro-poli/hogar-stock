import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.category,
    required this.onTap,
  });

  final Product product;
  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expirationText = product.expirationDate == null
        ? 'Sin vencimiento'
        : DateFormat('dd/MM/yyyy').format(product.expirationDate!);
    final isLowStock = product.quantity <= product.minimumQuantity;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(product.name),
        subtitle: Text(
          '${category?.name ?? 'Sin categoria'} - Vence: $expirationText',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.quantity} ${product.unit}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLowStock ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('Min. ${product.minimumQuantity}'),
          ],
        ),
      ),
    );
  }
}
