import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../services/locator.dart';
import '../../domain/entities/case.dart';
import '../../domain/repositories/user_repository.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/sham_cash_donation_sheet.dart';

class FieldReelsScreen extends StatefulWidget {
  final int initialIndex;
  final List<Case>? initialCases;
  final bool isStandalone; // True when pushed with back button, False when in bottom nav

  const FieldReelsScreen({
    super.key,
    this.initialIndex = 0,
    this.initialCases,
    this.isStandalone = false,
  });

  @override
  State<FieldReelsScreen> createState() => _FieldReelsScreenState();
}

class _FieldReelsScreenState extends State<FieldReelsScreen> {
  late PageController _pageController;
  List<Case> _cases = [];
  bool _isLoading = true;
  final Map<int, bool> _likedCases = {};
  final Map<int, int> _likesCounts = {};
  final Map<int, double> _collectedAmounts = {};
  final Map<int, int> _progressPercents = {};
  final Map<int, bool> _showHeartBurst = {};

  final NumberFormat _currencyFormatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.initialCases != null && widget.initialCases!.isNotEmpty) {
      _cases = List.from(widget.initialCases!);
      _initCaseStates();
      _isLoading = false;
    } else {
      _loadCases();
    }
  }

  void _initCaseStates() {
    for (final c in _cases) {
      _likesCounts[c.id] = c.likesCount;
      _collectedAmounts[c.id] = c.collectedAmount;
      _progressPercents[c.id] = c.progressPercent;
      _likedCases[c.id] = false;
    }
  }

  Future<void> _loadCases() async {
    try {
      final repo = locator<UserRepository>();
      final result = await repo.getAllCases();
      result.fold(
        (failure) {
          if (mounted) setState(() => _isLoading = false);
        },
        (cases) {
          if (mounted) {
            setState(() {
              _cases = cases;
              _initCaseStates();
              _isLoading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap(Case caseItem) {
    HapticFeedback.mediumImpact();
    setState(() {
      _showHeartBurst[caseItem.id] = true;
      if (!(_likedCases[caseItem.id] ?? false)) {
        _likedCases[caseItem.id] = true;
        _likesCounts[caseItem.id] = (_likesCounts[caseItem.id] ?? caseItem.likesCount) + 1;
        _syncLikeBackend(caseItem.id);
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _showHeartBurst[caseItem.id] = false;
        });
      }
    });
  }

  void _toggleLike(Case caseItem) {
    HapticFeedback.selectionClick();
    final currentLiked = _likedCases[caseItem.id] ?? false;
    setState(() {
      _likedCases[caseItem.id] = !currentLiked;
      final currentCount = _likesCounts[caseItem.id] ?? caseItem.likesCount;
      _likesCounts[caseItem.id] = !currentLiked ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0);
    });

    if (!currentLiked) {
      _syncLikeBackend(caseItem.id);
    }
  }

  Future<void> _syncLikeBackend(int caseId) async {
    try {
      final repo = locator<UserRepository>();
      await repo.toggleLikeCase(caseId);
    } catch (_) {}
  }

  void _openComments(Case caseItem) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(caseItem: caseItem),
    );
  }

  void _openDonation(Case caseItem) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShamCashDonationSheet(caseItem: caseItem),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          if (result['new_collected_amount'] != null) {
            _collectedAmounts[caseItem.id] = (result['new_collected_amount'] as num).toDouble();
          }
          if (result['progress_percent'] != null) {
            _progressPercents[caseItem.id] = (result['progress_percent'] as num).toInt();
          }
        });
      }
    });
  }

  void _shareReel(Case caseItem) {
    Clipboard.setData(ClipboardData(
      text: 'شاهد توثيق الحالة الميدانية: ${caseItem.title}\nمنظمة أثر للإغاثة والتنمية - التبرع متاح عبر شام كاش',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ رابط التوثيق الميداني',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isStandalone
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withAlpha(50), width: 0.8),
              ),
              child: Center(
                child: Text(
                  'أثر',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'الميدان',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _cases.isEmpty
              ? _buildEmptyState()
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _cases.length,
                  itemBuilder: (context, index) {
                    final item = _cases[index];
                    return _buildReelPage(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            'لا توجد توثيقات ميدانية متوفرة حالياً',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelPage(Case caseItem) {
    final isLiked = _likedCases[caseItem.id] ?? false;
    final likesCount = _likesCounts[caseItem.id] ?? caseItem.likesCount;
    final collectedAmount = _collectedAmounts[caseItem.id] ?? caseItem.collectedAmount;
    final progressPercent = _progressPercents[caseItem.id] ?? caseItem.progressPercent;
    final showHeartBurst = _showHeartBurst[caseItem.id] ?? false;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full Screen Media with Gesture Detection
        GestureDetector(
          onDoubleTap: () => _onDoubleTap(caseItem),
          child: Container(
            color: Colors.black,
            child: caseItem.thumbnail != null && caseItem.thumbnail!.isNotEmpty
                ? Image.network(
                    caseItem.thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildReelFallback(caseItem),
                  )
                : _buildReelFallback(caseItem),
          ),
        ),

        // 2. Cinematic Gradient Overlays (Top & Bottom for text readability)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(200),
                ],
                stops: const [0.0, 0.2, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // 3. Double-Tap Animated Heart Burst (Center)
        if (showHeartBurst)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(80),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 90,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1.2, 1.2),
                  duration: 250.ms,
                  curve: Curves.elasticOut,
                )
                .then(delay: 350.ms)
                .fadeOut(duration: 250.ms),
          ),

        // 4. Side Action Rail (Instagram Reels Style - Right/Left depending on RTL)
        Positioned(
          bottom: 40,
          left: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like Button
              _buildSideActionButton(
                icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                iconColor: isLiked ? const Color(0xFFEF4444) : Colors.white,
                label: '$likesCount',
                onTap: () => _toggleLike(caseItem),
              ),
              const SizedBox(height: 18),

              // Comments Button
              _buildSideActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.white,
                label: '${caseItem.commentsCount}',
                onTap: () => _openComments(caseItem),
              ),
              const SizedBox(height: 18),

              // Sham Cash Donation Hero Button (Standout Syrian Payment)
              GestureDetector(
                onTap: () => _openDonation(caseItem),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withAlpha(80),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تبرع',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),

              // Share Button
              _buildSideActionButton(
                icon: Icons.send_rounded,
                iconColor: Colors.white,
                label: 'مشاركة',
                onTap: () => _shareReel(caseItem),
              ),
              const SizedBox(height: 18),

              // Spinning Vinyl Audio Disc (Instagram / TikTok Style)
              _buildSpinningAudioDisc(),
            ],
          ),
        ),

        // 5. Bottom Narrative Info & Syrian Funding Progress
        Positioned(
          bottom: 30,
          right: 16,
          left: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Organization Header & Follow
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF10B981)],
                      ),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'أثر',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      caseItem.organizationName ?? 'منظمة أثر للإغاثة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 15),
                ],
              ),
              const SizedBox(height: 8),

              // Case Title
              Text(
                caseItem.title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description Snippet
              if (caseItem.description.isNotEmpty)
                Text(
                  caseItem.description,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),

              // Governorate Tag & Live Verification Seal
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white70, size: 13),
                  const SizedBox(width: 3),
                  Text(
                    caseItem.governorate.isNotEmpty ? caseItem.governorate : 'دمشق',
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('•', style: GoogleFonts.cairo(color: Colors.white54)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
                    ),
                    child: Text(
                      'توثيق ميداني معتمد NFC',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Syrian Funding Progress Bar Overlay
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تم جمع: ${_currencyFormatter.format(collectedAmount)} ل.س',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$progressPercent%',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progressPercent / 100.0).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withAlpha(40),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinningAudioDisc() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 4.seconds);
  }

  Widget _buildReelFallback(Case caseItem) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0369A1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                caseItem.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'توثيق ميداني حي • منظمة أثر',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
