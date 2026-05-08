import 'package:flutter/material.dart';
import 'volunteer_dashboard_screen.dart';
import 'volunteer_available_cases_screen.dart';
import 'volunteer_my_cases_screen.dart';
import 'volunteer_profile_screen.dart';

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

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({super.key});

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VolunteerDashboardScreen(),
    VolunteerAvailableCasesScreen(),
    VolunteerMyCasesScreen(),
    VolunteerProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
      'label': 'الرئيسية',
    },
    {
      'icon': Icons.search_outlined,
      'activeIcon': Icons.search_rounded,
      'label': 'البحث',
    },
    {
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment_rounded,
      'label': 'حالاتي',
    },
    {
      'icon': Icons.person_outlined,
      'activeIcon': Icons.person_rounded,
      'label': 'الملف',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundOffWhite,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: friendlyBlue.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                final item = _navItems[index];
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? friendlyBlue.withAlpha(15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: friendlyBlue.withAlpha(50), width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item['activeIcon'] : item['icon'],
                          color: isSelected
                              ? friendlyBlue
                              : textMedium,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? friendlyBlue
                                : textMedium,
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
