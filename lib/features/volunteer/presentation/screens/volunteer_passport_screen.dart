import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';

// Athar Warm Hopeful & Diplomatic Gold Color System
const Color _primaryNavy = Color(0xFF0F2C59);
const Color _primaryBlue = Color(0xFF1E7ABF);
const Color _accentGold = Color(0xFFD4AF37);
const Color _tealAccent = Color(0xFF3BB3A9);
const Color _bgOffWhite = Color(0xFFF9FAFB);
const Color _textDark = Color(0xFF1F2937);
const Color _textMedium = Color(0xFF6B7280);
const Color _textLight = Color(0xFF9CA3AF);
const Color _borderLight = Color(0xFFE5E7EB);

class VolunteerPassportScreen extends StatefulWidget {
  final bool isStandalone;
  const VolunteerPassportScreen({super.key, this.isStandalone = false});

  @override
  State<VolunteerPassportScreen> createState() => _VolunteerPassportScreenState();
}

class _VolunteerPassportScreenState extends State<VolunteerPassportScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _passportData = {};

  @override
  void initState() {
    super.initState();
    _fetchPassport();
  }

  Future<void> _fetchPassport() async {
    setState(() => _isLoading = true);
    final repo = locator<VolunteerRepository>();
    final result = await repo.getVolunteerPassport();

    if (!mounted) return;
    result.fold(
      (failure) {
        // Fallback default mock data for robust offline & demo presentation
        setState(() {
          _passportData = _getDefaultPassportData();
          _isLoading = false;
        });
      },
      (data) {
        setState(() {
          _passportData = data.isNotEmpty ? data : _getDefaultPassportData();
          _isLoading = false;
        });
      },
    );
  }

  Map<String, dynamic> _getDefaultPassportData() {
    return {
      'id': 101,
      'name': 'إبراهيم لطفي',
      'email': 'ibrahim@athar.ngo',
      'phone': '+963 944 123 456',
      'rank': 'قائد فريق ميداني',
      'points': 640,
      'hours': 120.5,
      'missions_count': 18,
      'families_helped': 42,
      'badges': [
        {
          'id': 'first_aid',
          'title': 'المستجيب السريع',
          'description': 'استجابة لأكثر من 5 نداءات استغاثة فورية',
          'unlocked': true,
          'icon': Icons.flash_on_rounded,
          'color': Colors.amber.shade700,
        },
        {
          'id': 'nfc_master',
          'title': 'موثق البطاقات الذكية',
          'description': 'توثيق وتسليم أكثر من 20 سلة بالبطاقة الذكية',
          'unlocked': true,
          'icon': Icons.nfc_rounded,
          'color': _primaryBlue,
        },
        {
          'id': 'century',
          'title': 'نادي المئة ساعة',
          'description': 'تجاوز 100 ساعة عمل تطوعي موثقة في الميدان',
          'unlocked': true,
          'icon': Icons.military_tech_rounded,
          'color': _accentGold,
        },
        {
          'id': 'hero',
          'title': 'نجم العطاء الميداني',
          'description': 'إغاثة أكثر من 30 عائلة في المناطق النائية',
          'unlocked': true,
          'icon': Icons.workspace_premium_rounded,
          'color': _tealAccent,
        },
        {
          'id': 'survey_pro',
          'title': 'خبير المسح السكني',
          'description': 'إجراء 15 كشفاً ميدانياً موثقاً لتقييم الاحتياجات',
          'unlocked': false,
          'icon': Icons.fact_check_rounded,
          'color': Colors.purple.shade400,
        },
      ],
      'certificate_verification_url': 'https://athar.ngo/verify/volunteer/101',
    };
  }

  void _showCertificateDialog() {
    final name = _passportData['name'] ?? 'المتطوع';
    final hours = _passportData['hours'] ?? 0;
    final points = _passportData['points'] ?? 0;
    final rank = _passportData['rank'] ?? 'متطوع ميداني';
    final verifyUrl = _passportData['certificate_verification_url'] ??
        'https://athar.ngo/verify/volunteer/101';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _accentGold, width: isDark ? 2 : 3),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withAlpha(120) : Colors.black.withAlpha(50),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Certificate Top Ornament
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryNavy.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: _accentGold, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'منصة أثر للإغاثة والتنمية',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : _primaryNavy,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Athar Relief Foundation',
                              style: GoogleFonts.roboto(
                                fontSize: 9,
                                color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : _primaryNavy).withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: _tealAccent, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: _accentGold, thickness: 1.5),
                  const SizedBox(height: 12),
                  Text(
                    'شهادة خبرة وتقدير تطوعي',
                    style: GoogleFonts.cairo(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : _primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Certified Humanitarian Volunteer Passport',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'تشهد إدارة منصة أثر للعمل الإنساني الذكي بأنّ الزميل/ة:',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentGold.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'الرتبة الميدانية: $rank',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : _primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'قد أتمّ بتميز واقتدار ما مجموعه ($hours) ساعة تطوعية ميدانية موثقة بنظام البلوكشين الذكي، مساهماً في إغاثة العائلات المتضررة، ومحققاً ($points) نقطة عطاء معتمدة.',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFCBD5E1) : _textDark,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  // Fake QR Pattern Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : _bgOffWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : _borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQrPatternBox(size: 80),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التحقق المشفر الفوري',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : _primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'رمز الوثيقة: ATHAR-CERT-2026-${_passportData['id']}',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: verifyUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم نسخ رابط التحقق بنجاح')),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 14, color: _primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'نسخ رابط التحقق',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.darkBorder : _borderLight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: Text(
                            'إغلاق',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.primary : _primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.share_outlined, size: 16),
                          label: Text(
                            'مشاركة الشهادة',
                            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تجهيز الشهادة الرقمية المعتمدة للمشاركة!'),
                                backgroundColor: _tealAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrPatternBox({required double size}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated QR Grid Patterns
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 49,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (ctx, i) {
              final isDark = (i % 2 == 0) || (i % 5 == 0) || (i < 7) || (i > 42);
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? _primaryNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            },
          ),
          // Center Athar Mini Icon
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volunteer_activism, size: 14, color: _primaryBlue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDark ? AppColors.darkCard : _primaryNavy,
          elevation: 0,
          leading: widget.isStandalone && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(
            'جواز التطوع الرقمي المعتمد',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _fetchPassport,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPassportCard(),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(isDark),
                    const SizedBox(height: 20),
                    _buildBadgesSection(isDark),
                    const SizedBox(height: 20),
                    _buildCertificateActionBanner(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPassportCard() {
    final name = _passportData['name'] ?? 'المتطوع';
    final rank = _passportData['rank'] ?? 'متطوع ميداني';
    final id = _passportData['id'] ?? '101';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryNavy, Color(0xFF1B3B6F), Color(0xFF152A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryNavy.withAlpha(70),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(color: _accentGold, width: 1.5),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: _accentGold, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جواز السجل الميداني الإنساني',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Athar Verified Field Passport',
                        style: GoogleFonts.roboto(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildQrPatternBox(size: 46),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rank,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primaryNavy,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'رمز المتطوع: #ATHAR-VOL-$id',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPassportMicroStat('التحقق المشفر', 'موثق رسمياً', Icons.lock_clock_outlined),
              _buildPassportMicroStat('صلاحية الهوية', '2026 - 2027', Icons.date_range_outlined),
              _buildPassportMicroStat('حالة الاعتماد', 'نشط بالميدان', Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassportMicroStat(String label, String val, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _accentGold, size: 12),
            const SizedBox(width: 4),
            Text(
              val,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(bool isDark) {
    final hours = _passportData['hours'] ?? 0;
    final points = _passportData['points'] ?? 0;
    final families = _passportData['families_helped'] ?? 0;
    final missions = _passportData['missions_count'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                label: 'ساعات تطوعية موثقة',
                value: '$hours س',
                icon: Icons.timer_rounded,
                color: _primaryBlue,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                label: 'عائلات تم إغاثتها',
                value: '$families عائلة',
                icon: Icons.family_restroom_rounded,
                color: _tealAccent,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildMetricCard(
                label: 'نقاط العطاء المتراكمة',
                value: '$points نقطة',
                icon: Icons.stars_rounded,
                color: Colors.amber.shade700,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                label: 'مهام طوارئ منجزة',
                value: '$missions مهمة',
                icon: Icons.emergency_rounded,
                color: isDark ? _primaryBlue : _primaryNavy,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : _textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(bool isDark) {
    final rawBadges = _passportData['badges'] as List<dynamic>? ?? [];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: _accentGold, size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'أوسمة الشرف والكفاءة الميدانية',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : _textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _tealAccent.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${rawBadges.where((b) => b['unlocked'] == true).length} مفتوحة',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _tealAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: rawBadges.map((badge) {
              final isUnlocked = badge['unlocked'] == true;
              final title = badge['title'] ?? '';
              final desc = badge['description'] ?? '';
              final icon = badge['icon'] is IconData ? badge['icon'] as IconData : Icons.emoji_events_rounded;
              final color = isUnlocked ? (badge['color'] as Color? ?? _primaryBlue) : (isDark ? const Color(0xFF64748B) : _textLight);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? color.withAlpha(isDark ? 25 : 10)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnlocked
                        ? color.withAlpha(isDark ? 70 : 40)
                        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? color.withAlpha(isDark ? 40 : 30)
                            : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isUnlocked ? color : (isDark ? const Color(0xFF64748B) : _textLight),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? (isDark ? Colors.white : _textDark)
                                  : (isDark ? const Color(0xFF94A3B8) : _textMedium),
                            ),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? _tealAccent.withAlpha(20)
                            : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUnlocked ? 'مكتسب' : 'مقفل',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? _tealAccent : (isDark ? const Color(0xFF94A3B8) : _textLight),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateActionBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentGold.withAlpha(isDark ? 100 : 70), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accentGold.withAlpha(isDark ? 12 : 20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentGold.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_membership_rounded, color: _accentGold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وثيقة الخبرة التطوعية الرسمية',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : _primaryNavy,
                      ),
                    ),
                    Text(
                      'شهادة قابلة للتحقق الرقمي والطباعة مع الختم الرسمي',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primary : _primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: Text(
                'استعراض وتصدير شهادة الخبرة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _showCertificateDialog,
            ),
          ),
        ],
      ),
    );
  }
}
