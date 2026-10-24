import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../organization/domain/entities/org_case.dart';
import 'volunteer_create_my_case_screen.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerMyCasesScreen extends StatefulWidget {
  const VolunteerMyCasesScreen({super.key});

  @override
  State<VolunteerMyCasesScreen> createState() => _VolunteerMyCasesScreenState();
}

class _VolunteerMyCasesScreenState extends State<VolunteerMyCasesScreen> {
  bool _isLoading = true;
  List<OrgCase> _cases = [];

  // Dynamic Theme Colors
  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get _backgroundOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
  Color get _softBlueTint => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  Color get _friendlyBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E7ABF);
  Color get _softTeal => const Color(0xFF10B981);
  Color get _textDark => _isDark ? Colors.white : const Color(0xFF0F172A);
  Color get _textMedium => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _textLight => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get _cardWhite => _isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
  Color get _borderLight => _isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

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
        backgroundColor: _cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _borderLight),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              'حذف الحالة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الحالة؟',
          style: GoogleFonts.cairo(fontSize: 14, color: _textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: _textMedium, fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'تأكيد',
                style: GoogleFonts.cairo(
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
        _showSnackBar('تم حذف الحالة بنجاح', _softTeal);
        _loadCases();
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
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
      backgroundColor: _backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: _isDark ? AppColors.darkCard : _backgroundOffWhite,
        elevation: 0,
        title: Text(
          'حالاتي',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderLight, width: 1),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: _friendlyBlue, size: 20),
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
                        color: _friendlyBlue,
                        backgroundColor: _cardWhite,
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
              color: _cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderLight),
              boxShadow: _isDark
                  ? []
                  : [
                      BoxShadow(
                        color: _friendlyBlue.withAlpha(20),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_friendlyBlue),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل الحالات...',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(OrgCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: _friendlyBlue.withAlpha(8),
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
                      color: _friendlyBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.edit_outlined,
                        size: 18, color: _friendlyBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(c.createdAt),
                  style: GoogleFonts.cairo(
                    color: _textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 10),
            if (c.thumbnail != null || c.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  c.thumbnail ?? c.images.first,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: _softBlueTint,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: _textLight,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: _friendlyBlue),
                const SizedBox(width: 5),
                Text(
                  c.category,
                  style: GoogleFonts.cairo(
                    color: _textMedium,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 16, color: _friendlyBlue),
                const SizedBox(width: 5),
                Text(
                  c.governorate,
                  style: GoogleFonts.cairo(
                    color: _textMedium,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (c.isRejected && c.rejectionReason != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(_isDark ? 30 : 15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(40), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c.rejectionReason!,
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(_isDark ? 25 : 12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(30), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'حذف الحالة',
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
      'approved': {'label': 'مقبول', 'color': _softTeal},
      'rejected': {'label': 'مرفوض', 'color': Colors.red},
    };

    final config = statusConfig[status] ?? statusConfig['pending']!;
    final color = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(_isDark ? 35 : 20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: GoogleFonts.cairo(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
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
              color: _softBlueTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 48,
              color: _friendlyBlue.withAlpha(80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حالات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط + لإضافة حالة جديدة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textMedium,
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
