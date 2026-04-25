import 'package:flutter/material.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/volunteer_case.dart';
import '../../domain/repositories/volunteer_repository.dart';

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
    'دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'درعا',
    'السويداء',
    'دير الزور',
    'الرقة',
    'الحسكة',
    'إدلب',
    'القنيطرة',
    'ريف دمشق',
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
        _showSnackBar('فشل: ${failure.message}', Colors.red);
      },
      (_) {
        _showSnackBar('تم إرسال طلبك بنجاح!', softTeal);
        _loadCases();
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          'الحالات المتاحة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _cases.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCases,
                        color: friendlyBlue,
                        backgroundColor: cardWhite,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _cases.length,
                          itemBuilder: (context, index) => _buildCaseCard(_cases[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: friendlyBlue.withAlpha(20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(friendlyBlue),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل الحالات...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMedium,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category ||
                    (category == 'الكل' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category == 'الكل' ? null : category;
                      });
                      _loadCases();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? friendlyBlue.withAlpha(20) : cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? friendlyBlue : borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? friendlyBlue : textMedium,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _governorates.map((gov) {
                final isSelected = _selectedGovernorate == gov ||
                    (gov == 'الكل' && _selectedGovernorate == null);
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGovernorate = gov == 'الكل' ? null : gov;
                      });
                      _loadCases();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? softTeal.withAlpha(20) : cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? softTeal : borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        gov,
                        style: TextStyle(
                          color: isSelected ? softTeal : textMedium,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: friendlyBlue.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPriorityBadge(volunteerCase.priority),
                const SizedBox(width: 8),
                if (volunteerCase.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_outlined, color: Colors.red, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'عاجل',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
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
                    color: textMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              volunteerCase.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              volunteerCase.description,
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(volunteerCase.governorate, style: TextStyle(color: textMedium, fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(volunteerCase.category, style: TextStyle(color: textMedium, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              children: [
                Icon(Icons.people_outlined, size: 18, color: textLight),
                const SizedBox(width: 4),
                Text(
                  '${volunteerCase.volunteersApplied}/${volunteerCase.volunteersNeeded} متطوع',
                  style: TextStyle(
                    color: volunteerCase.isFull ? Colors.red : softTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: volunteerCase.isFull ? null : () => _applyToCase(volunteerCase.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: volunteerCase.isFull
                          ? null
                          : const LinearGradient(
                              colors: [friendlyBlue, softTeal],
                            ),
                      color: volunteerCase.isFull ? borderLight : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      volunteerCase.isFull ? 'اكتمل' : 'تقدم',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: volunteerCase.isFull ? textLight : Colors.white,
                      ),
                    ),
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
      'medium': {'label': 'متوسط', 'color': Colors.amber.shade700},
      'low': {'label': 'منخفض', 'color': Colors.green},
    };

    final config = priorityConfig[priority] ?? priorityConfig['medium']!;
    final color = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: softBlueTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_outlined,
              size: 48,
              color: friendlyBlue.withAlpha(80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حالات متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}
