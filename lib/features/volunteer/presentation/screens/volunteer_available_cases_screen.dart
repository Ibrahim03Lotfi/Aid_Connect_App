import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../organization/domain/entities/org_case.dart';
import '../../../user/domain/entities/case.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerAvailableCasesScreen extends StatefulWidget {
  const VolunteerAvailableCasesScreen({super.key});

  @override
  State<VolunteerAvailableCasesScreen> createState() => _VolunteerAvailableCasesScreenState();
}

class _VolunteerAvailableCasesScreenState extends State<VolunteerAvailableCasesScreen> {
  bool _isLoading = true;
  List<Case> _cases = [];
  final _searchController = TextEditingController();

  // Dynamic Theme Colors
  bool get _isDark => mounted && Theme.of(context).brightness == Brightness.dark;
  Color get _backgroundOffWhite => _isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
  Color get _softBlueTint => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  Color get _friendlyBlue => _isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E7ABF);
  Color get _softTeal => const Color(0xFF3BB3A9);
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
    final queryText = _searchController.text.trim();
    final result = await repository.getVolunteerFeed(query: queryText);
    
    await result.fold(
      (failure) async {
        // Fallback: at minimum show current volunteer posted cases.
        final mine = await repository.getMyCases();
        mine.fold(
          (_) {
            setState(() => _isLoading = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'فشل تحميل الحالات: ${failure.message}',
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          (myCases) {
            final mapped = myCases.map(_orgCaseToCase).toList();
            setState(() {
              _cases = _applyLocalSearchFilter(mapped, queryText);
              _isLoading = false;
            });
          },
        );
      },
      (cases) async {
        setState(() {
          _cases = _applyLocalSearchFilter(cases, queryText);
          _isLoading = false;
        });
      },
    );
  }

  List<Case> _applyLocalSearchFilter(List<Case> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.governorate.toLowerCase().contains(q);
    }).toList();
  }

  Case _orgCaseToCase(OrgCase c) {
    return Case(
      id: c.id,
      title: c.title,
      description: c.description,
      governorate: c.governorate,
      category: c.category,
      categoryId: 0,
      governorateId: 0,
      status: c.status,
      priority: c.priority,
      thumbnail: c.thumbnail,
      images: c.images,
      views: c.views,
      createdAt: c.createdAt,
      organizationName: 'أنا',
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
          'بحث الحالات (المتطوعين)',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearch(),
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
                          itemBuilder: (context, index) => _buildCaseCard(_cases[index]),
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

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _loadCases(),
                    style: GoogleFonts.cairo(color: _textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم الحالة أو المحافظة...',
                      hintStyle: GoogleFonts.cairo(color: _textLight, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: _friendlyBlue, size: 20),
                      filled: true,
                      fillColor: _softBlueTint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _friendlyBlue, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _loadCases,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_friendlyBlue, _softTeal],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'بحث',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.shuffle_outlined, size: 16, color: _textMedium),
              const SizedBox(width: 6),
              Text(
                'النتائج تظهر بشكل عشوائي ومناسب للميدان',
                style: GoogleFonts.cairo(color: _textMedium, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Case caseItem) {
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
                _buildPriorityBadge(caseItem.priority),
                const Spacer(),
                if (caseItem.organizationName != null)
                  Text(
                    caseItem.organizationName!,
                    style: GoogleFonts.cairo(
                      color: _textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              caseItem.title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              caseItem.description,
              style: GoogleFonts.cairo(fontSize: 13, color: _textMedium, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: _friendlyBlue),
                const SizedBox(width: 4),
                Text(
                  caseItem.governorate,
                  style: GoogleFonts.cairo(color: _textMedium, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 16, color: _friendlyBlue),
                const SizedBox(width: 4),
                Text(
                  caseItem.category,
                  style: GoogleFonts.cairo(color: _textMedium, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.caseDetails,
                      arguments: {'caseId': caseItem.id},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_friendlyBlue, _softTeal],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'عرض',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final priorityConfig = {
      'urgent': {'label': 'عاجل', 'color': Colors.red},
      'high': {'label': 'مرتفع', 'color': Colors.orange},
      'medium': {'label': 'متوسط', 'color': Colors.amber.shade700},
      'low': {'label': 'منخفض', 'color': Colors.green},
    };

    final config = priorityConfig[priority] ?? priorityConfig['medium']!;
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
              Icons.search_off_outlined,
              size: 48,
              color: _friendlyBlue.withAlpha(80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حالات متاحة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
