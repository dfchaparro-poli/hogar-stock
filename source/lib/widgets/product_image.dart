import 'package:flutter/material.dart';

import 'product_image_provider.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.iconSize = 32,
    this.enablePreview = true,
  });

  final String? imagePath;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;
  final bool enablePreview;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && path.trim().isNotEmpty;
    final provider = hasImage ? productImageProvider(path) : null;
    final colorScheme = Theme.of(context).colorScheme;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
        child: SizedBox(
          width: width,
          height: height,
          child: provider != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image(
                        image: provider,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => _Placeholder(
                          iconSize: iconSize,
                          message: 'Imagen no disponible',
                        ),
                      ),
                    ),
                    if (enablePreview)
                      const Positioned(
                        right: 8,
                        bottom: 8,
                        child: _PreviewBadge(),
                      ),
                  ],
                )
              : _Placeholder(
                  iconSize: iconSize,
                  message: hasImage ? 'Imagen no disponible' : null,
                ),
        ),
      ),
    );

    if (provider == null || !enablePreview) {
      return image;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () => _showFullScreenImage(context, provider),
        child: image,
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, ImageProvider<Object> image) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(230),
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 5,
                  child: Center(
                    child: Image(
                      image: image,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: IconButton.filledTonal(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(130),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(5),
        child: Icon(Icons.open_in_full, size: 16, color: Colors.white),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize, this.message});

  final double iconSize;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: iconSize, color: color),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
