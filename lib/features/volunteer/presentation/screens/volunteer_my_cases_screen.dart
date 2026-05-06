import 'package:flutter/material.dart';
import '../../../../services/locator.dart';
import '../../../organization/domain/entities/org_case.dart';
import 'volunteer_create_my_case_screen.dart';
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

class VolunteerMyCasesScreen extends StatefulWidget {
  const VolunteerMyCasesScreen({super.key});

  @override
  State<VolunteerMyCasesScreen> createState() => _VolunteerMyCasesScreenState();
}

class _VolunteerMyCasesScreenState extends State<VolunteerMyCasesScreen> {
  bool _isLoading = true;
  List<OrgCase> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    
    final repository = locator<VolunteerRepository>();
    final result = await repository.getMyCases();
    
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (cases) => setState(() {
        _cases = cases;
        _isLoading = false;
      }),
    );
  }

  Future<void> _deleteCase(int caseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('حذف الحالة'),
          ],
        ),
        content: const Text('هل أنت متأكد من حذف هذه الحالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(color: textMedium)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تأكيد',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = locator<VolunteerRepository>();
    final result = await repository.deleteMyCase(caseId);
    
    result.fold(
      (failure) {
        _showSnackBar('فشل: ${failure.message}', Colors.red);
      },
      (_) {
        _showSnackBar('تم حذف الحالة بنجاح', softTeal);
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
          'حالاتي',
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
              icon: Icon(Icons.add, color: friendlyBlue, size: 20),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VolunteerCreateMyCaseScreen(),
                  ),
                );
                if (created == true) {
                  _loadCases();
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                          itemBuilder: (context, index) =>
                              _buildCaseCard(_cases[index]),
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

  Widget _buildCaseCard(OrgCase c) {
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
                _buildStatusBadge(c.status),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerCreateMyCaseScreen(existing: c),
                      ),
                    );
                    if (updated == true) _loadCases();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: friendlyBlue.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 18, color: friendlyBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(c.createdAt),
                  style: TextStyle(
                    color: textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(
                  c.category,
                  style: TextStyle(color: textMedium, fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(
                  c.governorate,
                  style: TextStyle(color: textMedium, fontSize: 13),
                ),
              ],
            ),
            if (c.isRejected && c.rejectionReason != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(30), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.rejectionReason!,
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => _deleteCase(c.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(30), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'حذف الحالة',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusConfig = {
      'pending': {'label': 'معلق', 'color': Colors.orange},
      'approved': {'label': 'مقبول', 'color': softTeal},
      'rejected': {'label': 'مرفوض', 'color': Colors.red},
    };

    final config = statusConfig[status] ?? statusConfig['pending']!;
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
              Icons.assignment_outlined,
              size: 48,
              color: friendlyBlue.withAlpha(80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط + لإضافة حالة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: textMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
