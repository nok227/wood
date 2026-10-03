class SaleItemEntity {
  final String itemId;
  final String productId;
  final String productName;
  final String woodType;

  final double? productWidth;
  final double? productLength;
  final double? productThickness;
  final String? productSizeUnit;

  final double unitPrice;
  final int quantity;
  final String unit;
  final double discountPerUnit;

  const SaleItemEntity({
    required this.itemId,
    required this.productId,
    required this.productName,
    this.woodType = '',
    this.productWidth,
    this.productLength,
    this.productThickness,
    this.productSizeUnit,
    required this.unitPrice,
    this.quantity = 1,
    this.unit = 'ຊິ້ນ',
    this.discountPerUnit = 0,
  });

  double get grossAmount => unitPrice * quantity;
  double get discountAmount => discountPerUnit * quantity;
  double get totalAmount => grossAmount - discountAmount;

  bool get hasDiscount => discountPerUnit > 0;
  bool get hasSize =>
      productWidth != null && productLength != null && productThickness != null;

  String get dimensionText {
    if (!hasSize) return '';
    String f(num v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return '${f(productWidth!)}×${f(productLength!)}×${f(productThickness!)} '
            '${productSizeUnit ?? ''}'
        .trim();
  }

  SaleItemEntity copyWith({
    int? quantity,
    double? discountPerUnit,
    double? unitPrice,
  }) =>
      SaleItemEntity(
        itemId: itemId,
        productId: productId,
        productName: productName,
        woodType: woodType,
        productWidth: productWidth,
        productLength: productLength,
        productThickness: productThickness,
        productSizeUnit: productSizeUnit,
        unitPrice: unitPrice ?? this.unitPrice,
        quantity: quantity ?? this.quantity,
        unit: unit,
        discountPerUnit: discountPerUnit ?? this.discountPerUnit,
      );
}