import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/governorate.dart';
import '../bloc/governorate_bloc/governorate_bloc.dart';
import '../bloc/governorate_bloc/governorate_event.dart';
import '../bloc/governorate_bloc/governorate_state.dart';

class GovernoratesScreen extends StatelessWidget {
  final int? categoryId;

  const GovernoratesScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<GovernorateBloc>()
        ..add(FetchGovernoratesEvent(categoryId: categoryId)),
      child: GovernoratesView(categoryId: categoryId),
    );
  }
}

class GovernoratesView extends StatelessWidget {
  final int? categoryId;

  const GovernoratesView({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحافظات'),
        centerTitle: true,
      ),
      body: BlocBuilder<GovernorateBloc, GovernorateState>(
        builder: (context, state) {
          if (state is GovernorateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GovernorateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<GovernorateBloc>()
                          .add(const RefreshGovernorateDataEvent());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is GovernorateLoaded || state is CasesLoadingMore) {
            final govState = state is GovernorateLoaded
                ? state
                : (state as CasesLoadingMore).governorates.isNotEmpty
                    ? GovernorateLoaded(
                        governorates: (state as CasesLoadingMore).governorates,
                        cases: (state as CasesLoadingMore).currentCases,
                        selectedGovernorateId:
                            (state as CasesLoadingMore).selectedGovernorateId,
                        selectedCategoryId:
                            (state as CasesLoadingMore).selectedCategoryId,
                      )
                    : null;

            if (govState == null) return const SizedBox.shrink();

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختر المحافظة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: govState.governorates.length,
                          itemBuilder: (context, index) {
                            final gov = govState.governorates[index];
                            final isSelected =
                                govState.selectedGovernorateId == gov.id;
                            return _GovernorateChip(
                              governorate: gov,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<GovernorateBloc>().add(
                                      SelectGovernorateEvent(gov.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (govState.selectedGovernorateId != null)
                  Expanded(
                    child: govState.cases.isEmpty
                        ? const Center(
                            child: Text('لا توجد حالات في هذه المحافظة'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: govState.cases.length +
                                (state is CasesLoadingMore ? 1 : 0) +
                                (govState.hasMoreCases &&
                                        state is! CasesLoadingMore
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index < govState.cases.length) {
                                final caseItem = govState.cases[index];
                                return _CaseCard(
                                  caseItem: caseItem,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.caseDetails,
                                      arguments: {'caseId': caseItem.id},
                                    );
                                  },
                                );
                              } else if (state is CasesLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (govState.hasMoreCases) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<GovernorateBloc>().add(
                                            const FetchMoreCasesEvent(),
                                          );
                                    },
                                    child: const Text('تحميل المزيد'),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text(
                        'اختر محافظة لعرض الحالات',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GovernorateChip extends StatelessWidget {
  final Governorate governorate;
  final bool isSelected;
  final VoidCallback onTap;

  const _GovernorateChip({
    required this.governorate,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              governorate.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${governorate.casesCount} حالة',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Case caseItem;
  final VoidCallback onTap;

  const _CaseCard({
    required this.caseItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: caseItem.thumbnail != null
                    ? Image.network(
                        caseItem.thumbnail!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(caseItem.priority)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPriorityText(caseItem.priority),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPriorityColor(caseItem.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${caseItem.views}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caseItem.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caseItem.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  caseItem.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: caseItem.isFavorited ? Colors.red : Colors.grey,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey, size: 30),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'مرتفع';
      case 'medium':
        return 'متوسط';
      default:
        return 'عادي';
    }
  }
}
