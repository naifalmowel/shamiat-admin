import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/admin_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/menu_item.dart';
import '../../widgets/gallery_picker.dart';

enum ProductSortOption {
  manual,
  newest,
  priceLowToHigh,
  priceHighToLow,
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

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // Filter products
    List<MenuItem> filtered = provider.products.where((p) {
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          p.nameAr.toLowerCase().contains(query) ||
          p.nameEn.toLowerCase().contains(query);
      final matchesCat = _selectedCategory == 'الكل' || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    // Sort products based on selected option
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

    final isManualActive = _sortOption == ProductSortOption.manual && _selectedCategory != 'الكل' && _searchQuery.isEmpty;

    return Column(
      children: [
        // --- Top Bar ---
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
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort_rounded, color: primaryColor, size: 20),
                          if (!isMobile) ...[
                            const SizedBox(width: 8),
                            Text(lang.getText(ar: 'ترتيب', en: 'Sort'), style: const TextStyle(fontSize: 12, color: primaryColor)),
                          ]
                        ],
                      ),
                    ),
                    onSelected: (opt) => setState(() => _sortOption = opt),
                    itemBuilder: (context) => [
                      _buildSortItem(ProductSortOption.manual, Icons.touch_app_rounded, lang.getText(ar: 'يدوي', en: 'Manual'), lang),
                      _buildSortItem(ProductSortOption.newest, Icons.new_releases_rounded, lang.getText(ar: 'الأحدث', en: 'Newest'), lang),
                      _buildSortItem(ProductSortOption.priceLowToHigh, Icons.arrow_downward_rounded, lang.getText(ar: 'الأقل سعراً', en: 'Cheapest'), lang),
                      _buildSortItem(ProductSortOption.priceHighToLow, Icons.arrow_upward_rounded, lang.getText(ar: 'الأعلى سعراً', en: 'Highest Price'), lang),
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

              // Category Filters
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
        if (isManualActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.getText(
                      ar: 'يمكنك إعادة ترتيب المنتجات عبر السحب والإفلات من أيقونة المقبض',
                      en: 'You can reorder products via drag and drop from the handle icon',
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

        // --- Products List (Always Reorderable ListView with constrained width) ---
        Expanded(
          child: provider.isInitialLoading
              ? _buildShimmerLoading()
              : filtered.isEmpty
                  ? Center(child: Text(lang.getText(ar: 'لا توجد منتجات', en: 'No products found')))
                  : Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          onReorder: (oldIdx, newIdx) {
                            if (isManualActive) {
                              provider.reorderProductsInList(filtered, oldIdx, newIdx);
                            }
                          },
                          buildDefaultDragHandles: false, // Custom handle for better control
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              key: ValueKey(filtered[index].id),
                              item: filtered[index],
                              isReorderable: isManualActive,
                              dragIndex: index,
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  PopupMenuItem<ProductSortOption> _buildSortItem(ProductSortOption val, IconData icon, String label, LanguageProvider lang) {
    final isSelected = _sortOption == val;
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? const Color(0xFF1B4332) : Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildCatChip(String id, bool selected, Color accent, Color primary, {String? label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label ?? id),
        selected: selected,
        onSelected: (v) => setState(() {
          _selectedCategory = id;
        }),
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
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => ProductEditorDialog(item: item));
  }

  Widget _buildShimmerLoading() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: 8,
          separatorBuilder: (c, i) => const SizedBox(height: 10),
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
          ),
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
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey[200]!)),
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
                      errorWidget: (c, url, e) => Container(width: 72, height: 72, color: accentColor.withValues(alpha: 0.1), child: const Icon(Icons.broken_image, color: Colors.grey, size: 30)),
                    )
                  : Container(width: 72, height: 72, color: accentColor.withValues(alpha: 0.1), child: const Icon(Icons.fastfood_rounded, color: accentColor, size: 32)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (displayDesc.isNotEmpty) Text(displayDesc, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.discountPrice != null && item.discountPrice! > 0) ...[
                        Text('${item.discountPrice} AED', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(width: 6),
                        Text('${item.price} AED', style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough, fontSize: 11)),
                      ] else
                        Text('${item.price} AED', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(height: 32, child: Transform.scale(scale: 0.75, child: Switch(value: item.isAvailable, activeThumbColor: primaryColor, onChanged: (v) => provider.toggleAvailability(item)))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_note_rounded, color: accentColor, size: 22), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _openEditor(context)),
                    const SizedBox(width: 6),
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _confirmDelete(context, lang)),
                    if (isReorderable && dragIndex != null) ...[
                      const SizedBox(width: 4),
                      ReorderableDragStartListener(index: dragIndex!, child: const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 22))
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
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => ProductEditorDialog(item: item));
  }

  void _confirmDelete(BuildContext context, LanguageProvider lang) {
    final displayName = lang.isArabic ? item.nameAr : item.nameEn;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.getText(ar: 'حذف المنتج', en: 'Delete Product')),
        content: Text(lang.getText(ar: 'هل أنت متأكد من حذف "$displayName"؟', en: 'Are you sure you want to delete "$displayName"?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.getText(ar: 'إلغاء', en: 'Cancel'))),
          TextButton(onPressed: () { Provider.of<AdminProvider>(context, listen: false).deleteProduct(item); Navigator.pop(ctx); }, child: Text(lang.getText(ar: 'حذف', en: 'Delete'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _OptionChoiceItem {
  TextEditingController nameArC;
  TextEditingController nameEnC;
  TextEditingController priceC;

  _OptionChoiceItem({
    String nameAr = '',
    String nameEn = '',
    double price = 0.0,
  })  : nameArC = TextEditingController(text: nameAr),
        nameEnC = TextEditingController(text: nameEn),
        priceC = TextEditingController(text: price > 0 ? price.toString() : '');

  void dispose() {
    nameArC.dispose();
    nameEnC.dispose();
    priceC.dispose();
  }

  OptionChoice toChoice() {
    return OptionChoice(
      nameAr: nameArC.text.trim(),
      nameEn: nameEnC.text.trim().isEmpty ? nameArC.text.trim() : nameEnC.text.trim(),
      price: double.tryParse(priceC.text.trim()) ?? 0.0,
    );
  }
}

class _OptionGroupItem {
  TextEditingController titleArC;
  TextEditingController titleEnC;
  String type; // 'single' or 'multiple'
  List<_OptionChoiceItem> choices;

  _OptionGroupItem({
    String titleAr = '',
    String titleEn = '',
    this.type = 'single',
    List<_OptionChoiceItem>? choices,
  })  : titleArC = TextEditingController(text: titleAr),
        titleEnC = TextEditingController(text: titleEn),
        choices = choices ?? [];

  void dispose() {
    titleArC.dispose();
    titleEnC.dispose();
    for (var c in choices) {
      c.dispose();
    }
  }

  MenuItemOptionGroup toOptionGroup() {
    return MenuItemOptionGroup(
      titleAr: titleArC.text.trim(),
      titleEn: titleEnC.text.trim().isEmpty ? titleArC.text.trim() : titleEnC.text.trim(),
      type: type,
      choices: choices
          .map((c) => c.toChoice())
          .where((c) => c.nameAr.isNotEmpty || c.nameEn.isNotEmpty)
          .toList(),
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
  List<_OptionGroupItem> _optionGroups = [];
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

    _optionGroups = item?.options.map((group) {
      return _OptionGroupItem(
        titleAr: group.titleAr,
        titleEn: group.titleEn,
        type: group.type,
        choices: group.choices.map((choice) => _OptionChoiceItem(
          nameAr: choice.nameAr,
          nameEn: choice.nameEn,
          price: choice.price,
        )).toList(),
      );
    }).toList() ?? [];
  }

  @override
  void dispose() {
    _idC.dispose();
    _nameArC.dispose();
    _nameEnC.dispose();
    _descArC.dispose();
    _descEnC.dispose();
    _priceC.dispose();
    _discountC.dispose();
    _catC.dispose();
    for (var g in _optionGroups) {
      g.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      setState(() { _imageBytes = bytes; _imageExtension = ext; _existingUrl = null; });
    }
  }

  Future<void> _pickFromGallery() async {
    final url = await showDialog<String>(
      context: context,
      builder: (c) => const GalleryPicker(folder: 'products'),
    );
    if (url != null) {
      setState(() {
        _existingUrl = url;
        _imageBytes = null;
        _imageExtension = null;
      });
    }
  }

  void _showImageSourceSheet() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.upload_file_rounded, color: Color(0xFFBC8A5F)),
            title: Text(lang.getText(ar: 'رفع صورة جديدة من الهاتف', en: 'Upload from Device')),
            onTap: () { Navigator.pop(ctx); _pickImage(); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1B4332)),
            title: Text(lang.getText(ar: 'اختيار من الصور المرفوعة مسبقاً', en: 'Choose from Gallery')),
            onTap: () { Navigator.pop(ctx); _pickFromGallery(); },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
        width: isMobile ? double.infinity : 600,
        constraints: BoxConstraints(maxHeight: size.height * 0.88),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEdit ? lang.getText(ar: 'تعديل المنتج', en: 'Edit Product') : lang.getText(ar: 'إضافة منتج جديد', en: 'New Product'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Centered Interactive Image Box
                      Center(
                        child: GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!, width: 2),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                ),
                                child: _imageBytes != null
                                    ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                                    : (_existingUrl != null && _existingUrl!.isNotEmpty)
                                        ? ClipRRect(borderRadius: BorderRadius.circular(18), child: CachedNetworkImage(imageUrl: _existingUrl!, fit: BoxFit.cover))
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey),
                                              const SizedBox(height: 8),
                                              Text(lang.getText(ar: 'أضف صورة', en: 'Add Photo'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFFBC8A5F), shape: BoxShape.circle),
                                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildField(_nameArC, lang.getText(ar: 'الاسم بالعربية *', en: 'Arabic Name *'), true),
                      _buildField(_nameEnC, lang.getText(ar: 'الاسم بالإنجليزية *', en: 'English Name *'), false),
                      _buildField(_descArC, lang.getText(ar: 'الوصف بالعربية', en: 'Arabic Description'), true, lines: 2, isRequired: false),
                      _buildField(_descEnC, lang.getText(ar: 'الوصف بالإنجليزية', en: 'English Description'), false, lines: 2, isRequired: false),
                      Row(
                        children: [
                          Expanded(child: _buildField(_priceC, lang.getText(ar: 'السعر (AED) *', en: 'Price (AED) *'), false, isNum: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField(_discountC, lang.getText(ar: 'سعر الخصم', en: 'Discount Price'), false, isNum: true, isRequired: false)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: provider.categories.any((c) => c.id == _catC.text) ? _catC.text : (provider.categories.isNotEmpty ? provider.categories.first.id : null),
                        decoration: InputDecoration(labelText: lang.getText(ar: 'فئة المنتج *', en: 'Category *'), prefixIcon: const Icon(Icons.category_outlined, color: accentColor, size: 20), filled: true, fillColor: Colors.grey[50], contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!))),
                        items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(lang.isArabic ? c.nameAr : c.nameEn, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _catC.text = v); },
                        validator: (v) => (v == null || v.isEmpty) ? lang.getText(ar: 'يرجى اختيار الفئة', en: 'Select category') : null,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      // --- Item Options & Variations Section ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                lang.getText(ar: 'الخيارات والإضافات', en: 'Options & Variations'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _optionGroups.add(_OptionGroupItem(
                                  choices: [_OptionChoiceItem()],
                                ));
                              });
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(lang.getText(ar: 'إضافة مجموعة', en: 'Add Group')),
                            style: TextButton.styleFrom(foregroundColor: accentColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_optionGroups.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Center(
                            child: Text(
                              lang.getText(
                                ar: 'لا توجد خيارات مضافة لهذا المنتج. اضغط "إضافة مجموعة" لإضافة خيارات مثل (درجة الحرارة، الحجم، الإضافات...)',
                                en: 'No options added for this product. Click "Add Group" to add options like (Spiciness, Size, Extras...)',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _optionGroups.length,
                          itemBuilder: (context, gIndex) {
                            final group = _optionGroups[gIndex];
                            return _buildOptionGroupCard(group, gIndex, lang, primaryColor, accentColor);
                          },
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(lang.getText(ar: 'إلغاء', en: 'Cancel')))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: provider.isLoading ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: provider.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(lang.getText(ar: 'حفظ المنتج', en: 'Save Product')))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionGroupCard(_OptionGroupItem group, int gIndex, LanguageProvider lang, Color primaryColor, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${gIndex + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lang.getText(ar: 'مجموعة خيارات #${gIndex + 1}', en: 'Option Group #${gIndex + 1}'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  tooltip: lang.getText(ar: 'حذف المجموعة', en: 'Delete Group'),
                  onPressed: () {
                    setState(() {
                      _optionGroups.removeAt(gIndex).dispose();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMiniField(
                    group.titleArC,
                    lang.getText(ar: 'عنوان المجموعة (عربي) *', en: 'Group Title (Arabic) *'),
                    isAr: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniField(
                    group.titleEnC,
                    lang.getText(ar: 'عنوان المجموعة (إنجليزي)', en: 'Group Title (English)'),
                    isAr: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: group.type,
              decoration: InputDecoration(
                labelText: lang.getText(ar: 'نوع الاختيار *', en: 'Selection Type *'),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
              items: [
                DropdownMenuItem(
                  value: 'single',
                  child: Text(
                    lang.getText(ar: 'إجباري اختيار واحد (Single Selection)', en: 'Single Selection (Required 1)'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                DropdownMenuItem(
                  value: 'multiple',
                  child: Text(
                    lang.getText(ar: 'متعدد اختياري (Multiple Selection)', en: 'Multiple Selection (Optional)'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    group.type = v;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.getText(ar: 'قائمة الاختيارات (Choices):', en: 'Choices List:'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[800]),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      group.choices.add(_OptionChoiceItem());
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 16, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          lang.getText(ar: 'إضافة خيار', en: 'Add Choice'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (group.choices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  lang.getText(ar: 'انقر على "إضافة خيار" لإنشاء خيارات مثل (حار، بارد...)', en: 'Click "Add Choice" to create choices like (Hot, Cold...)'),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.choices.length,
                itemBuilder: (context, cIndex) {
                  final choice = group.choices[cIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildMiniField(
                            choice.nameArC,
                            lang.getText(ar: 'الاسم بالعربي', en: 'Arabic Name'),
                            isAr: true,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 3,
                          child: _buildMiniField(
                            choice.nameEnC,
                            lang.getText(ar: 'الاسم بالإنجليزي', en: 'English Name'),
                            isAr: false,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: _buildMiniField(
                            choice.priceC,
                            lang.getText(ar: 'السعر الإضافي', en: 'Extra Price'),
                            isAr: false,
                            isNum: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              group.choices.removeAt(cIndex).dispose();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniField(TextEditingController c, String label, {bool isAr = false, bool isNum = false}) {
    return TextFormField(
      controller: c,
      textAlign: isAr ? TextAlign.right : TextAlign.left,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, bool isAr, {int lines = 1, bool isNum = false, bool isRequired = true}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, textAlign: isAr ? TextAlign.right : TextAlign.left, maxLines: lines, keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!))), validator: (v) { if (isRequired && (v == null || v.trim().isEmpty)) { return 'مطلوب'; } return null; }));
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final optionsList = _optionGroups
          .map((g) => g.toOptionGroup())
          .where((g) => g.titleAr.isNotEmpty || g.titleEn.isNotEmpty)
          .toList();

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
        options: optionsList,
      );
      await provider.saveProduct(item, _imageBytes, _imageExtension);
      if (mounted) Navigator.pop(context);
    }
  }
}
