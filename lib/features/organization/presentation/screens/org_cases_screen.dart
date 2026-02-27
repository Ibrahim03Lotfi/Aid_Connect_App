import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/org_case.dart';
import '../../domain/repositories/organization_repository.dart';
import '../bloc/org_cases_bloc/org_cases_bloc.dart';
import '../bloc/org_cases_bloc/org_cases_event.dart';
import '../bloc/org_cases_bloc/org_cases_state.dart';

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

class OrgCasesScreen extends StatelessWidget {
  const OrgCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrgCasesBloc(
        repository: locator<OrganizationRepository>(),
      )..add(const FetchOrgCasesEvent()),
      child: const OrgCasesView(),
    );
  }
}

class OrgCasesView extends StatefulWidget {
  const OrgCasesView({super.key});

  @override
  State<OrgCasesView> createState() => _OrgCasesViewState();
}

class _OrgCasesViewState extends State<OrgCasesView> {
  String? _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _filters = [
    {'label': 'الكل', 'value': null},
    {'label': 'معلق', 'value': 'pending'},
    {'label': 'مقبول', 'value': 'approved'},
    {'label': 'مرفوض', 'value': 'rejected'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrgCasesBloc>().add(const LoadMoreOrgCasesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          'حالات المنظمة',
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
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createCase);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<OrgCasesBloc, OrgCasesState>(
              listener: (context, state) {
                if (state is OrgCaseDeleted) {
                  _showSnackBar(state.message, softTeal);
                }
                if (state is OrgCasesError) {
                  _showSnackBar(state.message, Colors.red);
                }
              },
              builder: (context, state) {
                if (state is OrgCasesLoading) {
                  return _buildLoadingView();
                }

                if (state is OrgCasesError && state is! OrgCasesLoaded) {
                  return _buildErrorState(state.message);
                }

                if (state is OrgCasesLoaded ||
                    state is OrgCasesLoadingMore ||
                    state is OrgCaseDeleting) {
                  final cases = state is OrgCasesLoaded
                      ? state.cases
                      : state is OrgCasesLoadingMore
                          ? (state as OrgCasesLoadingMore).currentCases
                          : state is OrgCaseDeleting
                              ? (context.read<OrgCasesBloc>().state
                                      as OrgCasesLoaded)
                                  .cases
                              : [];

                  if (cases.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<OrgCasesBloc>()
                          .add(RefreshOrgCasesEvent(status: _selectedFilter));
                    },
                    color: friendlyBlue,
                    backgroundColor: cardWhite,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: cases.length + (state is OrgCasesLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == cases.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(friendlyBlue),
                                ),
                              ),
                            ),
                          );
                        }
                        return _buildCaseCard(cases[index]);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            final isAll = filter['value'] == null;
            final color = isAll
                ? friendlyBlue
                : _getFilterColor(filter['value'] as String?);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter['value'];
                  });
                  context.read<OrgCasesBloc>().add(
                    FilterByStatusEvent(status: _selectedFilter),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(20) : cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : borderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    filter['label'] as String,
                    style: TextStyle(
                      color: isSelected ? color : textMedium,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getFilterColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return softTeal;
      case 'rejected':
        return Colors.red;
      default:
        return friendlyBlue;
    }
  }

  Widget _buildCaseCard(OrgCase orgCase) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.caseDetails,
          arguments: {'caseId': orgCase.id},
        );
      },
      child: Container(
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
                  _buildStatusBadge(orgCase.status),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(orgCase.priority),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(orgCase),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                orgCase.title,
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
                orgCase.description,
                style: TextStyle(
                  fontSize: 14,
                  color: textMedium,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (orgCase.isRejected && orgCase.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(30), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سبب الرفض:',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orgCase.rejectionReason!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: textLight),
                  const SizedBox(width: 4),
                  Text(
                    orgCase.governorate,
                    style: TextStyle(
                      fontSize: 13,
                      color: textMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category_outlined,
                      size: 16, color: textLight),
                  const SizedBox(width: 4),
                  Text(
                    orgCase.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: textMedium,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(orgCase.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                ],
              ),
              if (orgCase.isApproved) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined,
                        size: 14, color: textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${orgCase.views}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.favorite_outline,
                        size: 14, color: textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${orgCase.donationsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusConfig = <String, Map<String, dynamic>>{
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

  Widget _buildPriorityBadge(String priority) {
    final priorityConfig = <String, Map<String, dynamic>>{
      'urgent': {'label': 'عاجل', 'color': Colors.red},
      'high': {'label': 'مرتفع', 'color': Colors.orange},
      'medium': {'label': 'متوسط', 'color': Colors.amber.shade700},
      'low': {'label': 'منخفض', 'color': Colors.green},
    };

    final config = priorityConfig[priority] ?? priorityConfig['medium']!;
    final color = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
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
              color: softBlueTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_outlined,
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
            'اضغط على + لإضافة حالة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red.withAlpha(100),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: textMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              context
                  .read<OrgCasesBloc>()
                  .add(FetchOrgCasesEvent(status: _selectedFilter));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [friendlyBlue, softTeal],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(OrgCase orgCase) {
    showDialog(
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
            const Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف "${orgCase.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: textMedium),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<OrgCasesBloc>().add(DeleteCaseEvent(orgCase.id));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'حذف',
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
