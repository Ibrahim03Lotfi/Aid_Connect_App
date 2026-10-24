import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/themes/app_theme.dart';
import 'field_reels_screen.dart';
import 'favorites_screen.dart';
import 'governorates_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FieldReelsScreen(),
    GovernoratesScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
      'label': 'الرئيسية',
    },
    {
      'icon': Icons.play_circle_outline_rounded,
      'activeIcon': Icons.play_circle_fill_rounded,
      'label': 'الميدان',
    },
    {
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
      'label': 'المحافظات',
    },
    {
      'icon': Icons.bookmark_outline_rounded,
      'activeIcon': Icons.bookmark_rounded,
      'label': 'المفضلة',
    },
    {
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
      'label': 'حسابي',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? AppColors.darkCard : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    final navBgColor = isDark ? AppColors.darkCard : Colors.white;
    final activeColor = isDark ? const Color(0xFF2E7D5E) : const Color(0xFF1A1A1A);
    final inactiveColor = isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE8E6E0);
    final scaffoldBg = isDark ? AppColors.darkScaffold : const Color(0xFFF5F5F0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                final item = _navItems[index];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onTabSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Active indicator line
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 20 : 0,
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? activeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        Icon(
                          isSelected ? item['activeIcon'] : item['icon'],
                          color: isSelected ? activeColor : inactiveColor,
                          size: 23,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'],
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? activeColor : inactiveColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
