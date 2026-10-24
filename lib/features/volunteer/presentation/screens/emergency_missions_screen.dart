import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';

// Hopeful & Rapid Emergency Color System
const Color _bgOffWhite = Color(0xFFF9FAFB);
const Color _cardWhite = Color(0xFFFFFFFF);
const Color _friendlyBlue = Color(0xFF1E7ABF);
const Color _softTeal = Color(0xFF3BB3A9);
const Color _emergencyRed = Color(0xFFDC2626);
const Color _warningAmber = Color(0xFFF59E0B);
const Color _textDark = Color(0xFF1F2937);
const Color _textMedium = Color(0xFF6B7280);
const Color _borderLight = Color(0xFFE5E7EB);

class EmergencyMissionsScreen extends StatefulWidget {
  const EmergencyMissionsScreen({super.key});

  @override
  State<EmergencyMissionsScreen> createState() => _EmergencyMissionsScreenState();
}

class _EmergencyMissionsScreenState extends State<EmergencyMissionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _missions = [];
  final Set<int> _actionLoadingIds = {};

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final repo = locator<VolunteerRepository>();
    final result = await repo.getEmergencyMissions();

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: _emergencyRed,
          ),
        );
      },
      (missions) {
        setState(() {
          _missions = missions;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _joinMission(int missionId) async {
    setState(() => _actionLoadingIds.add(missionId));
    HapticFeedback.mediumImpact();

    final repo = locator<VolunteerRepository>();
    final result = await repo.joinEmergencyMission(missionId);

    if (!mounted) return;
    setState(() => _actionLoadingIds.remove(missionId));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: _emergencyRed,
          ),
        );
      },
      (_) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم انضمامك إلى مهمة الطوارئ الميدانية بنجاح!'),
            backgroundColor: _softTeal,
          ),
        );
        _loadMissions();
      },
    );
  }

  Future<void> _checkInMission(int missionId) async {
    setState(() => _actionLoadingIds.add(missionId));
    HapticFeedback.mediumImpact();

    final repo = locator<VolunteerRepository>();
    final result = await repo.checkInEmergencyMission(missionId);

    if (!mounted) return;
    setState(() => _actionLoadingIds.remove(missionId));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: _emergencyRed,
          ),
        );
      },
      (_) {
        HapticFeedback.heavyImpact();
        _showCheckInSuccessDialog();
        _loadMissions();
      },
    );
  }

  void _showCheckInSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : _cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _softTeal.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: _softTeal, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'تم تأكيد الوصول الميداني!',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم تسجيل حضورك في الموقع ومنحك +50 نقطة وساعتين في جواز السفر التطوعي، مع وسام المستجيب السريع.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : _textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _friendlyBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'متابعة المهمة',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return _emergencyRed;
      case 'high':
      case 'urgent':
        return _warningAmber;
      default:
        return _softTeal;
    }
  }

  String _getUrgencyLabel(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return 'حرج جداً';
      case 'high':
      case 'urgent':
        return 'عاجل';
      default:
        return 'عادي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : _bgOffWhite,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkCard : _bgOffWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: isDark ? Colors.white : _textDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'نداءات الطوارئ والاستجابة السريعة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : _textDark,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_friendlyBlue),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMissions,
                color: _friendlyBlue,
                backgroundColor: isDark ? AppColors.darkCard : _cardWhite,
                child: _missions.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _missions.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildMissionCard(_missions[index], isDark);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _softTeal.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: _softTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد نداءات طوارئ نشطة حالياً',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الميدان مستقر حالياً، وسيتم إرسال إشعار فوري عند صدور نداء استغاثة من غرفة العمليات.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : _textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission, bool isDark) {
    final id = mission['id'] as int? ?? 0;
    final title = mission['title'] as String? ?? 'مهمة إغاثية طارئة';
    final description = mission['description'] as String? ?? '';
    final urgency = mission['urgency'] as String? ?? 'urgent';
    final district = mission['district'] as String? ?? 'الميدان';
    final governorate = mission['governorate']?['name'] as String? ?? 'دمشق';
    final needed = mission['volunteers_needed'] as int? ?? 1;
    final joined = mission['volunteers_joined'] as int? ?? 0;
    final skills = (mission['required_skills'] as List?)?.map((e) => e.toString()).toList() ?? [];

    final urgencyColor = _getUrgencyColor(urgency);
    final urgencyLabel = _getUrgencyLabel(urgency);

    final isBusy = _actionLoadingIds.contains(id);
    final progress = (joined / needed).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : _cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : _borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: urgencyColor.withAlpha(isDark ? 20 : 12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Urgency tag + SOS badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: urgencyColor.withAlpha(70), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.crisis_alert_rounded, size: 14, color: urgencyColor),
                    const SizedBox(width: 4),
                    Text(
                      urgencyLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: urgencyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? AppColors.darkTextSecondary : _textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$governorate - $district',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : _textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : _textDark,
              height: 1.3,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : _textMedium,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),

          // Required Skills
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _friendlyBlue.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _friendlyBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Volunteers Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الاستجابة الميدانية',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : _textMedium,
                ),
              ),
              Text(
                '$joined من أصل $needed متطوع',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _friendlyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? _softTeal : urgencyColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _friendlyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: isBusy ? null : () => _joinMission(id),
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.group_add_rounded, size: 18),
                  label: Text(
                    'انضمام للمهمة',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _softTeal.withAlpha(25),
                  foregroundColor: _softTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
                onPressed: isBusy ? null : () => _checkInMission(id),
                icon: const Icon(Icons.pin_drop_rounded, size: 18),
                label: Text(
                  'تسجيل وصول',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
