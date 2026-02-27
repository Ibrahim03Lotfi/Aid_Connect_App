import 'package:flutter/material.dart';
import '../../../../config/routes/app_routes.dart';

class OrgDashboardScreen extends StatelessWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المنظمة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              const Text(
                'الإجراءات السريعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              const Text(
                'آخر النشاطات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E7ABF),
            const Color(0xFF1E7ABF).withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.business,
              color: Color(0xFF1E7ABF),
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بعودتك!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'منظمة الخير للإغاثة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
    return Row(
      children: [
        _buildStatCard(
          'الحالات المعلقة',
          '3',
          Colors.orange,
          Icons.hourglass_empty,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'الحالات المقبولة',
          '4',
          Colors.green,
          Icons.check_circle,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'إجمالي التبرعات',
          '156',
          const Color(0xFF1E7ABF),
          Icons.favorite,
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
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
          'عرض الحالات',
          'إدارة حالات المنظمة',
          Icons.folder_open,
          const Color(0xFF1E7ABF),
          () => Navigator.pushNamed(context, AppRoutes.orgCases),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'إضافة حالة جديدة',
          'إنشاء حالة إغاثة جديدة',
          Icons.add_circle,
          Colors.green,
          () => Navigator.pushNamed(context, AppRoutes.createCase),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          'الملف الشخصي',
          'تعديل بيانات المنظمة',
          Icons.business,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'title': 'تمت الموافقة على حالة جديدة',
        'time': 'منذ 2 ساعة',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'تبرع جديد على حالة "مساعدة عاجلة"',
        'time': 'منذ 5 ساعات',
        'icon': Icons.favorite,
        'color': Colors.red,
      },
      {
        'title': 'تم رفض حالة - يرجى التعديل',
        'time': 'منذ يوم',
        'icon': Icons.cancel,
        'color': Colors.red,
      },
      {
        'title': 'تم إنشاء حالة جديدة',
        'time': 'منذ يومين',
        'icon': Icons.add_circle,
        'color': const Color(0xFF1E7ABF),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: (activity['color'] as Color).withAlpha(30),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          title: Text(activity['title'] as String),
          subtitle: Text(
            activity['time'] as String,
            style: TextStyle(color: Colors.grey[500]),
          ),
        );
      },
    );
  }
}
