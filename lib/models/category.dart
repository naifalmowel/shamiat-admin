class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'icon': icon,
    };
  }

  Category copyWith({
    String? nameAr,
    String? nameEn,
    String? icon,
  }) {
    return Category(
      id: this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
    );
  }
}
