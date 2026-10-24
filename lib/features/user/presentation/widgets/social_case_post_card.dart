import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/case.dart';
import '../../domain/repositories/user_repository.dart';
import '../bloc/favorites_bloc/favorites_cubit.dart';
import '../screens/field_reels_screen.dart';
import 'comments_bottom_sheet.dart';
import 'sham_cash_donation_sheet.dart';

/// A campaign-style card inspired by GoFundMe / LaunchGood.
/// Image on top, metadata & progress below — clean and trustworthy.
class SocialCasePostCard extends StatefulWidget {
  final Case caseItem;
  final List<Case>? allCases;
  final int caseIndex;
  final VoidCallback? onTap;

  const SocialCasePostCard({
    super.key,
    required this.caseItem,
    this.allCases,
    this.caseIndex = 0,
    this.onTap,
  });

  @override
  State<SocialCasePostCard> createState() => _SocialCasePostCardState();
}

class _SocialCasePostCardState extends State<SocialCasePostCard> {
  late Case _case;
  bool _isLiked = false;
  int _likesCount = 0;
  int _commentsCount = 0;
  double _collectedAmount = 0;
  int _progressPercent = 0;
  bool _showHeartBurst = false;
  bool _isFavorited = false;

  final NumberFormat _fmt = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _syncFromCase(widget.caseItem);
  }

  @override
  void didUpdateWidget(covariant SocialCasePostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caseItem != widget.caseItem) {
      _syncFromCase(widget.caseItem);
    }
  }

  void _syncFromCase(Case c) {
    _case = c;
    _likesCount = c.likesCount;
    _commentsCount = c.commentsCount;
    _collectedAmount = c.collectedAmount;
    _progressPercent = c.progressPercent;
    _isFavorited =
        locator<FavoritesCubit>().isFavorited(c.id) || c.isFavorited;
  }

  // ─── Actions ────────────────────────────────────────────────────────

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    setState(() {
      _showHeartBurst = true;
      if (!_isLiked) {
        _isLiked = true;
        _likesCount += 1;
        _syncLikeBackend();
      }
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showHeartBurst = false);
    });
  }

  void _toggleLike() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      if (_likesCount < 0) _likesCount = 0;
    });
    if (_isLiked) _syncLikeBackend();
  }

  Future<void> _syncLikeBackend() async {
    try {
      await locator<UserRepository>().toggleLikeCase(_case.id);
    } catch (_) {}
  }

  void _toggleFavorite() {
    HapticFeedback.selectionClick();
    final cubit = locator<FavoritesCubit>();
    cubit.toggleFavorite(_case);
    setState(() => _isFavorited = cubit.isFavorited(_case.id));
  }

  void _openReels() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FieldReelsScreen(
          initialIndex: widget.caseIndex,
          initialCases: widget.allCases,
          isStandalone: true,
        ),
      ),
    );
  }

  void _openComments() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(caseItem: _case),
    );
  }

  void _openDonation() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShamCashDonationSheet(caseItem: _case),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          if (result['new_collected_amount'] != null) {
            _collectedAmount =
                (result['new_collected_amount'] as num).toDouble();
          }
          if (result['progress_percent'] != null) {
            _progressPercent = (result['progress_percent'] as num).toInt();
          }
        });
      }
    });
  }

  void _sharePost() {
    Clipboard.setData(ClipboardData(
      text:
          'حالة إنسانية موثقة: ${_case.title}\nيمكنك التبرع عبر شام كاش في تطبيق أثر',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'تم نسخ رابط الحالة',
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap ?? _openReels,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
              // ── Image Section ──
              _buildImage(isDark),
              // ── Content Section ──
              _buildContent(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image (Top Half) ───────────────────────────────────────────────
  Widget _buildImage(bool isDark) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _case.thumbnail != null && _case.thumbnail!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _case.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFEEECE6),
                    ),
                    errorWidget: (context, url, error) => _imageFallback(isDark),
                  )
                : _imageFallback(isDark),
          ),

          // Category chip (top-left)
          if (_case.category.isNotEmpty)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withAlpha(140)
                      : Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _case.category,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF333333),
                  ),
                ),
              ),
            ),

          // Urgent indicator
          if (_case.priority == 'urgent')
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD44A3E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'عاجل',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Reels play indicator (bottom-left)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    'الميدان',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Heart burst on double-tap
          if (_showHeartBurst)
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 72,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.1, 1.1),
                      duration: 250.ms,
                      curve: Curves.elasticOut,
                    )
                    .then(delay: 350.ms)
                    .fadeOut(duration: 250.ms),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1A2436) : const Color(0xFFE8E6E0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism_rounded,
              color: isDark ? Colors.white12 : const Color(0xFFCCCCC5),
              size: 40,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _case.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: isDark ? Colors.white30 : const Color(0xFF999999),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Content (Bottom Half) ──────────────────────────────────────────
  Widget _buildContent(bool isDark) {
    final percentDecimal = (_progressPercent / 100.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization row
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D5E),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'أ',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'منظمة أثر',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : const Color(0xFF777777),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.verified_rounded,
                color: const Color(0xFF2E7D5E),
                size: 13,
              ),
              const Spacer(),
              // Location
              if (_case.governorate.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 12,
                      color: isDark ? Colors.white30 : const Color(0xFFAAAAAA),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _case.governorate,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color:
                            isDark ? Colors.white30 : const Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            _case.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              height: 1.35,
            ),
          ),

          // Description snippet
          if (_case.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _case.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: isDark ? Colors.white38 : const Color(0xFF888888),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Progress bar — thicker and more visible (GoFundMe style)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentDecimal,
              backgroundColor:
                  isDark ? AppColors.darkBorder : const Color(0xFFEDEBE5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D5E)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Amount + percent row
          Row(
            children: [
              Text(
                '${_fmt.format(_collectedAmount)} ل.س',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                ' جُمعت من ${_fmt.format(_case.targetAmount)} ل.س',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white30 : const Color(0xFF999999),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : const Color(0xFFEDEBE5),
          ),

          const SizedBox(height: 10),

          // Bottom action row — minimal icons + donate CTA
          Row(
            children: [
              // Like
              _actionIcon(
                icon: _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                label: '$_likesCount',
                color: _isLiked
                    ? const Color(0xFFD44A3E)
                    : (isDark ? Colors.white54 : const Color(0xFF888888)),
                isDark: isDark,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 16),

              // Comment
              _actionIcon(
                icon: Icons.chat_bubble_outline_rounded,
                label: '$_commentsCount',
                color: isDark ? Colors.white54 : const Color(0xFF888888),
                isDark: isDark,
                onTap: _openComments,
              ),
              const SizedBox(width: 16),

              // Share
              _actionIcon(
                icon: Icons.share_outlined,
                color: isDark ? Colors.white54 : const Color(0xFF888888),
                isDark: isDark,
                onTap: _sharePost,
              ),

              const Spacer(),

              // Bookmark
              GestureDetector(
                onTap: _toggleFavorite,
                child: Icon(
                  _isFavorited
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 22,
                  color: _isFavorited
                      ? const Color(0xFF2E7D5E)
                      : (isDark ? Colors.white38 : const Color(0xFFAAAAAA)),
                ),
              ),
              const SizedBox(width: 12),

              // Donate CTA
              GestureDetector(
                onTap: _openDonation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D5E),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D5E).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'تبرع',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    String? label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
