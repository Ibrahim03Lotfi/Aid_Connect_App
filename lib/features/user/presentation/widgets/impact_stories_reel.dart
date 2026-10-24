import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';

class ImpactStory {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final String description;
  final String timeAgo;
  final String impactMetric;

  const ImpactStory({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.timeAgo,
    required this.impactMetric,
  });
}

class ImpactStoriesReel extends StatelessWidget {
  const ImpactStoriesReel({super.key});

  static const List<ImpactStory> demoStories = [
    ImpactStory(
      id: '1',
      title: 'دفء ريف دمشق',
      location: 'جرمانا، ريف دمشق',
      imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
      description: 'بفضل مساهمتكم المباشرة، تم اليوم توزيع 48 سلة غذائية وبطانيات صوفية للعائلات المتضررة من الصقيع.',
      timeAgo: 'منذ ساعتين',
      impactMetric: '48 عائلة استفادت اليوم',
    ),
    ImpactStory(
      id: '2',
      title: 'عملية قلب لطفل',
      location: 'مشفى المواساة، دمشق',
      imageUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=800',
      description: 'تكللت عملية القلب المفتوح للطفل عمر بالنجاح التام بعد اكتمال تغطية تكاليف الجراحة والمستلزمات الطبية.',
      timeAgo: 'منذ 5 ساعات',
      impactMetric: 'نجاح العملية 100%',
    ),
    ImpactStory(
      id: '3',
      title: 'إغاثة أطفال حلب',
      location: 'حي السليمانية، حلب',
      imageUrl: 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
      description: 'تسليم حقائب الحليب والمكملات الغذائية للأمهات والأطفال في مراكز الإيواء المؤقتة.',
      timeAgo: 'منذ يوم',
      impactMetric: '120 طفلاً تم تأمين حليبهم',
    ),
    ImpactStory(
      id: '4',
      title: 'كسوة الشتاء بحمص',
      location: 'الوعر، حمص',
      imageUrl: 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800',
      description: 'توزيع معاطف شتوية وأحذية حرارية لطلاب المدارس الابتدائية لحمايتهم من برد الشتاء.',
      timeAgo: 'منذ يومين',
      impactMetric: '85 طالباً تم كسوتهم',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.5, 1.5),
                        duration: 800.ms,
                      ),
                  const SizedBox(width: 8),
                  Text(
                    'أثر في الميدان (سلسلة أثر)',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'توثيق حي',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: demoStories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final story = demoStories[index];
              return _buildStoryAvatar(context, story, index, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryAvatar(BuildContext context, ImpactStory story, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => StoryViewerDialog(story: story),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF0284C7), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(isDark ? 60 : 40),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  story.imageUrl,
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 62,
                    height: 62,
                    color: AppColors.primaryLight.withAlpha(50),
                    child: const Icon(Icons.volunteer_activism, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ).animate().scale(delay: (index * 80).ms, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 6),
          SizedBox(
            width: 76,
            child: Text(
              story.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryViewerDialog extends StatefulWidget {
  final ImpactStory story;

  const StoryViewerDialog({super.key, required this.story});

  @override
  State<StoryViewerDialog> createState() => _StoryViewerDialogState();
}

class _StoryViewerDialogState extends State<StoryViewerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..forward().then((_) {
        if (mounted) Navigator.of(context).pop();
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              widget.story.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.navyDark,
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white54, size: 64),
                ),
              ),
            ),

            // Top & Bottom Gradient Shadows
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(180),
                    Colors.transparent,
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Header & Progress Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 3,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'منظمة أثر للإغاثة والتنمية',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.primaryLight, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.story.location} • ${widget.story.timeAgo}',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Description Card
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(30), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withAlpha(120)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            widget.story.impactMetric,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.story.description,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
