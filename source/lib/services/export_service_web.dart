import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import 'category_service.dart';
import 'export_payload.dart';
import 'product_service.dart';

class ExportService {
  ExportService({
    required ProductService productService,
    required CategoryService categoryService,
    DateTime Function()? now,
  }) : _payload = ExportPayload(
         productService: productService,
         categoryService: categoryService,
         now: now,
       );

  static const appVersion = ExportPayload.appVersion;

  final ExportPayload _payload;

  bool get hasProducts => _payload.hasProducts;

  String buildInventoryJson() => _payload.buildInventoryJson();

  Future<String> shareInventory() async {
    final fileName = 'hogarstock-inventario-${_payload.fileStamp()}.json';
    final bytes = utf8.encode(buildInventoryJson());
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, name: fileName, mimeType: 'application/json'),
        ],
        subject: 'Inventario HogarStock',
        text: 'Copia local del inventario de HogarStock.',
      ),
    );
    return fileName;
  }
}
