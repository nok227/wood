enum RecipeCategory {
  soup,
  stirFry,
  grilled,
  salad,
  curry,
  stirFried,
  dessert,
  other;

  String get label {
    switch (this) {
      case RecipeCategory.soup: return 'ຕົ້ມ';
      case RecipeCategory.stirFry: return 'ຜັດ';
      case RecipeCategory.grilled: return 'ຍ່າງ/ປີ້ງ';
      case RecipeCategory.salad: return 'ລາບ/ຍຳ';
      case RecipeCategory.curry: return 'ແກງ';
      case RecipeCategory.stirFried: return 'ຂົ້ວ';
      case RecipeCategory.dessert: return 'ຂອງຫວານ';
      case RecipeCategory.other: return 'ອື່ນໆ';
    }
  }

  String get emoji {
    switch (this) {
      case RecipeCategory.soup: return '🍲';
      case RecipeCategory.stirFry: return '🍳';
      case RecipeCategory.grilled: return '🍖';
      case RecipeCategory.salad: return '🥗';
      case RecipeCategory.curry: return '🍛';
      case RecipeCategory.stirFried: return '🥘';
      case RecipeCategory.dessert: return '🍰';
      case RecipeCategory.other: return '🍽️';
    }
  }

  static RecipeCategory fromString(String? s) {
    if (s == null) return RecipeCategory.other;
    for (final c in RecipeCategory.values) {
      if (c.name == s) return c;
    }
    return RecipeCategory.other;
  }
}

enum RecipeStatus {
  never,
  want,
  tried;

  String get label {
    switch (this) {
      case RecipeStatus.never: return 'ຍັງບໍ່ເຄີຍ';
      case RecipeStatus.want: return 'ຢາກລອງ';
      case RecipeStatus.tried: return 'ເຄີຍເຮັດ';
    }
  }

  static RecipeStatus fromString(String? s) {
    if (s == null) return RecipeStatus.never;
    for (final c in RecipeStatus.values) {
      if (c.name == s) return c;
    }
    return RecipeStatus.never;
  }
}

class RecipeEntity {
  final String id;
  final String name;
  final RecipeCategory category;
  final List<String> ingredients;
  final String? steps;
  final RecipeStatus status;
  final int rating;
  final List<String> imageUrls;
  final DateTime? lastEatenAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeEntity({
    required this.id,
    required this.name,
    this.category = RecipeCategory.other,
    this.ingredients = const [],
    this.steps,
    this.status = RecipeStatus.never,
    this.rating = 0,
    this.imageUrls = const [],
    this.lastEatenAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  RecipeEntity copyWith({
    String? id,
    String? name,
    RecipeCategory? category,
    List<String>? ingredients,
    String? steps,
    RecipeStatus? status,
    int? rating,
    List<String>? imageUrls,
    DateTime? lastEatenAt,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLastEaten = false,
    bool clearSteps = false,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: clearSteps ? null : (steps ?? this.steps),
      status: status ?? this.status,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      lastEatenAt:
          clearLastEaten ? null : (lastEatenAt ?? this.lastEatenAt),
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasSteps => (steps ?? '').trim().isNotEmpty;

  int? get daysSinceLastEaten {
    if (lastEatenAt == null) return null;
    return DateTime.now().difference(lastEatenAt!).inDays;
  }

  bool get isFreshlyEaten => (daysSinceLastEaten ?? 999) <= 3;

  bool get isDueForVariety =>
      lastEatenAt == null || (daysSinceLastEaten ?? 0) >= 14;

  String get lastEatenLabel {
    if (lastEatenAt == null) return 'ຍັງບໍ່ເຄີຍກິນ';
    final d = daysSinceLastEaten ?? 0;
    if (d == 0) return 'ກິນມື້ນີ້';
    if (d == 1) return 'ກິນມື້ວານ';
    if (d < 7) return 'ກິນ $d ວັນກ່ອນ';
    if (d < 30) return 'ກິນ ${(d / 7).floor()} ອາທິດກ່ອນ';
    return 'ກິນ ${(d / 30).floor()} ເດືອນກ່ອນ';
  }
}