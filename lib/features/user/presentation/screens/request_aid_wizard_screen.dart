import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';

class RequestAidWizardScreen extends StatefulWidget {
  const RequestAidWizardScreen({super.key});

  @override
  State<RequestAidWizardScreen> createState() => _RequestAidWizardScreenState();
}

class _RequestAidWizardScreenState extends State<RequestAidWizardScreen> {
  int _currentStep = 0;

  // Step 1: Category
  String _selectedCategory = 'health';

  // Step 2: Details & Location
  int _familyCount = 4;
  String _selectedGovernorate = 'دمشق';
  String _urgencyLevel = 'urgent';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Step 3: Evidence & Audio
  bool _isRecordingAudio = false;
  bool _hasRecordedAudio = false;
  bool _hasAttachedDoc = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'health',
      'title': 'رعاية صحية وعمليات',
      'subtitle': 'عمليات جراحية، أدوية مزمنة، رنين وطبقي',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFF0284C7),
    },
    {
      'id': 'food',
      'title': 'سلة غذائية وإطعام',
      'subtitle': 'طرود غذائية شهرية، حليب ومكملات أطفال',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'winter',
      'title': 'تدفئة وكسوة شتاء',
      'subtitle': 'بطانيات حرارية، وقود مازوت، مدافئ ومعاطف',
      'icon': Icons.ac_unit_rounded,
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': 'shelter',
      'title': 'إيواء وترميم طارئ',
      'subtitle': 'مأوى مؤقت، تأمين أسقف، مساعدات إيجار',
      'icon': Icons.home_work_rounded,
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        // Top Right Brand Logo + Screen Title
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'أثر',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'طلب مساعدة إغاثية',
                  style: GoogleFonts.cairo(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  'الاستمارة الرقمية للحالات الطارئة',
                  style: GoogleFonts.cairo(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Indicator
            _buildStepIndicator(isDark),
            const SizedBox(height: 16),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCurrentStepContent(isDark),
              ),
            ),

            // Bottom Navigation Controls
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildStepCircle(0, 'التصنيف', isDark),
          _buildStepDivider(0, isDark),
          _buildStepCircle(1, 'البيانات', isDark),
          _buildStepDivider(1, isDark),
          _buildStepCircle(2, 'التوثيق', isDark),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isDark) {
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isCurrent ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF64748B)),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: isCurrent
                ? AppColors.primary
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int step, bool isDark) {
    final isPassed = _currentStep > step;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
        decoration: BoxDecoration(
          color: isPassed
              ? AppColors.success
              : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStep(isDark);
      case 1:
        return _buildDetailsStep(isDark);
      case 2:
        return _buildEvidenceStep(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Step 1: Category Selection ---
  Widget _buildCategoryStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ما هو نوع المساعدة المطلوبة؟',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اختر المجال الأنسب لحالتك حتى يتم توجيه طلبك للفريق المتخصص فوراً.',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        ..._categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat['id']),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: 250.ms,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withAlpha(isDark ? 35 : 15)
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? (cat['color'] as Color)
                        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 6),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['subtitle'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: cat['color'] as Color, size: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // --- Step 2: Details & Family Info ---
  Widget _buildDetailsStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'بيانات العائلة والمنطقة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text('عنوان مختصر للحالة', style: _labelStyle(isDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _titleController,
            style: GoogleFonts.cairo(color: isDark ? Colors.white : const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'مثال: عملية جراحية لطفل عمره 7 سنوات',
              hintStyle: GoogleFonts.cairo(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Family Members Counter
        Text('عدد أفراد الأسرة المقيمين معاً', style: _labelStyle(isDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.family_restroom_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    '$_familyCount أفراد',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _familyCount > 1 ? () => setState(() => _familyCount--) : null,
                    icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _familyCount++),
                    icon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Governorate & District
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المحافظة', style: _labelStyle(isDark)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGovernorate,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        items: ['دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس']
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(
                                    g,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGovernorate = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحي أو المنطقة', style: _labelStyle(isDark)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _districtController,
                      style: GoogleFonts.cairo(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'مثال: جرمانا',
                        hintStyle: GoogleFonts.cairo(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Urgency Switch
        Text('درجة الاستعجال', style: _labelStyle(isDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('عاجل (خلال 48 س)')),
                selected: _urgencyLevel == 'urgent',
                selectedColor: AppColors.error.withAlpha(isDark ? 50 : 30),
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                labelStyle: GoogleFonts.cairo(
                  color: _urgencyLevel == 'urgent' ? AppColors.error : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _urgencyLevel == 'urgent' ? AppColors.error : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                  ),
                ),
                onSelected: (val) => setState(() => _urgencyLevel = 'urgent'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('احتياج شهري اعتيادي')),
                selected: _urgencyLevel == 'normal',
                selectedColor: AppColors.primary.withAlpha(isDark ? 50 : 30),
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                labelStyle: GoogleFonts.cairo(
                  color: _urgencyLevel == 'normal' ? AppColors.primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _urgencyLevel == 'normal' ? AppColors.primary : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                  ),
                ),
                onSelected: (val) => setState(() => _urgencyLevel = 'normal'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        Text('شرح تفصيلي للوضع المعيشي', style: _labelStyle(isDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: GoogleFonts.cairo(color: isDark ? Colors.white : const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'اكتب باختصار وضع العائلة، مصدر الدخل إن وجد، وطبيعة الاحتياج...',
              hintStyle: GoogleFonts.cairo(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // --- Step 3: Evidence & Audio Recording ---
  Widget _buildEvidenceStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إرفاق الوثائق أو رسالة صوتية',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'يمكنك إرفاق تقرير مشفى مطبوع، فاتورة، أو تسجيل رسالة صوتية تشرح فيها ظروفك.',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),

        // 1. Document Upload Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hasAttachedDoc ? AppColors.success : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: _hasAttachedDoc ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقرير طبي أو فاتورة مطبوعة',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _hasAttachedDoc
                              ? 'تم إرفاق: تقرير_طبي_مشفى_المواساة.pdf'
                              : 'صورة واضحة لتقرير المشفى، الرنين، أو إيجار السكن',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _hasAttachedDoc ? AppColors.success : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _hasAttachedDoc = !_hasAttachedDoc);
                  },
                  icon: Icon(_hasAttachedDoc ? Icons.check_circle_rounded : Icons.camera_alt_rounded),
                  label: Text(_hasAttachedDoc ? 'تم الإرفاق بنجاح (تغيير)' : 'التقاط صورة / اختيار ملف', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: _hasAttachedDoc ? AppColors.success : AppColors.primary,
                    side: BorderSide(color: _hasAttachedDoc ? AppColors.success : AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              if (_hasAttachedDoc) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withAlpha(isDark ? 30 : 15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF0F766E).withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F766E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التدقيق الذكي للفاتورة (AI Auditor)',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F766E),
                              ),
                            ),
                            Text(
                              'استخراج التكلفة والتشخيص والتحقق الحسابي للبنود',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAiInvoiceAuditorModal(isDark),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0F766E),
                          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        child: const Text('تدقيق الآن'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Audio Voice Note Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hasRecordedAudio ? AppColors.success : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: _hasRecordedAudio ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_rounded, color: AppColors.warning, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تسجيل صوتي ميسر (60 ثانية)',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _hasRecordedAudio
                              ? 'تم حفظ الرسالة الصوتية (42 ثانية)'
                              : 'تحدث بلهجتك الطبيعية لشرح ما تحتاجه عائلتك',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: _hasRecordedAudio ? AppColors.success : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_isRecordingAudio) {
                        _isRecordingAudio = false;
                        _hasRecordedAudio = true;
                      } else {
                        _isRecordingAudio = true;
                      }
                    });
                  },
                  icon: Icon(_isRecordingAudio ? Icons.stop_rounded : Icons.mic_none_rounded),
                  label: Text(
                    _isRecordingAudio ? 'إيقاف التسجيل الصوتي' : (_hasRecordedAudio ? 'إعادة التسجيل' : 'بدء تسجيل صوتي'),
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecordingAudio ? AppColors.error : AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBottomBar(bool isDark) {
    final isLastStep = _currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                ),
                child: Text('السابق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (isLastStep) {
                  _showSuccessDialog(isDark);
                } else {
                  setState(() => _currentStep++);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isLastStep ? 'إرسال الطلب للاعتماد' : 'المتابعة للخطوة التالية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'تم استلام طلبكم بنجاح!',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم التتبع الموحد الخاص بك:',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
              ),
              child: Text(
                'ATHAR-REQ-2026-91',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'تم تحويل الطلب إلى فريق التدقيق الذكي، وسيتم تكليف متطوع ميداني لزيارتكم والكشف على الاحتياج.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.caseTracking,
                    arguments: {'code': 'ATHAR-REQ-2026-91'},
                  );
                },
                icon: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 18),
                label: Text(
                  'تتبع مسار الطلب فوراً',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Home
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  'العودة للرئيسية',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiInvoiceAuditorModal(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0F766E), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتائج التدقيق الذكي للوثيقة الطبية',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'تم استخراج البيانات والتحقق الحسابي بواسطة محرك أثر للذكاء الاصطناعي',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInvoiceRow('المشفى / المركز الطبي:', 'مشفى المواساة الجامعي - دمشق', isDark),
                    const Divider(height: 16),
                    _buildInvoiceRow('التشخيص الطبي المستخرج:', 'تضيق تاجي حاد وقصور صمام (جراحة قلب مفتوح)', isDark),
                    const Divider(height: 16),
                    _buildInvoiceRow('أجور العمليات والتخدير:', '12,500,000 ل.س', isDark),
                    const SizedBox(height: 6),
                    _buildInvoiceRow('صمام قلب ميكانيكي وقسطرة:', '9,500,000 ل.س', isDark),
                    const SizedBox(height: 6),
                    _buildInvoiceRow('عناية مشددة واستشفاء:', '3,000,000 ل.س', isDark),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي المدقق:',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        Text(
                          '25,000,000 ل.س',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم التحقق الرياضي التام من تطابق مجموع البنود مع الإجمالي (Math Verified)',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _titleController.text = 'جراحة قلب مفتوح وتبديل صمام - مشفى المواساة';
                    });
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  label: Text(
                    'اعتماد البيانات واستكمال الطلب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle(bool isDark) => GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      );
}
