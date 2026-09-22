class WoodProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double width; // กว้าง (ซม.)
  final double length; // ยาว (ซม.)
  final double thickness; // หนา (ซม.)
  final int quantity; // จำนวน
  final String unit; // หน่วยนับ เช่น แผ่น, ท่อน, ต้น
  final double price; // ราคาขาย (บาท)

  WoodProduct({
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
}
