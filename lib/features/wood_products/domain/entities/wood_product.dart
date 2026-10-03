class WoodProduct {
  final String id;
  final String name;
  final List<String> imageUrls;
  final double width;
  final double length;
  final double thickness;
  final String sizeUnit;
  final int quantity;
  final String unit;
  final double price;
  final List<String> zones;
  final String note;

  WoodProduct({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.width,
    required this.length,
    required this.thickness,
    required this.sizeUnit,
    required this.quantity,
    required this.unit,
    required this.price,
    this.zones = const [],
    this.note = '',
  });
}