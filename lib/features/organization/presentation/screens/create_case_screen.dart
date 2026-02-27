import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateCaseScreen extends StatefulWidget {
  const CreateCaseScreen({super.key});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  
  int? _selectedCategory;
  int? _selectedGovernorate;
  String? _selectedPriority;
  
  bool _isLoading = false;
  int _currentStep = 0;
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'إغاثة عاجلة'},
    {'id': 2, 'name': 'مساعدات غذائية'},
    {'id': 3, 'name': 'علاج طبي'},
    {'id': 4, 'name': 'تعليم'},
    {'id': 5, 'name': 'سكن'},
    {'id': 6, 'name': 'ملابس'},
    {'id': 7, 'name': 'مياه'},
    {'id': 8, 'name': 'دعم نفسي'},
  ];
  
  final List<Map<String, dynamic>> _governorates = [
    {'id': 1, 'name': 'القاهرة'},
    {'id': 2, 'name': 'الإسكندرية'},
    {'id': 3, 'name': 'الجيزة'},
    {'id': 4, 'name': 'القليوبية'},
    {'id': 5, 'name': 'المنصورة'},
    {'id': 6, 'name': 'أسوان'},
    {'id': 7, 'name': 'الأقصر'},
    {'id': 8, 'name': 'بورسعيد'},
    {'id': 9, 'name': 'الإسماعيلية'},
    {'id': 10, 'name': 'السويس'},
  ];
  
  final List<Map<String, dynamic>> _priorities = [
    {'value': 'urgent', 'name': 'عاجل', 'color': Colors.red},
    {'value': 'high', 'name': 'مرتفع', 'color': Colors.orange},
    {'value': 'medium', 'name': 'متوسط', 'color': Colors.yellow.shade700},
    {'value': 'low', 'name': 'منخفض', 'color': Colors.green},
  ];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedGovernorate == null || _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار القسم والمحافظة والأولوية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحالة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة حالة جديدة'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _currentStep == 2 ? _submitForm : _nextStep,
          onStepCancel: _previousStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentStep == 2 ? 'إنشاء الحالة' : 'التالي'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('السابق'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('المعلومات'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildBasicInfoStep(),
            ),
            Step(
              title: const Text('التصنيف'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildClassificationStep(),
            ),
            Step(
              title: const Text('الصور'),
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.indexed : StepState.indexed,
              content: _buildImagesStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان الحالة *',
              hintText: 'مثال: مساعدة عاجلة لعائلة متضررة',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال عنوان الحالة';
              }
              if (value.length < 5) {
                return 'العنوان يجب أن يكون 5 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'وصف الحالة *',
              hintText: 'صف الحالة بالتفصيل...',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            minLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال وصف الحالة';
              }
              if (value.length < 20) {
                return 'الوصف يجب أن يكون 20 حرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'مستوى الأولوية *',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _priorities.map((priority) {
              final isSelected = _selectedPriority == priority['value'];
              return ChoiceChip(
                label: Text(priority['name'] as String),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? priority['value'] as String : null;
                  });
                },
                selectedColor: (priority['color'] as Color).withAlpha(30),
                labelStyle: TextStyle(
                  color: isSelected ? priority['color'] as Color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'القسم *',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.category),
              title: Text(
                _selectedCategory != null
                    ? _categories.firstWhere((c) => c['id'] == _selectedCategory)['name']
                    : 'اختر القسم',
                style: TextStyle(
                  color: _selectedCategory != null ? Colors.black : Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showCategoryPicker(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'المحافظة *',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(
                _selectedGovernorate != null
                    ? _governorates.firstWhere((g) => g['id'] == _selectedGovernorate)['name']
                    : 'اختر المحافظة',
                style: TextStyle(
                  color: _selectedGovernorate != null ? Colors.black : Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showGovernoratePicker(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withAlpha(100)),
            ),
            child: const Row(
              children: [
                Icon(Icons.photo_camera, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'أضف صور توضح الحالة. الصور تزيد من فرصة قبول الحالة وتحفز المتبرعين.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedImages.length < 5)
            InkWell(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط لإضافة صور',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الحد الأقصى 5 صور',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (_selectedImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
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
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'اختر القسم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['id'];
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      title: Text(category['name'] as String),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['id'] as int;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGovernoratePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'اختر المحافظة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _governorates.length,
                  itemBuilder: (context, index) {
                    final governorate = _governorates[index];
                    final isSelected = _selectedGovernorate == governorate['id'];
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      title: Text(governorate['name'] as String),
                      onTap: () {
                        setState(() {
                          _selectedGovernorate = governorate['id'] as int;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
