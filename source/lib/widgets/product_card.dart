import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../core/category_icon_catalog.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'product_image.dart';

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
    final isExpired = _isExpired(product);
    final expirationLabel = isExpired ? 'Venció' : 'Vence';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: ProductImage(
          imagePath: product.imagePath,
          width: 48,
          height: 48,
          borderRadius: 6,
          iconSize: 22,
          enablePreview: false,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isExpired) ...[
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(34),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.error.withAlpha(120)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    'Vencido',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Row(
          children: [
            Icon(CategoryIconCatalog.iconFor(category), size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${category?.name ?? 'Sin categoria'} - $expirationLabel: $expirationText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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

  bool _isExpired(Product product) {
    final expiration = product.expirationDate;
    if (expiration == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(expiration.year, expiration.month, expiration.day);
    return date.isBefore(today);
  }
}
