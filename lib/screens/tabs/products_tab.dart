import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/admin_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/menu_item.dart';

enum ProductSortOption {
  manual, // According to custom drag/order
  newest, // Recently added first
  priceLowToHigh, // Lowest price first
  priceHighToLow, // Highest price first
}

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  ProductSortOption _sortOption = ProductSortOption.manual;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);

    // 1. Filter products
    List<MenuItem> filtered = provider.products.where((p) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          p.nameAr.toLowerCase().contains(query) ||
          p.nameEn.toLowerCase().contains(query);
      final matchesCat = _selectedCategory == 'الكل' || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    // 2. Sort products
    switch (_sortOption) {
      case ProductSortOption.manual:
        filtered.sort((a, b) => a.order.compareTo(b.order));
        break;
      case ProductSortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProductSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    final canReorder = _sortOption == ProductSortOption.manual && _selectedCategory != 'الكل' && _searchQuery.isEmpty;

    return Column(
      children: [
        // --- Top Bar (Search + Sort + Add) ---
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        textAlign: lang.isArabic ? TextAlign.right : TextAlign.left,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: lang.getText(ar: 'ابحث عن منتج...', en: 'Search product...'),
                          prefixIcon: const Icon(Icons.search, color: primaryColor, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort Menu
                  PopupMenuButton<ProductSortOption>(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Icon(Icons.sort_rounded, color: primaryColor, size: 22),
                    ),
                    tooltip: lang.getText(ar: 'ترتيب المنتجات', en: 'Sort Products'),
                    onSelected: (opt) => setState(() => _sortOption = opt),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: ProductSortOption.manual,
                        child: Text(lang.getText(ar: 'الترتيب الافتراضي / يدوي', en: 'Default / Manual Order')),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.newest,
                        child: Text(lang.getText(ar: 'المضافة حديثاً', en: 'Recently Added')),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.priceLowToHigh,
                        child: Text(lang.getText(ar: 'السعر: من الأدنى للأعلى', en: 'Price: Low to High')),
                      ),
                      PopupMenuItem(
                        value: ProductSortOption.priceHighToLow,
                        child: Text(lang.getText(ar: 'السعر: من الأعلى للأدنى', en: 'Price: High to Low')),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Add Button
                  Material(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _openProductEditor(context, null),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Category Filter Bar
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCatChip('الكل', _selectedCategory == 'الكل', accentColor, primaryColor, label: lang.getText(ar: 'الكل', en: 'All')),
                    ...provider.categories.map((c) => _buildCatChip(
                          c.id,
                          _selectedCategory == c.id,
                          accentColor,
                          primaryColor,
                          label: lang.isArabic ? c.nameAr : c.nameEn,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Hint for Reordering
        if (canReorder)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: accentColor.withValues(alpha: 0.12),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lang.getText(
                      ar: 'يمكنك إعادة ترتيب المنتجات في هذه الفئة عبر السحب والإفلات',
                      en: 'You can reorder products in this category via drag and drop',
                    ),
                    style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

        // --- Products List Optimized ---
        Expanded(
          child: provider.isInitialLoading
              ? _buildShimmerLoading()
              : filtered.isEmpty 
                  ? Center(child: Text(lang.getText(ar: 'لا توجد منتجات', en: 'No products found')))
                  : canReorder
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: filtered.length,
                          onReorder: (oldIndex, newIndex) {
                            provider.reorderProductsInList(filtered, oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              key: ValueKey(filtered[index].id),
                              child: _ProductCard(
                                item: filtered[index],
                                isReorderable: true,
                                dragIndex: index,
                              ),
                            );
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: filtered.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: _ProductCard(
                                key: ValueKey(filtered[index].id),
                                item: filtered[index],
                                isReorderable: false,
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildCatChip(String id, bool selected, Color accent, Color primary, {String? label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label ?? id),
        selected: selected,
        onSelected: (v) => setState(() => _selectedCategory = id),
        selectedColor: primary.withValues(alpha: 0.12),
        backgroundColor: Colors.grey[50],
        labelStyle: TextStyle(
          color: selected ? primary : Colors.black87,
          fontSize: 13,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? primary : Colors.grey[300]!),
        ),
        showCheckmark: false,
      ),
    );
  }

  void _openProductEditor(BuildContext context, MenuItem? item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductEditorDialog(item: item),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      separatorBuilder: (c, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MenuItem item;
  final bool isReorderable;
  final int? dragIndex;

  const _ProductCard({super.key, required this.item, this.isReorderable = false, this.dragIndex});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context);
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);

    final displayName = lang.isArabic ? item.nameAr : item.nameEn;
    final displayDesc = lang.isArabic ? item.descriptionAr : item.descriptionEn;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Product Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (c, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(width: 72, height: 72, color: Colors.white),
                      ),
                      errorWidget: (c, url, e) => Container(
                        width: 72,
                        height: 72,
                        color: accentColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: accentColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.fastfood_rounded, color: accentColor, size: 32),
                    ),
            ),
            const SizedBox(width: 10),

            // Product Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (displayDesc.isNotEmpty)
                    Text(
                      displayDesc,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.discountPrice != null && item.discountPrice! > 0) ...[
                        Text(
                          '${item.discountPrice} AED',
                          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${item.price} AED',
                          style: const TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 11,
                          ),
                        ),
                      ] else
                        Text(
                          '${item.price} AED',
                          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Switch & Actions
            Column(
              children: [
                SizedBox(
                  height: 32,
                  child: Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: item.isAvailable,
                      activeThumbColor: primaryColor,
                      onChanged: (v) => provider.toggleAvailability(item),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: accentColor, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _openEditor(context),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDelete(context, lang),
                    ),
                    if (isReorderable && dragIndex != null) ...[
                      const SizedBox(width: 4),
                      ReorderableDragStartListener(
                        index: dragIndex!,
                        child: const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 22),
                      ),
                    ]
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductEditorDialog(item: item),
    );
  }

  void _confirmDelete(BuildContext context, LanguageProvider lang) {
    final displayName = lang.isArabic ? item.nameAr : item.nameEn;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.getText(ar: 'حذف المنتج', en: 'Delete Product')),
        content: Text(lang.getText(
          ar: 'هل أنت متأكد من حذف "$displayName"؟',
          en: 'Are you sure you want to delete "$displayName"?',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang.getText(ar: 'إلغاء', en: 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).deleteProduct(item);
              Navigator.pop(ctx);
            },
            child: Text(lang.getText(ar: 'حذف', en: 'Delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ProductEditorDialog extends StatefulWidget {
  final MenuItem? item;
  const ProductEditorDialog({super.key, this.item});

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idC, _nameArC, _nameEnC, _descArC, _descEnC, _priceC, _discountC, _catC;
  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _existingUrl;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _idC = TextEditingController(text: item?.id ?? 'pr_${DateTime.now().millisecondsSinceEpoch}');
    _nameArC = TextEditingController(text: item?.nameAr ?? '');
    _nameEnC = TextEditingController(text: item?.nameEn ?? '');
    _descArC = TextEditingController(text: item?.descriptionAr ?? '');
    _descEnC = TextEditingController(text: item?.descriptionEn ?? '');
    _priceC = TextEditingController(text: item != null ? item.price.toString() : '');
    _discountC = TextEditingController(text: item?.discountPrice != null ? item!.discountPrice.toString() : '');
    _catC = TextEditingController(text: item?.category ?? '');
    _existingUrl = item?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      setState(() {
        _imageBytes = bytes;
        _imageExtension = ext;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isEdit = widget.item != null;
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);

    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 550,
        constraints: BoxConstraints(maxHeight: size.height * 0.88),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? lang.getText(ar: 'تعديل المنتج', en: 'Edit Product') : lang.getText(ar: 'إضافة منتج جديد', en: 'New Product'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20),

            // Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Image Picker Box
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_imageBytes != null)
                                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imageBytes!, width: 130, height: 130, fit: BoxFit.cover))
                              else if (_existingUrl != null && _existingUrl!.isNotEmpty)
                                ClipRRect(borderRadius: BorderRadius.circular(16), child: CachedNetworkImage(imageUrl: _existingUrl!, width: 130, height: 130, fit: BoxFit.cover))
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_photo_alternate_outlined, size: 36, color: accentColor),
                                    const SizedBox(height: 6),
                                    Text(
                                      lang.getText(ar: 'صورة المنتج', en: 'Product Photo'),
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Arabic and English Names
                      _buildField(_nameArC, lang.getText(ar: 'الاسم بالعربية *', en: 'Arabic Name *'), true),
                      _buildField(_nameEnC, lang.getText(ar: 'الاسم بالإنجليزية *', en: 'English Name *'), false),

                      // Descriptions
                      _buildField(_descArC, lang.getText(ar: 'الوصف بالعربية', en: 'Arabic Description'), true, lines: 2, isRequired: false),
                      _buildField(_descEnC, lang.getText(ar: 'الوصف بالإنجليزية', en: 'English Description'), false, lines: 2, isRequired: false),

                      // Price and Category Selection
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(_priceC, lang.getText(ar: 'السعر (AED) *', en: 'Price (AED) *'), false, isNum: true),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(_discountC, lang.getText(ar: 'سعر الخصم', en: 'Discount Price'), false, isNum: true, isRequired: false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Enhanced Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: provider.categories.any((c) => c.id == _catC.text)
                            ? _catC.text
                            : (provider.categories.isNotEmpty ? provider.categories.first.id : null),
                        decoration: InputDecoration(
                          labelText: lang.getText(ar: 'فئة المنتج *', en: 'Category *'),
                          prefixIcon: const Icon(Icons.category_outlined, color: accentColor, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                        ),
                        items: provider.categories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    lang.isArabic ? c.nameAr : c.nameEn,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _catC.text = v);
                        },
                        validator: (v) => (v == null || v.isEmpty) ? lang.getText(ar: 'يرجى اختيار الفئة', en: 'Select category') : null,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(lang.getText(ar: 'إلغاء', en: 'Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(lang.getText(ar: 'حفظ المنتج', en: 'Save Product'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    bool isAr, {
    int lines = 1,
    bool isNum = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        maxLines: lines,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
        validator: (v) {
          if (isRequired && (v == null || v.trim().isEmpty)) {
            return 'مطلوب';
          }
          return null;
        },
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final item = MenuItem(
        id: _idC.text,
        nameAr: _nameArC.text.trim(),
        nameEn: _nameEnC.text.trim().isEmpty ? _nameArC.text.trim() : _nameEnC.text.trim(),
        descriptionAr: _descArC.text.trim(),
        descriptionEn: _descEnC.text.trim(),
        price: double.tryParse(_priceC.text.trim()) ?? 0.0,
        discountPrice: double.tryParse(_discountC.text.trim()),
        category: _catC.text.isEmpty && provider.categories.isNotEmpty ? provider.categories.first.id : _catC.text,
        imageUrl: _existingUrl ?? '',
        isAvailable: widget.item?.isAvailable ?? true,
        order: widget.item?.order ?? 999,
        createdAt: widget.item?.createdAt,
      );

      await provider.saveProduct(item, _imageBytes, _imageExtension);
      if (mounted) Navigator.pop(context);
    }
  }
}
