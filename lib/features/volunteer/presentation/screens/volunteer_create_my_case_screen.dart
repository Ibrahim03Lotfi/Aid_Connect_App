import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../organization/domain/entities/org_case.dart';
import '../../../user/domain/entities/category.dart';
import '../../../user/domain/entities/governorate.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerCreateMyCaseScreen extends StatefulWidget {
  final OrgCase? existing;
  const VolunteerCreateMyCaseScreen({super.key, this.existing});

  @override
  State<VolunteerCreateMyCaseScreen> createState() =>
      _VolunteerCreateMyCaseScreenState();
}

class _VolunteerCreateMyCaseScreenState
  extends State<VolunteerCreateMyCaseScreen> {
  static const Set<String> _syrianGovernorates = {
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'الرقة',
    'دير الزور',
    'الحسكة',
    'درعا',
    'السويداء',
    'القنيطرة',
  };

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;

  List<Category> _categories = [];
  List<Governorate> _governorates = [];

  int? _categoryId;
  int? _governorateId;
  String _priority = 'medium';

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<String> _existingImageUrls = [];

  // Dynamic Theme Colors
  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get _backgroundOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
  Color get _softBlueTint => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  Color get _friendlyBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E7ABF);
  Color get _softTeal => const Color(0xFF10B981);
  Color get _textDark => _isDark ? Colors.white : const Color(0xFF0F172A);
  Color get _textMedium => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _textLight => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get _cardWhite => _isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
  Color get _borderLight => _isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
  Color get _inputFill => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _descriptionController.text = widget.existing!.description;
      _priority = widget.existing!.priority;
      _existingImageUrls.addAll(widget.existing!.images);
      if (_existingImageUrls.isEmpty && widget.existing!.thumbnail != null) {
        _existingImageUrls.add(widget.existing!.thumbnail!);
      }
    }
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    setState(() => _loading = true);
    final userRepo = locator<UserRepository>();
    final cats = await userRepo.getCategories();
    final govs = await userRepo.getGovernorates();

    if (!mounted) return;

    cats.fold((_) => _categories = [], (v) => _categories = v);
    govs.fold(
      (_) => _governorates = [],
      (v) => _governorates = v
          .where((g) => _syrianGovernorates.contains(g.name.trim()))
          .toList(),
    );

    if (widget.existing != null) {
      _categoryId = _categories
          .where((c) => c.name == widget.existing!.category)
          .map((c) => c.id)
          .cast<int?>()
          .firstWhere((e) => e != null, orElse: () => null);
      _governorateId = _governorates
          .where((g) => g.name == widget.existing!.governorate)
          .map((g) => g.id)
          .cast<int?>()
          .firstWhere((e) => e != null, orElse: () => null);
    }

    setState(() => _loading = false);
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 85);
    if (!mounted) return;
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null || _governorateId == null) {
      _toast('يرجى اختيار القسم والمحافظة', Colors.orange);
      return;
    }

    setState(() => _submitting = true);
    final repo = locator<VolunteerRepository>();
    final imagePaths = _selectedImages.map((e) => e.path).toList();

    final isEdit = widget.existing != null;
    final result = isEdit
        ? await repo.updateMyCase(
            caseId: widget.existing!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            categoryId: _categoryId!,
            governorateId: _governorateId!,
            priority: _priority,
            existingImageUrls: _existingImageUrls,
            imagePaths: imagePaths,
          )
        : await repo.createMyCase(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            categoryId: _categoryId!,
            governorateId: _governorateId!,
            priority: _priority,
            imagePaths: imagePaths,
          );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (f) => _toast('فشل: ${f.message}', Colors.red),
      (_) {
        _toast(isEdit ? 'تم تعديل الحالة' : 'تم إنشاء الحالة (قيد المراجعة)',
            _softTeal);
        Navigator.pop(context, true);
      },
    );
  }

  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: _isDark ? AppColors.darkCard : _backgroundOffWhite,
        elevation: 0,
        title: Text(
          widget.existing != null ? 'تعديل الحالة' : 'إضافة حالة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_friendlyBlue),
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _sectionTitle('معلومات الحالة'),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _titleController,
                    label: 'العنوان',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _descriptionController,
                    label: 'الوصف',
                    maxLines: 5,
                    validator: (v) => (v == null || v.trim().length < 20)
                        ? 'الوصف يجب أن يكون 20 حرف على الأقل'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int>(
                    value: _categoryId,
                    label: 'القسم',
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int>(
                    value: _governorateId,
                    label: 'المحافظة',
                    items: _governorates
                        .map((g) =>
                            DropdownMenuItem(
                              value: g.id,
                              child: Text(
                                g.name,
                                style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _governorateId = v),
                  ),
                  const SizedBox(height: 12),
                  _dropdown<String>(
                    value: _priority,
                    label: 'الأولوية',
                    items: [
                      DropdownMenuItem(
                        value: 'urgent',
                        child: Text(
                          'عاجل',
                          style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.w700),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'high',
                        child: Text(
                          'مرتفع',
                          style: GoogleFonts.cairo(color: Colors.orange, fontWeight: FontWeight.w700),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text(
                          'متوسط',
                          style: GoogleFonts.cairo(color: Colors.amber.shade700, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'low',
                        child: Text(
                          'منخفض',
                          style: GoogleFonts.cairo(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _priority = v ?? 'medium'),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('الصور والمرفقات'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _softBlueTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _friendlyBlue.withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _borderLight),
                            ),
                            child: Icon(Icons.add_photo_alternate_outlined,
                                color: _friendlyBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'اضغط لإضافة صور (اختياري)',
                              style: GoogleFonts.cairo(
                                color: _textMedium,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_existingImageUrls.isNotEmpty) ...[
                    Text(
                      'الصور الحالية',
                      style: GoogleFonts.cairo(
                        color: _textMedium,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _existingImageUrls.length,
                      itemBuilder: (context, index) {
                        final imgUrl = _existingImageUrls[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: _softBlueTint,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: _textLight,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final img = _selectedImages[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(img.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _submitting ? null : _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_friendlyBlue, _softTeal],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: _friendlyBlue.withAlpha(30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.existing != null ? 'حفظ التعديلات' : 'إنشاء الحالة',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _friendlyBlue,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: _textMedium, fontSize: 13),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: _cardWhite,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: _textMedium, fontSize: 13),
        filled: true,
        fillColor: _inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
        ),
      ),
    );
  }
}
