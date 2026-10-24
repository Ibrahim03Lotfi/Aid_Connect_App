import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';
import 'volunteer_my_cases_screen.dart';
import 'volunteer_available_cases_screen.dart';
import 'nfc_aid_scanner_screen.dart';
import 'field_assessment_screen.dart';

// Athar Clean Field Design Tokens
const Color _primaryNavy = Color(0xFF0F2C59);
const Color _friendlyBlue = Color(0xFF1E7ABF);
const Color _softTeal = Color(0xFF10B981);
const Color _emergencyRed = Color(0xFFDC2626);
const Color _warningAmber = Color(0xFFF59E0B);

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _emergencyMissions = [];
  Map<String, dynamic>? _activeCampaign;
  int _offlineQueueCount = 0;
  bool _isSyncingOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repository = locator<VolunteerRepository>();
    final profileResult = await repository.getProfile();
    final dashboardResult = await repository.getDashboard();
    final missionsResult = await repository.getEmergencyMissions();
    final campaignsResult = await repository.getActiveCampaigns();
    final offlineCount = await repository.getPendingOfflineDistributionsCount();

    if (!mounted) return;

    profileResult.fold((_) {}, (profile) => _profile = profile);
    dashboardResult.fold((_) {}, (data) => _dashboard = data);
    missionsResult.fold((_) {}, (missions) => _emergencyMissions = missions);
    campaignsResult.fold((_) {}, (campaigns) {
      if (campaigns.isNotEmpty) {
        _activeCampaign = campaigns.first;
      }
    });

    setState(() {
      _offlineQueueCount = offlineCount;
      _isLoading = false;
    });
  }

  Future<void> _syncOfflineQueue() async {
    setState(() => _isSyncingOffline = true);
    HapticFeedback.mediumImpact();

    final repo = locator<VolunteerRepository>();
    final result = await repo.syncOfflineDistributions();

    if (!mounted) return;
    setState(() => _isSyncingOffline = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message,
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: _emergencyRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (syncedCount) async {
        final count = await repo.getPendingOfflineDistributionsCount();
        if (!mounted) return;
        setState(() => _offlineQueueCount = count);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تمت مزامنة $syncedCount سجل توزيع بنجاح مع السيرفر!',
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: _softTeal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
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
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          elevation: 0,
          title: Text(
            'لوحة العمليات الميدانية',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: IconButton(
                tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFBBF24) : _friendlyBlue,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  locator<ThemeService>().setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? AppColors.primaryLight : _friendlyBlue,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingView(isDark)
            : RefreshIndicator(
                onRefresh: _loadData,
                color: _friendlyBlue,
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Executive Volunteer Header
                      _buildVolunteerHeader(isDark),

                      // 2. Offline Queue Sync Banner (Conditional)
                      if (_offlineQueueCount > 0) ...[
                        const SizedBox(height: 14),
                        _buildOfflineQueueAlert(isDark),
                      ],

                      // 3. Emergency SOS Banner (Conditional)
                      if (_emergencyMissions.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildEmergencyMissionBanner(isDark),
                      ],

                      const SizedBox(height: 18),

                      // 4. Clean Numeric KPI Summary Cards
                      _buildStatsRow(isDark),

                      const SizedBox(height: 20),

                      // 5. Active Campaign & Direct Field Distribution Hero Card
                      _buildActiveCampaignCard(isDark),

                      const SizedBox(height: 24),

                      // 6. Professional Quick Field Operations
                      Text(
                        'غرفة العمليات الميدانية',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCleanOperationsList(context, isDark),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_friendlyBlue),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحديث بيانات الميدان...',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerHeader(bool isDark) {
    final volunteerName = _profile?['name'] ?? 'عمر خالد';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Elegant Initials Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryNavy, _friendlyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                volunteerName.isNotEmpty ? volunteerName[0] : 'م',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        volunteerName,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _softTeal.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _softTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'نشط ميدانياً',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _softTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'كادر الإغاثة والتوثيق الميداني المعتمد',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueAlert(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _warningAmber.withAlpha(isDark ? 30 : 15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _warningAmber.withAlpha(isDark ? 90 : 60)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجلات غير متصلة معلقة ($_offlineQueueCount)',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'عمليات توزيع مسجلة محلياً بانتظار المزامنة مع السيرفر المركزي.',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _warningAmber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: _isSyncingOffline ? null : _syncOfflineQueue,
            child: _isSyncingOffline
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'مزامنة الآن',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyMissionBanner(bool isDark) {
    final mission = _emergencyMissions.first;
    final title = mission['title'] ?? 'نداء طوارئ ميداني عاجل';
    final district = mission['district'] ?? 'مخيمات النزوح';

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyMissions),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _emergencyRed.withAlpha(isDark ? 25 : 12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _emergencyRed.withAlpha(isDark ? 80 : 40)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _emergencyRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'نداء استغاثة طارئ نشط',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        district,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _emergencyRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _emergencyRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'عرض المهمة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final myPosted = (_dashboard?['my_posted_cases_count'] as int?) ?? 0;
    final allVol = (_dashboard?['all_volunteer_cases_count'] as int?) ?? 0;
    final missionsCount = _emergencyMissions.length;

    return Row(
      children: [
        _buildCleanKpiCard(
          title: 'حالاتي المكتملة',
          value: '$myPosted',
          accentColor: _softTeal,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _buildCleanKpiCard(
          title: 'حالات الشبكة',
          value: '$allVol',
          accentColor: _friendlyBlue,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _buildCleanKpiCard(
          title: 'مهام الطوارئ',
          value: '$missionsCount',
          accentColor: _emergencyRed,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCleanKpiCard({
    required String title,
    required String value,
    required Color accentColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCampaignCard(bool isDark) {
    final campaignName = _activeCampaign?['name'] ?? 'حملة الإغاثة الغذائية الموحدة 2026';
    final targetGovernorate = _activeCampaign?['target_governorate'] ?? 'دمشق وريفها';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: _friendlyBlue.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ماسح الإغاثة NFC',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLight : _friendlyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _softTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'قيد التنفيذ',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _softTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            campaignName,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'النطاق الجغرافي: $targetGovernorate',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NfcAidScannerScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryNavy, _friendlyBlue],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'فتح الماسح الذكي لتسليم المعونة',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanOperationsList(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildOperationRow(
          title: 'سجل حالاتي وقوائم التوزيع الميداني',
          subtitle: 'متابعة الحالات التي قمت برفعها ومسار اعتمادها',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VolunteerMyCasesScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _buildOperationRow(
          title: 'استكشاف حالات وفرص التطوع المتاحة',
          subtitle: 'عرض حالات المحتاجين في محافظتك والانضمام لخدمتها',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VolunteerAvailableCasesScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _buildOperationRow(
          title: 'الكشف الميداني',
          subtitle: 'استمارة فحص وتوثيق معايير الحاجة والإيواء',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FieldAssessmentScreen(isStandalone: true)),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationRow({
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
