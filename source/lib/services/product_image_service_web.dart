import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProductImageService {
  Future<String> saveImage(XFile image) async {
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('La imagen seleccionada no esta disponible.');
    }

    final mimeType = _mimeTypeFor(image.name.isEmpty ? image.path : image.name);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }
}
