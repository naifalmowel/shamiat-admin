import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/admin_provider.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    // Filter products outside the list to keep it fast
    final filtered = provider.products.where((p) {
      final matchesSearch = _searchQuery.isEmpty || 
          p.nameAr.contains(_searchQuery) ||
          p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'الكل' || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Column(
      children: [
        // --- Sticky Top Bar & Filters ---
        Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                      height: 45,
                      child: TextField(
                        textAlign: TextAlign.right,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن منتج...',
                          prefixIcon: const Icon(Icons.search, color: primaryColor, size: 20),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
                  const SizedBox(width: 10),
                  Material(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _openProductEditor(context, null),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.add_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  children: [
                    _buildCatChip('الكل', _selectedCategory == 'الكل', accentColor, primaryColor),
                    ...provider.categories.map((c) => 
                      _buildCatChip(c.id, _selectedCategory == c.id, accentColor, primaryColor, label: c.nameAr)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- Products List Optimized ---
        Expanded(
          child: provider.isLoading && provider.products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty 
                  ? const Center(child: Text('لا توجد منتجات تطابق بحثك'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: _ProductCard(
                            key: ValueKey(filtered[index].id), 
                            item: filtered[index]
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
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Text(label ?? id),
        selected: selected,
        onSelected: (v) => setState(() => _selectedCategory = id),
        selectedColor: primary.withOpacity(0.1),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? primary : Colors.black54,
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
}

class _ProductCard extends StatelessWidget {
  final MenuItem item;
  const _ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    const primaryColor = Color(0xFF1B4332);
    const accentColor = Color(0xFFBC8A5F);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: isMobile ? 80 : 90,
                      height: isMobile ? 80 : 90,
                      fit: BoxFit.cover,
                      placeholder: (c, url) => Container(color: Colors.grey[100]),
                      errorWidget: (c, url, e) => const Icon(Icons.broken_image),
                    )
                  : Container(
                      width: isMobile ? 80 : 90,
                      height: isMobile ? 80 : 90,
                      color: accentColor.withOpacity(0.1),
                      child: const Icon(Icons.fastfood, color: accentColor),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.nameAr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.nameEn, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text('${item.price} AED', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 15)),
                ],
              ),
            ),
            const VerticalDivider(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 35,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: item.isAvailable,
                      activeColor: primaryColor,
                      onChanged: (v) => provider.toggleAvailability(item),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: accentColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _openEditor(context),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDelete(context),
                    ),
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
      builder: (ctx) => ProductEditorDialog(item: item),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف "${item.nameAr}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AdminProvider>(
                context,
                listen: false,
              ).deleteProduct(item);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
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
  late TextEditingController _idC,
      _nameArC,
      _nameEnC,
      _descArC,
      _descEnC,
      _priceC,
      _catC;
  File? _imageFile;
  String? _existingUrl;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _idC = TextEditingController(
      text: item?.id ?? 'pr_${DateTime.now().millisecondsSinceEpoch}',
    );
    _nameArC = TextEditingController(text: item?.nameAr ?? '');
    _nameEnC = TextEditingController(text: item?.nameEn ?? '');
    _descArC = TextEditingController(text: item?.descriptionAr ?? '');
    _descEnC = TextEditingController(text: item?.descriptionEn ?? '');
    _priceC = TextEditingController(text: item?.price.toString() ?? '');
    _catC = TextEditingController(text: item?.category ?? '');
    _existingUrl = item?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    final isEdit = widget.item != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'تعديل المنتج' : 'إضافة منتج جديد',
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : (_existingUrl != null && _existingUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: _existingUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40),
                              Text('اضف صورة'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(_nameArC, 'الاسم (عربي)', true),
                _buildField(_nameEnC, 'الاسم (إنجليزي)', false),
                _buildField(_descArC, 'الوصف (عربي)', true, lines: 2),
                _buildField(_descEnC, 'الوصف (إنجليزي)', false, lines: 2),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(_priceC, 'السعر', false, isNum: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value:
                            provider.categories.any((c) => c.id == _catC.text)
                            ? _catC.text
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(),
                        ),
                        items: provider.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.nameAr),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => _catC.text = v ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: provider.isLoading ? null : _save,
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : const Text('حفظ المنتج'),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    bool isAr, {
    int lines = 1,
    bool isNum = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        maxLines: lines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final item = MenuItem(
        id: _idC.text,
        nameAr: _nameArC.text,
        nameEn: _nameEnC.text,
        descriptionAr: _descArC.text,
        descriptionEn: _descEnC.text,
        price: double.tryParse(_priceC.text) ?? 0.0,
        category: _catC.text,
        imageUrl: _existingUrl ?? '',
        isAvailable: widget.item?.isAvailable ?? true,
      );
      await Provider.of<AdminProvider>(
        context,
        listen: false,
      ).saveProduct(item, _imageFile);
      if (mounted) Navigator.pop(context);
    }
  }
}
