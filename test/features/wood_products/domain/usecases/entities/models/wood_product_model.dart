class WoodProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double width;
  final double length;
  final double thickness;
  final int quantity;
  final String unit;
  final double price;

  WoodProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.width,
    required this.length,
    required this.thickness,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'width': width,
      'length': length,
      'thickness': thickness,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'createdAt': DateTime.now(),
    };
  }

  factory WoodProductModel.fromMap(Map<String, dynamic> map, String docId) {
    // ✅ ใช้ num.tryParse / as num? เผื่อข้อมูลเก่าที่ยังไม่มีฟิลด์เหล่านี้
    // ป้องกัน error ตอนอ่านข้อมูลเก่าจาก Firestore
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

    return WoodProductModel(
      id: docId,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      width: _toDouble(map['width']),
      length: _toDouble(map['length']),
      thickness: _toDouble(map['thickness']),
      quantity: _toInt(map['quantity']),
      unit: map['unit'] ?? 'แผ่น',
      price: _toDouble(map['price']),
    );
  }
}
