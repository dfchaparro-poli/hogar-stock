import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/category_icon_catalog.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../services/product_image_service.dart';
import '../services/product_service.dart';
import '../widgets/product_image.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    this.product,
    required this.categoryService,
    required this.productService,
  });

  final Product? product;
  final CategoryService categoryService;
  final ProductService productService;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumQuantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _observationsController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _imageService = ProductImageService();

  DateTime? _expirationDate;
  String? _categoryId;
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final categories = widget.categoryService.getAll();
    final defaultCategory = widget.categoryService.findByName('Mercado');
    _categoryId =
        product?.categoryId ??
        defaultCategory?.id ??
        (categories.isEmpty ? null : categories.first.id);

    if (product != null) {
      _nameController.text = product.name;
      _quantityController.text = product.quantity.toString();
      _minimumQuantityController.text = product.minimumQuantity.toString();
      _unitController.text = product.unit;
      _observationsController.text = product.observations ?? '';
      _expirationDate = product.expirationDate;
      _imagePath = product.imagePath;
    } else {
      _minimumQuantityController.text = '1';
      _unitController.text = 'unidades';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _unitController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryService.getAll();
    final dateText = _expirationDate == null
        ? 'Seleccionar fecha'
        : DateFormat('dd/MM/yyyy').format(_expirationDate!);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Registrar producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(CategoryIconCatalog.iconFor(category), size: 18),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              validator: (value) =>
                  value == null ? 'Selecciona una categoria.' : null,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                prefixIcon: Icon(Icons.numbers_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: _positiveInteger,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minimumQuantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad minima',
                prefixIcon: Icon(Icons.warning_amber_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: _nonNegativeInteger,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unidad',
                prefixIcon: Icon(Icons.straighten_outlined),
              ),
              textInputAction: TextInputAction.done,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observationsController,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Fecha de vencimiento'),
                subtitle: Text(dateText),
                trailing: _expirationDate == null
                    ? null
                    : IconButton(
                        tooltip: 'Quitar fecha',
                        onPressed: () => setState(() => _expirationDate = null),
                        icon: const Icon(Icons.close),
                      ),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Imagen del producto',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProductImage(
                      imagePath: _imagePath,
                      height: 180,
                      iconSize: 42,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _saving ? null : _pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(
                            _imagePath == null
                                ? 'Seleccionar imagen'
                                : 'Cambiar imagen',
                          ),
                        ),
                        if (_imagePath != null)
                          TextButton.icon(
                            onPressed: _saving
                                ? null
                                : () => setState(() => _imagePath = null),
                            icon: const Icon(Icons.close),
                            label: const Text('Quitar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isEditing ? 'Guardar cambios' : 'Registrar producto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (selected != null) {
      setState(() => _expirationDate = selected);
    }
  }

  Future<void> _pickImage() async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (selected == null) {
      return;
    }

    try {
      final savedPath = await _imageService.saveImage(selected);
      if (mounted) {
        setState(() => _imagePath = savedPath);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('No se pudo seleccionar la imagen.');
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final existing = widget.product;
    final now = DateTime.now();
    final product = Product(
      id: existing?.id ?? '',
      name: _nameController.text.trim(),
      categoryId: _categoryId!,
      quantity: int.parse(_quantityController.text),
      minimumQuantity: int.parse(_minimumQuantityController.text),
      unit: _unitController.text.trim(),
      expirationDate: _expirationDate,
      createdAt: existing?.createdAt ?? now,
      updatedAt: existing?.updatedAt ?? now,
      imagePath: _imagePath?.trim().isEmpty ?? true ? null : _imagePath,
      observations: _observationsController.text.trim().isEmpty
          ? null
          : _observationsController.text.trim(),
    );

    await widget.productService.save(product);

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Producto actualizado correctamente.'
              : 'Producto registrado correctamente.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }
    return null;
  }

  String? _positiveInteger(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final number = int.tryParse(value!);
    if (number == null || number <= 0) {
      return 'Ingresa una cantidad mayor a cero.';
    }
    return null;
  }

  String? _nonNegativeInteger(String? value) {
    final requiredMessage = _required(value);
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final number = int.tryParse(value!);
    if (number == null || number < 0) {
      return 'Ingresa una cantidad valida.';
    }
    return null;
  }
}
