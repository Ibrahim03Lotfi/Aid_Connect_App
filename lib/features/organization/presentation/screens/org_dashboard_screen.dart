import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../bloc/org_dashboard_bloc/org_dashboard_bloc.dart';
import '../bloc/org_dashboard_bloc/org_dashboard_event.dart';
import '../bloc/org_dashboard_bloc/org_dashboard_state.dart';
import '../bloc/org_profile_bloc/org_profile_bloc.dart';
import '../bloc/org_profile_bloc/org_profile_event.dart';
import '../bloc/org_profile_bloc/org_profile_state.dart';
import '../../domain/entities/org_dashboard.dart';
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

class OrgDashboardScreen extends StatelessWidget {
  final String? organizationName;
  
  const OrgDashboardScreen({this.organizationName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              OrgDashboardBloc(repository: locator<OrganizationRepository>())
                ..add(const LoadDashboard()),
        ),
        BlocProvider(
          create: (_) =>
              OrgProfileBloc(repository: locator<OrganizationRepository>())
                ..add(const LoadProfile()),
        ),
      ],
      child: _DashboardView(organizationName: organizationName),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String? organizationName;
  
  const _DashboardView({this.organizationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: BlocBuilder<OrgProfileBloc, OrgProfileState>(
          builder: (context, profileState) {
            String orgName = 'المنظمة';
            if (profileState is OrgProfileLoaded) {
              orgName = profileState.profile.name;
            }
            
            return Text(
              'لوحة تحكم $orgName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            );
          },
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
              icon: Icon(
                Icons.notifications_outlined,
                color: friendlyBlue,
                size: 20,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<OrgDashboardBloc, OrgDashboardState>(
        builder: (context, state) {
          if (state is OrgDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrgDashboardLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildStatsRow(state.dashboard),
                    const SizedBox(height: 28),
                    Text(
                      'الإجراءات السريعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            );
          } else if (state is OrgDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16, color: textDark),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrgDashboardBloc>().add(
                        const LoadDashboard(),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<OrgProfileBloc, OrgProfileState>(
      builder: (context, profileState) {
        String orgName = 'منظمة الخير للإغاثة';
        if (profileState is OrgProfileLoaded) {
          orgName = profileState.profile.name;
        }
        
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
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.business, color: friendlyBlue, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بعودتك!',
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orgName,
                      style: TextStyle(
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
      },
    );
  }

  Widget _buildStatsRow(OrgDashboard dashboard) {
    return _buildStatCard(
      'حالات المنظمة',
      dashboard.approvedCasesCount.toString(),
      softTeal,
      Icons.check_circle_rounded,
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(15),
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
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textMedium,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          context,
          'عرض الحالات',
          'إدارة حالات المنظمة',
          Icons.folder_open_outlined,
          friendlyBlue,
          () => Navigator.pushNamed(context, AppRoutes.orgCases),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'إضافة حالة جديدة',
          'إنشاء حالة إغاثة جديدة',
          Icons.add_circle_outline,
          softTeal,
          () => Navigator.pushNamed(context, AppRoutes.createCase),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'الملف الشخصي',
          'تعديل بيانات المنظمة',
          Icons.business_outlined,
          Colors.orange,
          () => Navigator.pushNamed(context, AppRoutes.profile),
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
    return GestureDetector(
      onTap: onTap,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: textMedium),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
          ],
        ),
      ),
    );
  }
}
