import 'package:flutter/material.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../../organization/domain/entities/org_case.dart';
import '../../../user/domain/entities/case.dart';
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

class VolunteerAvailableCasesScreen extends StatefulWidget {
  const VolunteerAvailableCasesScreen({super.key});

  @override
  State<VolunteerAvailableCasesScreen> createState() => _VolunteerAvailableCasesScreenState();
}

class _VolunteerAvailableCasesScreenState extends State<VolunteerAvailableCasesScreen> {
  bool _isLoading = true;
  List<Case> _cases = [];
  final _searchController = TextEditingController();

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
                  content: Text('فشل تحميل الحالات: ${failure.message}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
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
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          'بحث الحالات (المتطوعين)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
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
                        color: friendlyBlue,
                        backgroundColor: cardWhite,
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

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _loadCases(),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم الحالة أو المحافظة...',
                      hintStyle: TextStyle(color: textLight, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: friendlyBlue),
                      filled: true,
                      fillColor: softBlueTint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: friendlyBlue, width: 1.5),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [friendlyBlue, softTeal],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'بحث',
                      style: TextStyle(
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
              Icon(Icons.shuffle_outlined, size: 16, color: textMedium),
              const SizedBox(width: 6),
              Text(
                'النتائج تظهر بشكل عشوائي',
                style: TextStyle(color: textMedium, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Case caseItem) {
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
                _buildPriorityBadge(caseItem.priority),
                const Spacer(),
                if (caseItem.organizationName != null)
                  Text(
                    caseItem.organizationName!,
                    style: TextStyle(color: textMedium, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              caseItem.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              caseItem.description,
              style: TextStyle(fontSize: 14, color: textMedium),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(caseItem.governorate,
                    style: TextStyle(color: textMedium, fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 16, color: textLight),
                const SizedBox(width: 4),
                Text(caseItem.category,
                    style: TextStyle(color: textMedium, fontSize: 13)),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [friendlyBlue, softTeal],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'عرض',
                      style: TextStyle(
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
              Icons.search_off_outlined,
              size: 48,
              color: friendlyBlue.withAlpha(80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حالات متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
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
