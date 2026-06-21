import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

ImageProvider<Object>? productImageProvider(String path) {
  final bytes = _decodeDataUri(path);
  return bytes == null ? null : MemoryImage(bytes);
}

Uint8List? _decodeDataUri(String value) {
  final marker = 'base64,';
  final index = value.indexOf(marker);
  if (!value.startsWith('data:image/') || index == -1) {
    return null;
  }
  return base64Decode(value.substring(index + marker.length));
}
