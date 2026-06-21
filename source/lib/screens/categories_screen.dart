import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/category_icon_catalog.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../services/export_service.dart';
import '../services/hive_service.dart';
import '../services/import_service.dart';
import '../services/product_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.categoryService,
    required this.productService,
  });

  final CategoryService categoryService;
  final ProductService productService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left),
        ),
        title: const Text(
          'Categorias y exportacion',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Category>(
            HiveService.categoriesBoxName,
          ).listenable(),
          builder: (context, Box<Category> categoryBox, _) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<Product>(
                HiveService.productsBoxName,
              ).listenable(),
              builder: (context, Box<Product> productBox, _) {
                final categories = categoryService.getAll();
                final exportService = ExportService(
                  productService: productService,
                  categoryService: categoryService,
                );
                final importService = ImportService(
                  productService: productService,
                  categoryService: categoryService,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
                  children: [
                    const _SectionTitle('Categorias'),
                    const SizedBox(height: 10),
                    if (categories.isEmpty)
                      const _InfoBox(
                        text:
                            'Crea categorias para organizar los productos del inventario.',
                      )
                    else
                      ...categories.map(
                        (category) => _CategoryRow(
                          category: category,
                          productCount: productService
                              .search(categoryId: category.id)
                              .length,
                          onEdit: () =>
                              _showCategoryDialog(context, category: category),
                          onDelete: () => _confirmDelete(
                            context,
                            category,
                            productService
                                .search(categoryId: category.id)
                                .length,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showCategoryDialog(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Agregar categoria',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle(
                      'Importacion y exportacion del inventario',
                    ),
                    const SizedBox(height: 12),
                    const _InfoBox(
                      text:
                          'Generar o cargar una copia del inventario registrado para consulta externa o respaldo.',
                    ),
                    const SizedBox(height: 16),
                    _InventoryTransferActions(
                      exportService: exportService,
                      importService: importService,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    Category? category,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CategoryFormDialog(
        category: category,
        categoryService: categoryService,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Category category,
    int productCount,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar categoria'),
        content: Text(
          productCount > 0
              ? 'La categoria "${category.name}" tiene productos asociados. '
                    'Se mostrara la advertencia y no se eliminaran productos.'
              : 'Se eliminara la categoria "${category.name}".',
        ),
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

    final result = await categoryService.delete(category.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({
    required this.category,
    required this.categoryService,
  });

  final Category? category;
  final CategoryService categoryService;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late String _selectedIconKey;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _controller = TextEditingController(text: category?.name ?? '');
    _selectedIconKey =
        CategoryIconCatalog.normalizeKey(category?.iconKey) ??
        CategoryIconCatalog.suggestedKeyForName(category?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar categoria' : 'Crear categoria'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (!_isEditing) {
                      setState(
                        () => _selectedIconKey =
                            CategoryIconCatalog.suggestedKeyForName(value),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Icono',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CategoryIconCatalog.options.map((option) {
                    final selected = _selectedIconKey == option.key;
                    return ChoiceChip(
                      selected: selected,
                      avatar: Icon(option.icon, size: 18),
                      label: Text(option.label),
                      onSelected: (_) =>
                          setState(() => _selectedIconKey = option.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = widget.category;
    if (category != null) {
      await widget.categoryService.update(
        category.copyWith(
          name: _controller.text.trim(),
          iconKey: _selectedIconKey,
        ),
      );
    } else {
      await widget.categoryService.create(
        _controller.text.trim(),
        iconKey: _selectedIconKey,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 39,
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onEdit,
        onLongPress: onDelete,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: Row(
            children: [
              Icon(
                CategoryIconCatalog.iconFor(category),
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$productCount',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                color: colorScheme.onSurfaceVariant,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: onDelete,
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                color: colorScheme.onSurfaceVariant,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
        color: colorScheme.surfaceContainerHighest.withAlpha(70),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 13,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InventoryTransferActions extends StatefulWidget {
  const _InventoryTransferActions({
    required this.exportService,
    required this.importService,
  });

  final ExportService exportService;
  final ImportService importService;

  @override
  State<_InventoryTransferActions> createState() =>
      _InventoryTransferActionsState();
}

class _InventoryTransferActionsState extends State<_InventoryTransferActions> {
  bool _exporting = false;
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    final busy = _exporting || _importing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : _export,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: _exporting
              ? const SizedBox.shrink()
              : const Icon(Icons.file_upload_outlined),
          label: _exporting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Exportar inventario',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: busy ? null : _import,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: _importing
              ? const SizedBox.shrink()
              : const Icon(Icons.file_download_outlined),
          label: _importing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Importar inventario',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
        ),
      ],
    );
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );

      if (result == null) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw const FormatException('No se pudo leer el archivo seleccionado.');
      }
      final content = utf8.decode(bytes);
      final imported = await widget.importService.importInventoryJson(content);

      if (mounted) {
        _showMessage(
          'Importacion completa: ${imported.productsImported} productos y '
          '${imported.categoriesImported} categorias.',
        );
      }
    } on FormatException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo importar el inventario.');
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _export() async {
    if (!widget.exportService.hasProducts) {
      _showMessage('No hay inventario para exportar.');
      return;
    }

    setState(() => _exporting = true);
    try {
      final path = await widget.exportService.shareInventory();
      if (mounted) {
        _showMessage('Inventario exportado correctamente: $path');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo exportar el inventario.');
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
