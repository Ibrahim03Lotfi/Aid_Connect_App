import 'package:flutter/material.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../domain/repositories/volunteer_repository.dart';
import 'volunteer_my_cases_screen.dart';
import 'volunteer_profile_screen.dart';

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

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _dashboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repository = locator<VolunteerRepository>();
    final profileResult = await repository.getProfile();
    final dashboardResult = await repository.getDashboard();

    if (!mounted) return;

    profileResult.fold((_) {}, (profile) => _profile = profile);
    dashboardResult.fold((_) {}, (data) => _dashboard = data);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          'لوحة المتطوع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderLight, width: 1),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: friendlyBlue, size: 20),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: friendlyBlue,
              backgroundColor: cardWhite,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      Text(
                        'الإجراءات السريعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: friendlyBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
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
            'جاري التحميل...',
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

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [friendlyBlue, softTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: friendlyBlue.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cardWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: friendlyBlue.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.volunteer_activism,
              color: friendlyBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بعودتك!',
                  style: TextStyle(
                    color: Colors.white.withAlpha(90),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _profile?['name'] ?? 'متطوع',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final myPosted = (_dashboard?['my_posted_cases_count'] as int?) ?? 0;
    final allVol = (_dashboard?['all_volunteer_cases_count'] as int?) ?? 0;
    return Row(
      children: [
        _buildStatCard(
          'الحالات المكتملة',
          '$myPosted',
          softTeal,
          Icons.check_circle_outlined,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'حالات جميع المتطوعين',
          '$allVol',
          friendlyBlue,
          Icons.groups_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          context,
          'حالاتي',
          'أنشئ حالاتك وتابع حالتها',
          Icons.assignment_outlined,
          softTeal,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VolunteerMyCasesScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'الملف الشخصي',
          'تحديث بياناتك ومهاراتك',
          Icons.person_outlined,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VolunteerProfileScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: textMedium,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
      ),
    );
  }

}
