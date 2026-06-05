import 'package:hive/hive.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.minimumQuantity,
    required this.unit,
    required this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String categoryId;
  final int quantity;
  final int minimumQuantity;
  final String unit;
  final DateTime? expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product copyWith({
    String? id,
    String? name,
    String? categoryId,
    int? quantity,
    int? minimumQuantity,
    String? unit,
    DateTime? expirationDate,
    bool clearExpirationDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      unit: unit ?? this.unit,
      expirationDate: clearExpirationDate
          ? null
          : expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 2;

  @override
  Product read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final fieldCount = reader.readByte();
    for (var i = 0; i < fieldCount; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryId: fields[2] as String,
      quantity: fields[3] as int,
      minimumQuantity: fields[4] as int,
      unit: fields[5] as String,
      expirationDate: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.minimumQuantity)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.expirationDate)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}
