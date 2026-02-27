import 'package:flutter/material.dart';

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

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                icon,
                size: 48,
                color: iconColor ?? friendlyBlue.withAlpha(80),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: textMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onButtonPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [friendlyBlue, softTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state variants for specific use cases
class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_off_outlined,
      title: 'لا توجد إشعارات',
      subtitle: 'سيتم إشعارك عند حدوث أي جديد',
    );
  }
}

class EmptyCases extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyCases({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'لا توجد حالات',
      subtitle: 'يمكنك استكشاف الحالات المتاحة',
      buttonText: 'استكشاف',
      onButtonPressed: onExplore,
    );
  }
}

class EmptyFavorites extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyFavorites({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_outline,
      title: 'لا توجد مفضلات',
      subtitle: 'أضف الحالات المفضلة لديك للوصول إليها بسهولة',
      buttonText: 'استكشاف الحالات',
      onButtonPressed: onExplore,
    );
  }
}

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off_outlined,
      title: 'لا توجد نتائج',
      subtitle: 'جرب بحثاً بكلمات مختلفة',
    );
  }
}

class EmptyApplications extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyApplications({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: 'لا توجد طلبات',
      subtitle: 'ابحث عن حالات متاحة وقدم طلبك',
      buttonText: 'استكشاف الحالات',
      onButtonPressed: onExplore,
    );
  }
}

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.history_outlined,
      title: 'لا يوجد سجل',
      subtitle: 'ستظهر هنا أنشطتك السابقة',
    );
  }
}
