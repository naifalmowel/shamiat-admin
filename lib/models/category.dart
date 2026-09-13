class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final int order;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.order = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      icon: json['icon'],
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'icon': icon,
      'order': order,
    };
  }

  Category copyWith({
    String? nameAr,
    String? nameEn,
    String? icon,
    int? order,
  }) {
    return Category(
      id: this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }
}
