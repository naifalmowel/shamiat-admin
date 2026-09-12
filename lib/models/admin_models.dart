enum AdminCategoryKey {
  shawarma,
  burger,
  sandwich,
  fries,
  meals,
  chicken_meals,
  beverages,
  desserts,
}

class AdminMenuCategory {
  final AdminCategoryKey key;
  final String nameAr;
  final String nameEn;

  AdminMenuCategory({
    required this.key,
    required this.nameAr,
    required this.nameEn,
  });
}

class AdminMenuItem {
  final String id;
  String nameAr;
  String nameEn;
  String descriptionAr;
  String descriptionEn;
  double price;
  double? discountPrice;
  String categoryKey;
  String supabaseUrl;
  bool isAvailable;

  AdminMenuItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr = '',
    this.descriptionEn = '',
    required this.price,
    this.discountPrice,
    required this.categoryKey,
    this.supabaseUrl = '',
    this.isAvailable = true,
  });
}
