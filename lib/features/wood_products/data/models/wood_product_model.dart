class WoodProductModel {
  final String id;
  final String name;
  final String woodType;
  final List<String> imageUrls;
  final double width;
  final double length;
  final double thickness;
  final String sizeUnit;
  final int quantity;
  final String unit;
  final double price;

  WoodProductModel({
    required this.id,
    required this.name,
    this.woodType = '',
    required this.imageUrls,
    required this.width,
    required this.length,
    required this.thickness,
    required this.sizeUnit,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'woodType': woodType,
      'imageUrls': imageUrls,
      'width': width,
      'length': length,
      'thickness': thickness,
      'sizeUnit': sizeUnit,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'createdAt': DateTime.now(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'woodType': woodType,
      'imageUrls': imageUrls,
      'width': width,
      'length': length,
      'thickness': thickness,
      'sizeUnit': sizeUnit,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'updatedAt': DateTime.now(),
    };
  }

  factory WoodProductModel.fromMap(Map<String, dynamic> map, String docId) {
    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    List<String> images = [];
    if (map['imageUrls'] != null) {
      images = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      images = [map['imageUrl'].toString()];
    }

    return WoodProductModel(
      id: docId,
      name: map['name'] ?? '',
      woodType: map['woodType'] ?? '',
      imageUrls: images,
      width: _toDouble(map['width']),
      length: _toDouble(map['length']),
      thickness: _toDouble(map['thickness']),
      sizeUnit: map['sizeUnit'] ?? 'cm',
      quantity: _toInt(map['quantity']),
      unit: map['unit'] ?? 'ແຜ່ນ',
      price: _toDouble(map['price']),
    );
  }

  // ✅ เพิ่ม 2 เมธอดนี้ เพื่อให้ Dropdown เปรียบเทียบ Object จาก id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoodProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}