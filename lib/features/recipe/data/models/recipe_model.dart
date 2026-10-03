import '../../domain/entities/recipe.dart';

class RecipeModel {
  final String id;
  final String name;
  final String category;
  final List<String> ingredients;
  final String? steps;
  final String status;
  final int rating;
  final List<String> imageUrls;
  final DateTime? lastEatenAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.id,
    required this.name,
    this.category = 'other',
    this.ingredients = const [],
    this.steps,
    this.status = 'never',
    this.rating = 0,
    this.imageUrls = const [],
    this.lastEatenAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _s(dynamic v, [String d = '']) =>
      v == null ? d : v.toString();

  static String? _sOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int _i(dynamic v, [int d = 0]) {
    if (v == null) return d;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? d;
  }

  static List<String> _strList(dynamic v) {
    if (v == null || v is! List) return [];
    return v
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static DateTime _date(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return DateTime.now();
  }

  static DateTime? _dateOrNull(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    try {
      final d = (v as dynamic).toDate();
      if (d is DateTime) return d;
    } catch (_) {}
    return null;
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map, String docId) {
    return RecipeModel(
      id: docId,
      name: _s(map['name']),
      category: _s(map['category'], 'other'),
      ingredients: _strList(map['ingredients']),
      steps: _sOrNull(map['steps']),
      status: _s(map['status'], 'never'),
      rating: _i(map['rating']).clamp(0, 5),
      imageUrls: _strList(map['imageUrls']),
      lastEatenAt: _dateOrNull(map['lastEatenAt']),
      note: _sOrNull(map['note']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'ingredients': ingredients,
        'steps': steps,
        'status': status,
        'rating': rating,
        'imageUrls': imageUrls,
        'lastEatenAt': lastEatenAt?.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  RecipeEntity toEntity() => RecipeEntity(
        id: id,
        name: name,
        category: RecipeCategory.fromString(category),
        ingredients: ingredients,
        steps: steps,
        status: RecipeStatus.fromString(status),
        rating: rating,
        imageUrls: imageUrls,
        lastEatenAt: lastEatenAt,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static RecipeModel fromEntity(RecipeEntity e) => RecipeModel(
        id: e.id,
        name: e.name,
        category: e.category.name,
        ingredients: e.ingredients,
        steps: e.steps,
        status: e.status.name,
        rating: e.rating,
        imageUrls: e.imageUrls,
        lastEatenAt: e.lastEatenAt,
        note: e.note,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}