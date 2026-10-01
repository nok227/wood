// lib/features/wood_products/data/models/wood_product_model.dart

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

  // 🆕 ໂຊນ (multiple) — ເຊັ່ນ ['a1', 'a2', 'b3']
  final List<String> zones;

  // 🆕 ເວລາທີ່ແກ້ໄຂລາຄາລ່າສຸດ (ໃຊ້ສະແດງ Badge "ໃໝ່")
  final DateTime? priceUpdatedAt;

  // 🆕 ໝາຍເຫດ
  final String note;

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
    this.zones = const [],
    this.priceUpdatedAt,
    this.note = '',
  });

  bool get isPriceNew {
    if (priceUpdatedAt == null) return false;
    final diff = DateTime.now().difference(priceUpdatedAt!);
    return diff.inDays < 7 && !diff.isNegative;
  }

  int get daysSincePriceUpdate {
    if (priceUpdatedAt == null) return -1;
    return DateTime.now().difference(priceUpdatedAt!).inDays;
  }

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
      'zones': zones,
      'priceUpdatedAt': priceUpdatedAt?.toIso8601String(),
      'note': note,
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
      'zones': zones,
      'priceUpdatedAt': priceUpdatedAt?.toIso8601String(),
      'note': note,
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

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      try {
        final d = (v as dynamic).toDate();
        if (d is DateTime) return d;
      } catch (_) {}
      return null;
    }

    List<String> images = [];
    if (map['imageUrls'] != null) {
      images = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null &&
        map['imageUrl'].toString().isNotEmpty) {
      images = [map['imageUrl'].toString()];
    }

    List<String> zones = [];
    if (map['zones'] != null) {
      if (map['zones'] is List) {
        zones = List<String>.from(
          (map['zones'] as List).map((e) => e.toString()),
        );
      } else if (map['zones'] is String) {
        zones = (map['zones'] as String)
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
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
      zones: zones,
      priceUpdatedAt: _toDate(map['priceUpdatedAt']),
      note: (map['note'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoodProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}