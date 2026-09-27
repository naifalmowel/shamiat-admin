class OptionChoice {
  final String nameAr;
  final String nameEn;
  final double price;

  OptionChoice({
    required this.nameAr,
    required this.nameEn,
    this.price = 0.0,
  });

  factory OptionChoice.fromJson(Map<String, dynamic> json) {
    return OptionChoice(
      nameAr: json['nameAr'] ?? json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'price': price,
    };
  }

  OptionChoice copyWith({
    String? nameAr,
    String? nameEn,
    double? price,
  }) {
    return OptionChoice(
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      price: price ?? this.price,
    );
  }
}

class MenuItemOptionGroup {
  final String titleAr;
  final String titleEn;
  final String type; // 'single' or 'multiple'
  final List<OptionChoice> choices;

  MenuItemOptionGroup({
    required this.titleAr,
    required this.titleEn,
    this.type = 'single',
    required this.choices,
  });

  factory MenuItemOptionGroup.fromJson(Map<String, dynamic> json) {
    var rawChoices = json['choices'] as List? ?? [];
    List<OptionChoice> choicesList = rawChoices
        .map((c) => OptionChoice.fromJson(Map<String, dynamic>.from(c)))
        .toList();

    return MenuItemOptionGroup(
      titleAr: json['titleAr'] ?? json['title'] ?? '',
      titleEn: json['titleEn'] ?? '',
      type: json['type'] ?? 'single',
      choices: choicesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'type': type,
      'choices': choices.map((c) => c.toJson()).toList(),
    };
  }

  MenuItemOptionGroup copyWith({
    String? titleAr,
    String? titleEn,
    String? type,
    List<OptionChoice>? choices,
  }) {
    return MenuItemOptionGroup(
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      type: type ?? this.type,
      choices: choices ?? this.choices,
    );
  }
}

class MenuItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final double? discountPrice;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int order;
  final int createdAt;
  final List<MenuItemOptionGroup> options;

  MenuItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.imageUrl,
    this.isAvailable = true,
    this.order = 0,
    int? createdAt,
    this.options = const [],
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List? ?? [];
    List<MenuItemOptionGroup> optionsList = rawOptions
        .map((o) => MenuItemOptionGroup.fromJson(Map<String, dynamic>.from(o)))
        .toList();

    return MenuItem(
      id: json['id'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      options: optionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'order': order,
      'createdAt': createdAt,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  MenuItem copyWith({
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? discountPrice,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    int? order,
    int? createdAt,
    List<MenuItemOptionGroup>? options,
  }) {
    return MenuItem(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      options: options ?? this.options,
    );
  }
}
