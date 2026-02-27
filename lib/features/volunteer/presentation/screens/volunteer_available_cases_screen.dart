import 'package:flutter/material.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/volunteer_case.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerAvailableCasesScreen extends StatefulWidget {
  const VolunteerAvailableCasesScreen({super.key});

  @override
  State<VolunteerAvailableCasesScreen> createState() => _VolunteerAvailableCasesScreenState();
}

class _VolunteerAvailableCasesScreenState extends State<VolunteerAvailableCasesScreen> {
  bool _isLoading = true;
  List<VolunteerCase> _cases = [];
  String? _selectedCategory;
  String? _selectedGovernorate;

  final List<String> _categories = [
    'الكل',
    'إغاثة عاجلة',
    'مساعدات غذائية',
    'علاج طبي',
    'تعليم',
    'سكن',
    'ملابس',
    'بيئة',
    'دعم نفسي',
  ];

  final List<String> _governorates = [
    'الكل',
    'القاهرة',
    'الإسكندرية',
    'الجيزة',
    'المنصورة',
    'أسوان',
    'الأقصر',
  ];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    
    final repository = locator<VolunteerRepository>();
    final result = await repository.getAvailableCases(
      category: _selectedCategory == 'الكل' ? null : _selectedCategory,
      governorate: _selectedGovernorate == 'الكل' ? null : _selectedGovernorate,
    );
    
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (cases) => setState(() {
        _cases = cases;
        _isLoading = false;
      }),
    );
  }

  Future<void> _applyToCase(int caseId) async {
    final repository = locator<VolunteerRepository>();
    final result = await repository.applyToCase(caseId);
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلبك بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCases();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحالات المتاحة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cases.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCases,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _cases.length,
                          itemBuilder: (context, index) => _buildCaseCard(_cases[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category ||
                    (category == 'الكل' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'الكل' ? null : category;
                      });
                      _loadCases();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Governorate filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _governorates.map((gov) {
                final isSelected = _selectedGovernorate == gov ||
                    (gov == 'الكل' && _selectedGovernorate == null);
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(gov),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGovernorate = gov == 'الكل' ? null : gov;
                      });
                      _loadCases();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(VolunteerCase volunteerCase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with priority badge
            Row(
              children: [
                _buildPriorityBadge(volunteerCase.priority),
                const SizedBox(width: 8),
                if (volunteerCase.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign, color: Colors.red, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'عاجل',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  volunteerCase.organizationName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              volunteerCase.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              volunteerCase.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Info row
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(volunteerCase.governorate, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(volunteerCase.category, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            
            // Footer with spots and apply button
            Row(
              children: [
                Icon(Icons.people_outlined, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${volunteerCase.volunteersApplied}/${volunteerCase.volunteersNeeded} متطوع',
                  style: TextStyle(
                    color: volunteerCase.isFull ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: volunteerCase.isFull ? null : () => _applyToCase(volunteerCase.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: volunteerCase.isFull ? Colors.grey : const Color(0xFF1E7ABF),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(
                    volunteerCase.isFull ? 'اكتمل' : 'تقدم',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final priorityConfig = {
      'urgent': {'label': 'عاجل', 'color': Colors.red},
      'high': {'label': 'مرتفع', 'color': Colors.orange},
      'medium': {'label': 'متوسط', 'color': Colors.yellow.shade700},
      'low': {'label': 'منخفض', 'color': Colors.green},
    };

    final config = priorityConfig[priority] ?? priorityConfig['medium']!;
    final color = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات متاحة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
