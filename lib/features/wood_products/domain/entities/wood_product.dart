class WoodProduct {
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
  final List<String> zones;
  final DateTime? priceUpdatedAt;
  final String note;

  WoodProduct({
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

  WoodProduct copyWith({
    String? id,
    String? name,
    String? woodType,
    List<String>? imageUrls,
    double? width,
    double? length,
    double? thickness,
    String? sizeUnit,
    int? quantity,
    String? unit,
    double? price,
    List<String>? zones,
    DateTime? priceUpdatedAt,
    String? note,
  }) =>
      WoodProduct(
        id: id ?? this.id,
        name: name ?? this.name,
        woodType: woodType ?? this.woodType,
        imageUrls: imageUrls ?? this.imageUrls,
        width: width ?? this.width,
        length: length ?? this.length,
        thickness: thickness ?? this.thickness,
        sizeUnit: sizeUnit ?? this.sizeUnit,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        price: price ?? this.price,
        zones: zones ?? this.zones,
        priceUpdatedAt: priceUpdatedAt ?? this.priceUpdatedAt,
        note: note ?? this.note,
      );
}