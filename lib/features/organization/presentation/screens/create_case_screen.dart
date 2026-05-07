import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/org_case.dart';
import '../../../user/domain/entities/category.dart';
import '../../../user/domain/entities/governorate.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/repositories/organization_repository.dart';

// Light of Impact - Warm Hopeful Color System
const Color backgroundOffWhite = Color(0xFFF9FAFB);
const Color softBlueTint = Color(0xFFF3F8FC);
const Color friendlyBlue = Color(0xFF1E7ABF);
const Color softTeal = Color(0xFF3BB3A9);
const Color textDark = Color(0xFF1F2937);
const Color textMedium = Color(0xFF6B7280);
const Color textLight = Color(0xFF9CA3AF);
const Color cardWhite = Color(0xFFFFFFFF);
const Color borderLight = Color(0xFFE5E7EB);
const Color inputFill = Color(0xFFF7FAFC);

class CreateCaseScreen extends StatefulWidget {
  final OrgCase? existing;
  const CreateCaseScreen({super.key, this.existing});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
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

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _descriptionController.text = widget.existing!.description;
      _priority = widget.existing!.priority;
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
    govs.fold((_) => _governorates = [], (v) => _governorates = v);

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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null || _governorateId == null) {
      _toast('يرجى اختيار القسم والمحافظة', Colors.orange);
      return;
    }

    setState(() => _submitting = true);
    final repo = locator<OrganizationRepository>();
    final imagePaths = _selectedImages.map((e) => e.path).toList();

    final isEdit = widget.existing != null;
    final result = isEdit
        ? await repo.updateCase(
            caseId: widget.existing!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            images: imagePaths,
          )
        : await repo.createCase(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            categoryId: _categoryId!,
            governorateId: _governorateId!,
            priority: _priority,
            images: imagePaths,
          );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold((f) => _toast('فشل: ${f.message}', Colors.red), (_) {
      _toast(
        isEdit ? 'تم تعديل الحالة' : 'تم إنشاء الحالة (قيد المراجعة)',
        softTeal,
      );
      Navigator.pop(context, true);
    });
  }

  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          widget.existing != null ? 'تعديل الحالة' : 'إضافة حالة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int>(
                    value: _governorateId,
                    label: 'المحافظة',
                    items: _governorates
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _governorateId = v),
                  ),
                  const SizedBox(height: 12),
                  _dropdown<String>(
                    value: _priority,
                    label: 'الأولوية',
                    items: const [
                      DropdownMenuItem(value: 'urgent', child: Text('عاجل')),
                      DropdownMenuItem(value: 'high', child: Text('مرتفع')),
                      DropdownMenuItem(value: 'medium', child: Text('متوسط')),
                      DropdownMenuItem(value: 'low', child: Text('منخفض')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 'medium'),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('الصور'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: softBlueTint,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: friendlyBlue.withAlpha(30),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderLight),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: friendlyBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'اضغط لإضافة صور (اختياري)',
                              style: TextStyle(
                                color: textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _submitting ? null : _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [friendlyBlue, softTeal],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: friendlyBlue.withAlpha(30),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.existing != null ? 'حفظ' : 'إنشاء',
                                style: const TextStyle(
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: friendlyBlue,
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: friendlyBlue, width: 1.5),
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
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: friendlyBlue, width: 1.5),
        ),
      ),
    );
  }
}
