class WoodProduct {
  final String id;
  final String name;
  final List<String> imageUrls; // ✅ รองรับหลายรูป (สูงสุด 6)
  final double width;
  final double length;
  final double thickness;
  final String sizeUnit; // mm / cm / m
  final int quantity;
  final String unit; // แผ่น / ท่อน / ต้น ฯลฯ
  final double price;

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
  });
}
