import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/governorate.dart';
import '../bloc/governorate_bloc/governorate_bloc.dart';
import '../bloc/governorate_bloc/governorate_event.dart';
import '../bloc/governorate_bloc/governorate_state.dart';

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
      backgroundColor: backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: backgroundOffWhite,
        elevation: 0,
        title: Text(
          'المحافظات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: true,
        
      ),
      body: BlocBuilder<GovernorateBloc, GovernorateState>(
        builder: (context, state) {
          if (state is GovernorateLoading) {
            return _buildLoadingView();
          }

          if (state is GovernorateError) {
            return _buildErrorView(state.message, context);
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
                // Governorates Horizontal List
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  decoration: BoxDecoration(
                    color: cardWhite,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر المحافظة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textDark,
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
                // Cases List
                if (govState.selectedGovernorateId != null)
                  Expanded(
                    child: govState.cases.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
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
                                return const _LinearLoadingIndicator();
                              } else if (govState.hasMoreCases) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<GovernorateBloc>().add(
                                            const FetchMoreCasesEvent(),
                                          );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [friendlyBlue, softTeal],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: friendlyBlue.withAlpha(30),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'تحميل المزيد',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                  )
                else
                  Expanded(
                    child: _buildSelectPrompt(),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
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

  Widget _buildErrorView(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<GovernorateBloc>().add(
                  const RefreshGovernorateDataEvent(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [friendlyBlue, softTeal],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: friendlyBlue.withAlpha(30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
              Icons.inbox_outlined,
              color: textLight,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد حالات في هذه المحافظة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPrompt() {
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
              Icons.location_on_outlined,
              color: friendlyBlue.withAlpha(80),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'اختر محافظة لعرض الحالات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textMedium,
            ),
          ),
        ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 90,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [friendlyBlue, softTeal],
                )
              : null,
          color: isSelected ? null : cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: borderLight, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: friendlyBlue.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: friendlyBlue.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(30)
                    : friendlyBlue.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: isSelected ? Colors.white : friendlyBlue,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              governorate.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${governorate.casesCount} حالة',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white.withAlpha(85) : textMedium,
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: friendlyBlue.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: caseItem.thumbnail != null
                    ? Image.network(
                        caseItem.thumbnail!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(caseItem.priority)
                                .withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPriorityText(caseItem.priority),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPriorityColor(caseItem.priority),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 14,
                          color: textMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${caseItem.views}',
                          style: TextStyle(
                            fontSize: 12,
                            color: textMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseItem.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          caseItem.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: textMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: caseItem.isFavorited
                      ? Colors.red.withAlpha(15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  caseItem.isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline,
                  color: caseItem.isFavorited ? Colors.red : textLight,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: softBlueTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image_outlined, color: textLight, size: 28),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber.shade700;
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

class _LinearLoadingIndicator extends StatelessWidget {
  const _LinearLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              backgroundColor: borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(friendlyBlue),
              minHeight: 4,
            ),
          ),
        ),
      ),
    );
  }
}
