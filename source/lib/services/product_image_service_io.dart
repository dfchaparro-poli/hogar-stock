import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProductImageService {
  Future<String> saveImage(XFile image) async {
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw const FileSystemException(
        'La imagen seleccionada no esta disponible.',
      );
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/product_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final extension = _extensionFor(
      image.name.isEmpty ? image.path : image.name,
    );
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}$extension';
    final saved = File('${imageDir.path}/$fileName');
    await saved.writeAsBytes(bytes, flush: true);
    return saved.path;
  }

  String _extensionFor(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '.jpg';
    }
    return fileName.substring(dotIndex).toLowerCase();
  }
}
