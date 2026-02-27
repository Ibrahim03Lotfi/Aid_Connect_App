import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/org_case.dart';
import '../../domain/repositories/organization_repository.dart';
import '../bloc/org_cases_bloc/org_cases_bloc.dart';
import '../bloc/org_cases_bloc/org_cases_event.dart';
import '../bloc/org_cases_bloc/org_cases_state.dart';

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
      appBar: AppBar(
        title: const Text('حالات المنظمة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createCase);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Chips
          _buildFilterChips(),
          
          // Cases List
          Expanded(
            child: BlocConsumer<OrgCasesBloc, OrgCasesState>(
              listener: (context, state) {
                if (state is OrgCaseDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                if (state is OrgCasesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrgCasesLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                          : (state as OrgCaseDeleting).caseId != null
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
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: cases.length + (state is OrgCasesLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == cases.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(filter['label']),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter['value'];
                  });
                  context.read<OrgCasesBloc>().add(
                    FilterByStatusEvent(status: _selectedFilter),
                  );
                },
                selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCaseCard(OrgCase orgCase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.caseDetails,
            arguments: {'caseId': orgCase.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Priority Row
              Row(
                children: [
                  _buildStatusBadge(orgCase.status),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(orgCase.priority),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(orgCase);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                orgCase.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                orgCase.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Rejection Reason (if rejected)
              if (orgCase.isRejected && orgCase.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(100)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red[700],
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
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orgCase.rejectionReason!,
                              style: TextStyle(
                                color: Colors.red[700],
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
              
              // Footer Info
              Row(
                children: [
                  Icon(Icons.location_on_outlined, 
                      size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    orgCase.governorate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category_outlined, 
                      size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    orgCase.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(orgCase.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              
              // Stats (if approved)
              if (orgCase.isApproved) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, 
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${orgCase.views}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.favorite_outline, 
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${orgCase.donationsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
      'approved': {'label': 'مقبول', 'color': Colors.green},
      'rejected': {'label': 'مرفوض', 'color': Colors.red},
    };

    final config = statusConfig[status] ?? statusConfig['pending']!;
    final color = config['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    final priorityConfig = <String, Map<String, dynamic>>{
      'urgent': {'label': 'عاجل', 'color': Colors.red},
      'high': {'label': 'مرتفع', 'color': Colors.orange},
      'medium': {'label': 'متوسط', 'color': Colors.yellow.shade700},
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
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على + لإضافة حالة جديدة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context
                  .read<OrgCasesBloc>()
                  .add(FetchOrgCasesEvent(status: _selectedFilter));
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(OrgCase orgCase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${orgCase.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrgCasesBloc>().add(DeleteCaseEvent(orgCase.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
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
