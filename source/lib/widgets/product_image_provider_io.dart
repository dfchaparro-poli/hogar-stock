import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

ImageProvider<Object>? productImageProvider(String path) {
  final bytes = _decodeDataUri(path);
  if (bytes != null) {
    return MemoryImage(bytes);
  }
  return FileImage(File(path));
}

Uint8List? _decodeDataUri(String value) {
  final marker = 'base64,';
  final index = value.indexOf(marker);
  if (!value.startsWith('data:image/') || index == -1) {
    return null;
  }
  return base64Decode(value.substring(index + marker.length));
}
