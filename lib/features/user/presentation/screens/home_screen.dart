import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/case.dart';
import '../bloc/home_bloc/home_bloc.dart';
import '../bloc/home_bloc/home_event.dart';
import '../bloc/home_bloc/home_state.dart';
import '../widgets/impact_stories_reel.dart';
import '../widgets/sham_cash_donation_sheet.dart';
import '../widgets/social_case_post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<HomeBloc>()..add(const FetchHomeDataEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final NumberFormat _currencyFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : const Color(0xFFF5F5F0),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const _FeedLoadingSkeleton();
          }

          if (state is HomeError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<HomeBloc>().add(const FetchHomeDataEvent());
              },
            );
          }

          if (state is HomeLoaded || state is CasesLoadingMore) {
            final moreState = state is CasesLoadingMore ? state : null;
            final homeState = state is HomeLoaded
                ? state
                : (moreState != null && moreState.categories.isNotEmpty)
                    ? HomeLoaded(
                        categories: moreState.categories,
                        cases: moreState.currentCases,
                        urgentCases: moreState.urgentCases,
                        selectedCategoryId: moreState.selectedCategoryId,
                      )
                    : null;

            if (homeState == null) return const SizedBox.shrink();

            final cases = homeState.cases;
            final urgentList = homeState.urgentCases.isNotEmpty
                ? homeState.urgentCases
                : (cases.where((c) => c.priority.toLowerCase() == 'urgent').isNotEmpty
                    ? cases.where((c) => c.priority.toLowerCase() == 'urgent').toList()
                    : (cases.isNotEmpty ? [cases.first] : <Case>[]));

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshHomeDataEvent());
              },
              color: isDark ? Colors.white : const Color(0xFF2D2D2D),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ─── 1. Collapsing App Bar with Greeting ──────────
                  _buildSliverAppBar(context, isDark),

                  // ─── 2. Top Impact Stories ("سلسلة أثر") ─────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: ImpactStoriesReel(),
                    ),
                  ),

                  // ─── 3. Featured Urgent Case (Hero) ───────────────
                  if (urgentList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _UrgentHeroSection(
                        urgentCases: urgentList,
                        currencyFormatter: _currencyFormatter,
                      ),
                    ),

                  // ─── 4. Quick Live Statistics ─────────────────────
                  if (cases.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildQuickStats(cases, isDark),
                    ),

                  // ─── 5. Citizen & Donor Quick Actions Hub ─────────
                  SliverToBoxAdapter(
                    child: _buildCitizenQuickActions(context, isDark),
                  ),

                  // ─── 6. Category Chips ────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildCategorySection(context, homeState, isDark),
                  ),

                  // ─── 7. Cases Feed ────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(
                      'الحالات الإنسانية',
                      count: cases.length,
                      isDark: isDark,
                    ),
                  ),

                  if (homeState.isCategoryLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white38 : const Color(0xFFBBBBBB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (cases.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyState(context, isDark),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < cases.length) {
                            return SocialCasePostCard(
                              caseItem: cases[index],
                              allCases: cases,
                              caseIndex: index,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.caseDetails,
                                  arguments: {'caseId': cases[index].id},
                                );
                              },
                            );
                          } else if (state is CasesLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? Colors.white30 : const Color(0xFFBBBBBB),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        childCount: cases.length + (state is CasesLoadingMore ? 1 : 0),
                      ),
                    ),

                  // ─── 6. Load More ─────────────────────────────────
                  if (homeState.hasMoreCases &&
                      state is! CasesLoadingMore &&
                      !homeState.isCategoryLoading)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: GestureDetector(
                          onTap: () {
                            context.read<HomeBloc>().add(const FetchMoreCasesEvent());
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'تحميل المزيد',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Sliver App Bar — warm, editorial, like a news app
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = (hour < 12) ? 'صباح الخير' : 'مساء الخير';

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: (isDark ? AppColors.darkScaffold : const Color(0xFFF5F5F0)).withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 76,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            greeting,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF888888),
              height: 1.1,
            ),
          ),
          Row(
            children: [
              Text(
                'أثر',
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D5E),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Quick Theme Switcher
        _buildAppBarAction(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          isDark: isDark,
          onTap: () {
            HapticFeedback.selectionClick();
            locator<ThemeService>().setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
            );
          },
        ),
        // Search
        _buildAppBarAction(
          icon: Icons.search_rounded,
          isDark: isDark,
          onTap: () => Navigator.pushNamed(context, AppRoutes.governorates),
        ),
        // Notifications
        Stack(
          alignment: Alignment.center,
          children: [
            _buildAppBarAction(
              icon: Icons.notifications_none_rounded,
              isDark: isDark,
              onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            Positioned(
              top: 12,
              right: 14,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFD44A3E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkScaffold : const Color(0xFFF5F5F0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white70 : const Color(0xFF555555),
          size: 20,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Quick Stats — inspired by LaunchGood's impact counters
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildQuickStats(List<Case> cases, bool isDark) {
    final totalCollected = cases.fold<double>(
      0, (sum, c) => sum + c.collectedAmount,
    );
    final totalTarget = cases.fold<double>(
      0, (sum, c) => sum + c.targetAmount,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE8E6E0),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'حالة نشطة',
            value: '${cases.length}',
            isDark: isDark,
          ),
          _statDivider(isDark),
          _StatItem(
            label: 'تم جمعه',
            value: '${_currencyFormatter.format(totalCollected)} ل.س',
            isDark: isDark,
            valueColor: const Color(0xFF2E7D5E),
          ),
          _statDivider(isDark),
          _StatItem(
            label: 'المستهدف',
            value: '${_currencyFormatter.format(totalTarget)} ل.س',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? AppColors.darkBorder : const Color(0xFFE8E6E0),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Citizen & Donor Quick Actions Hub (Phase 2)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCitizenQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {
        'title': 'طلب مساعدة',
        'subtitle': 'معالج مرئي 3 خطوات',
        'icon': Icons.assignment_add,
        'gradient': const [Color(0xFF0284C7), Color(0xFF0369A1)],
        'route': AppRoutes.requestAidWizard,
      },
      {
        'title': 'تتبع المساعدات',
        'subtitle': 'مسار التوثيق الميداني',
        'icon': Icons.track_changes_rounded,
        'gradient': const [Color(0xFF059669), Color(0xFF10B981)],
        'route': AppRoutes.caseTracking,
      },
      {
        'title': 'انضم كمتطوع',
        'subtitle': 'فرق الاستجابة الميدانية',
        'icon': Icons.volunteer_activism_rounded,
        'gradient': const [Color(0xFFD97706), Color(0xFFF59E0B)],
        'route': AppRoutes.joinVolunteer,
      },
      {
        'title': 'سلسلة أثر',
        'subtitle': 'قصص وتوثيق حي',
        'icon': Icons.play_circle_fill_rounded,
        'gradient': const [Color(0xFFE11D48), Color(0xFFF43F5E)],
        'route': AppRoutes.reels,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'خدمات أثر الرقمية',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'بوابة المواطن',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(context, actions[0], isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(context, actions[1], isDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(context, actions[2], isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(context, actions[3], isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    Map<String, dynamic> action,
    bool isDark,
  ) {
    final gradient = action['gradient'] as List<Color>;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, action['route'] as String);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE8E6E0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withAlpha(50),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  action['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action['subtitle'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Category Section
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCategorySection(
    BuildContext context,
    HomeLoaded homeState,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'تصفح حسب التصنيف',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: homeState.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final isSelected = isAll
                  ? homeState.selectedCategoryId == null
                  : homeState.selectedCategoryId ==
                      homeState.categories[index - 1].id;
              final label =
                  isAll ? 'الكل' : homeState.categories[index - 1].name;

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (isAll) {
                      context
                          .read<HomeBloc>()
                          .add(const CategorySelectedEvent(0));
                    } else {
                      context.read<HomeBloc>().add(
                            CategorySelectedEvent(
                                homeState.categories[index - 1].id),
                          );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFF2E7D5E)
                              : const Color(0xFF1A1A1A))
                          : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: (isDark ? const Color(0xFF2E7D5E) : const Color(0xFF1A1A1A)).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white60
                                  : const Color(0xFF666666)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Section Title
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSectionTitle(String title, {int? count, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              '($count)',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white38 : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFCCCCC5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد حالات في هذا التصنيف',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add(const CategorySelectedEvent(0));
              },
              child: Text(
                'عرض كل الحالات',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF2E7D5E),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Stat Item widget
// ═══════════════════════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ??
                  (isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Urgent Hero Section — Full-width featured carousel
// ═══════════════════════════════════════════════════════════════════════
class _UrgentHeroSection extends StatefulWidget {
  final List<Case> urgentCases;
  final NumberFormat currencyFormatter;

  const _UrgentHeroSection({
    required this.urgentCases,
    required this.currencyFormatter,
  });

  @override
  State<_UrgentHeroSection> createState() => _UrgentHeroSectionState();
}

class _UrgentHeroSectionState extends State<_UrgentHeroSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    if (widget.urgentCases.length <= 1) return;
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.urgentCases.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = widget.urgentCases.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD44A3E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'بحاجة مساعدة عاجلة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),

        // Carousel
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _buildHeroCard(
                context,
                widget.urgentCases[index],
                isDark,
              );
            },
          ),
        ),

        // Page indicators
        if (count > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (i) {
                final active = _currentPage == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 24 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFD44A3E)
                        : (isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFD5D3CD)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, Case heroCase, bool isDark) {
    final collected = heroCase.collectedAmount;
    final target = heroCase.targetAmount;
    final percent = (heroCase.progressPercent / 100.0).clamp(0.0, 1.0);
    final imageUrl = heroCase.thumbnail ??
        (heroCase.images.isNotEmpty ? heroCase.images.first : null);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — top half
            Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark
                                ? const Color(0xFF1F2937)
                                : const Color(0xFFEEECE6),
                          ),
                          errorWidget: (context, url, error) => _heroFallback(isDark),
                        )
                      : _heroFallback(isDark),

                  // Top gradient for badge readability
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(80),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Urgent badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD44A3E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        heroCase.governorate.isNotEmpty
                            ? heroCase.governorate
                            : 'سوريا',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content — bottom half
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      heroCase.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFEDEBE5),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D5E),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Amount row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.currencyFormatter.format(collected)} ل.س',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D5E),
                          ),
                        ),
                        Text(
                          'من ${widget.currencyFormatter.format(target)} ل.س',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Donate button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              ShamCashDonationSheet(caseItem: heroCase),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D5E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'تبرع الآن',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1A2436) : const Color(0xFFE8E6E0),
      child: Center(
        child: Icon(
          Icons.volunteer_activism_rounded,
          color: isDark ? Colors.white12 : const Color(0xFFCCCCC5),
          size: 48,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Shimmer Loading Skeleton
// ═══════════════════════════════════════════════════════════════════════
class _FeedLoadingSkeleton extends StatelessWidget {
  const _FeedLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmer = isDark ? AppColors.darkCard : const Color(0xFFE8E6E0);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Fake app bar
          Row(
            children: [
              Container(
                width: 60,
                height: 28,
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: shimmer, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: shimmer, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fake hero card
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: shimmer,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),

          // Fake stats
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: shimmer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),

          // Fake category chips
          Row(
            children: List.generate(
              4,
              (i) => Container(
                width: 70,
                height: 36,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Fake cards
          ...List.generate(2, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 260,
              decoration: BoxDecoration(
                color: shimmer,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ],
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1200.ms, color: (isDark ? AppColors.darkSurface : const Color(0xFFF0EEE8)).withAlpha(80)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Error View
// ═══════════════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: isDark ? Colors.white24 : const Color(0xFFBBBBBB),
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
}
