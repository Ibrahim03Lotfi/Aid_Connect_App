import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';

// Athar Warm Hopeful Color System
const Color _primaryBlue = Color(0xFF1E7ABF);
const Color _tealAccent = Color(0xFF3BB3A9);
const Color _urgencyCritical = Color(0xFFDC2626);
const Color _urgencyHigh = Color(0xFFF59E0B);
const Color _urgencyNormal = Color(0xFF10B981);

class FieldAssessmentScreen extends StatefulWidget {
  final int? initialBeneficiaryId;
  final String? initialBeneficiaryName;
  final int? initialCaseId;
  final bool isStandalone;

  const FieldAssessmentScreen({
    super.key,
    this.initialBeneficiaryId,
    this.initialBeneficiaryName,
    this.initialCaseId,
    this.isStandalone = false,
  });

  @override
  State<FieldAssessmentScreen> createState() => _FieldAssessmentScreenState();
}

class _FieldAssessmentScreenState extends State<FieldAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get _bgOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
  Color get _cardBg => _isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
  Color get _inputFill => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get _textDark => _isDark ? Colors.white : const Color(0xFF1F2937);
  Color get _textMedium => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
  Color get _textLight => _isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);
  Color get _borderLight => _isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

  late int _beneficiaryId;
  String _beneficiaryName = '';

  // Form fields
  double _livingConditionScore = 3.0;
  String _housingType = 'خيمة / مخيم مؤقت';
  bool _heatingAvailable = false;
  final _incomeController = TextEditingController(text: '0');
  String _incomeSource = 'لا يوجد دخل ثابت';
  String _urgencyRating = 'high'; // normal, high, critical
  final _notesController = TextEditingController();

  final List<String> _attachedPhotos = [];
  bool _isSubmitting = false;

  final List<String> _housingOptions = [
    'خيمة / مخيم مؤقت',
    'مبنى متضرر / هيكل غير مكتمل',
    'إيجار غير مستقر',
    'إيجار مستقر',
    'ملك',
  ];

  final List<String> _incomeSourceOptions = [
    'لا يوجد دخل ثابت',
    'مياومة غير منتظمة',
    'مساعدات وإعانات كفالة',
    'عمل خاص / تجاري',
    'راتب تقاعدي / وظيفة',
  ];

  @override
  void initState() {
    super.initState();
    _beneficiaryId = widget.initialBeneficiaryId ?? 1;
    _beneficiaryName = widget.initialBeneficiaryName ?? 'عائلة أحمد الشامي';
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score <= 3) return _urgencyCritical;
    if (score <= 6) return _urgencyHigh;
    if (score <= 8) return _tealAccent;
    return _urgencyNormal;
  }

  String _getScoreLabel(double score) {
    if (score <= 3) return 'حالة معيشية حرجة ومتردية جداً';
    if (score <= 6) return 'ظروف معيشية صعبة بحاجة إلى تدخل';
    if (score <= 8) return 'ظروف متوسطة ومقبولة نسبياً';
    return 'ظروف مستقرة وجيدة';
  }

  Future<void> _submitAssessment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تدوين الملاحظات والتوصيات الميدانية للزيارة'),
          backgroundColor: _urgencyCritical,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final repo = locator<VolunteerRepository>();
    final incomeVal = double.tryParse(_incomeController.text.trim()) ?? 0.0;

    final result = await repo.submitFieldAssessment(
      beneficiaryId: _beneficiaryId,
      livingConditionScore: _livingConditionScore.round(),
      housingType: _housingType,
      heatingAvailable: _heatingAvailable,
      monthlyIncome: incomeVal,
      incomeSource: _incomeSource,
      inspectorNotes: _notesController.text.trim(),
      urgencyRating: _urgencyRating,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: _urgencyCritical,
          ),
        );
      },
      (data) {
        HapticFeedback.heavyImpact();
        _showSuccessRewardDialog();
      },
    );
  }

  void _showSuccessRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _tealAccent.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: _tealAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تم رفع تقرير الكشف بنجاح!',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'تم توثيق الزيارة الميدانية في السجل المركزي لمنصة أثر، وحساب استحقاق العائلة الإغاثي.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: _textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _primaryBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _primaryBlue.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardBadge(
                    icon: Icons.stars_rounded,
                    label: '+30 نقطة',
                    color: Colors.amber.shade700,
                  ),
                  Container(width: 1, height: 32, color: _borderLight),
                  _buildRewardBadge(
                    icon: Icons.timer_outlined,
                    label: '+1.5 ساعة تطوعية',
                    color: _primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context, true);
                },
                child: Text(
                  'العودة للوحة الميدان',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgOffWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _cardBg,
          elevation: 0,
          leading: widget.isStandalone && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: _textDark, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(
            'استمارة الكشف الميداني',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _tealAccent.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_work_outlined, size: 16, color: _tealAccent),
                  const SizedBox(width: 4),
                  Text(
                    'مسح سكني',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBeneficiaryCard(),
                const SizedBox(height: 16),
                _buildLivingConditionCard(),
                const SizedBox(height: 16),
                _buildHousingDetailsCard(),
                const SizedBox(height: 16),
                _buildFinancialStatusCard(),
                const SizedBox(height: 16),
                _buildUrgencyRatingCard(),
                const SizedBox(height: 16),
                _buildInspectorNotesCard(),
                const SizedBox(height: 16),
                _buildPhotoDocumentationCard(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeneficiaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_pin_circle_outlined, color: _primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المستفيد محل المعاينة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _textMedium,
                      ),
                    ),
                    Text(
                      _beneficiaryName,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgOffWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderLight),
                ),
                child: Text(
                  '#ID: $_beneficiaryId',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _borderLight),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 16, color: _textLight),
              const SizedBox(width: 6),
              Text(
                'تغيير المستفيد (حالات سريعة):',
                style: GoogleFonts.cairo(fontSize: 12, color: _textMedium),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickBeneficiaryChip(1, 'أحمد الشامي'),
                      const SizedBox(width: 6),
                      _buildQuickBeneficiaryChip(2, 'فاطمة العلي'),
                      const SizedBox(width: 6),
                      _buildQuickBeneficiaryChip(3, 'سامر النجار'),
                      const SizedBox(width: 6),
                      _buildQuickBeneficiaryChip(11, 'مروان الشامي'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBeneficiaryChip(int id, String name) {
    final isSelected = _beneficiaryId == id;
    return InkWell(
      onTap: () {
        setState(() {
          _beneficiaryId = id;
          _beneficiaryName = 'عائلة $name';
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : _bgOffWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primaryBlue : _borderLight,
          ),
        ),
        child: Text(
          name,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildLivingConditionCard() {
    final color = _getScoreColor(_livingConditionScore);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: _primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'مستوى المعيشة العام (1 - 10)',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Text(
                  '${_livingConditionScore.round()} / 10',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getScoreLabel(_livingConditionScore),
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: _borderLight,
              thumbColor: color,
              overlayColor: color.withAlpha(40),
              trackHeight: 6,
            ),
            child: Slider(
              value: _livingConditionScore,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() => _livingConditionScore = val);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 (معدم / خطر)',
                style: GoogleFonts.cairo(fontSize: 11, color: _urgencyCritical),
              ),
              Text(
                '5 (صعب)',
                style: GoogleFonts.cairo(fontSize: 11, color: _urgencyHigh),
              ),
              Text(
                '10 (مستقر ومكتفٍ)',
                style: GoogleFonts.cairo(fontSize: 11, color: _urgencyNormal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHousingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.roofing_outlined, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'نوع السكن ومواصفاته',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _housingOptions.map((opt) {
              final isSelected = _housingType == opt;
              return ChoiceChip(
                label: Text(
                  opt,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : _textDark,
                  ),
                ),
                selected: isSelected,
                selectedColor: _primaryBlue,
                backgroundColor: _bgOffWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? _primaryBlue : _borderLight,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _housingType = opt);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: _borderLight),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                _heatingAvailable ? Icons.fireplace_rounded : Icons.ac_unit_rounded,
                color: _heatingAvailable ? Colors.amber.shade700 : _primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توفر التدفئة والمحروقات',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      _heatingAvailable
                          ? 'تتوفر وسيلة تدفئة ومحروقات آمنة'
                          : 'لا تتوفر تدفئة كافية (عرضة للبرد القارس)',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _heatingAvailable ? _urgencyNormal : _urgencyCritical,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _heatingAvailable,
                activeTrackColor: _primaryBlue,
                onChanged: (val) {
                  setState(() => _heatingAvailable = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'الوضع المالي ومصادر الدخل',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'تقدير الدخل الشهري التقريبي (ل.س)',
            style: GoogleFonts.cairo(fontSize: 12, color: _textMedium),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.attach_money, color: _textLight),
              hintText: '0',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
              ),
              filled: true,
              fillColor: _inputFill,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'المصدر الرئيسي للدخل',
            style: GoogleFonts.cairo(fontSize: 12, color: _textMedium),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _incomeSource,
            items: _incomeSourceOptions.map((src) {
              return DropdownMenuItem(
                value: src,
                child: Text(
                  src,
                  style: GoogleFonts.cairo(fontSize: 13, color: _textDark),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _incomeSource = val);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              filled: true,
              fillColor: _inputFill,
            ),
            dropdownColor: _cardBg,
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyRatingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_outlined, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'درجة الاستجابة المطلوبة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildUrgencySegment(
                  code: 'normal',
                  title: 'اعتيادي',
                  desc: 'ضمن خطة الدعم',
                  color: _urgencyNormal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUrgencySegment(
                  code: 'high',
                  title: 'عاجل',
                  desc: 'خلال 48 ساعة',
                  color: _urgencyHigh,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUrgencySegment(
                  code: 'critical',
                  title: 'طارئ / حرج',
                  desc: 'إغاثة فورية',
                  color: _urgencyCritical,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencySegment({
    required String code,
    required String title,
    required String desc,
    required Color color,
  }) {
    final isSelected = _urgencyRating == code;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _urgencyRating = code);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : _bgOffWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : _borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : _textLight,
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : _textDark,
              ),
            ),
            Text(
              desc,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: _textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorNotesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: _primaryBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'ملاحظات وتوصيات الباحث الميداني',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Text(
                '* مطلوب',
                style: GoogleFonts.cairo(fontSize: 11, color: _urgencyCritical),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
            decoration: InputDecoration(
              hintText: 'سجل أدق التفاصيل حول حالة المسكن، احتياجات الأطفال والمسنين، والأدوية الضرورية...',
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
              ),
              filled: true,
              fillColor: _inputFill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoDocumentationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_back_outlined, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'التوثيق الفوتوغرافي للزيارة',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._attachedPhotos.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderLight),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, color: _primaryBlue, size: 32),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _attachedPhotos.removeAt(entry.key));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: _urgencyCritical,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              InkWell(
                onTap: () {
                  if (_attachedPhotos.length < 4) {
                    setState(() {
                      _attachedPhotos.add('photo_${_attachedPhotos.length + 1}.jpg');
                    });
                    HapticFeedback.lightImpact();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الحد الأقصى للصور 4 صور')),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _bgOffWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderLight, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: _primaryBlue, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'إرفاق صورة',
                        style: GoogleFonts.cairo(fontSize: 10, color: _textMedium),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: _primaryBlue.withAlpha(70),
        ),
        onPressed: _isSubmitting ? null : _submitAssessment,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'اعتماد وإرسال التقرير الميداني',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
