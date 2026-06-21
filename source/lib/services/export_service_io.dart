import 'dart:io';

import 'package:path_provider/path_provider.dart';
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

  Future<String> exportToFile() async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/hogarstock-inventario-${_payload.fileStamp()}.json',
    );
    await file.writeAsString(buildInventoryJson());
    return file.path;
  }

  Future<String> shareInventory() async {
    final filePath = await exportToFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Inventario HogarStock',
        text: 'Copia local del inventario de HogarStock.',
      ),
    );
    return filePath;
  }
}
