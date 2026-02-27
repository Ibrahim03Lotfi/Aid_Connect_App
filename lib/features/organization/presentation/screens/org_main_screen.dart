import 'package:flutter/material.dart';
import 'org_dashboard_screen.dart';
import 'org_cases_screen.dart';
import 'create_case_screen.dart';
import 'org_profile_screen.dart';

class OrgMainScreen extends StatefulWidget {
  const OrgMainScreen({super.key});

  @override
  State<OrgMainScreen> createState() => _OrgMainScreenState();
}

class _OrgMainScreenState extends State<OrgMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OrgDashboardScreen(),
    OrgCasesScreen(),
    CreateCaseScreen(),
    OrgProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': 'الرئيسية',
    },
    {
      'icon': Icons.folder_outlined,
      'activeIcon': Icons.folder,
      'label': 'الحالات',
    },
    {
      'icon': Icons.add_circle_outline,
      'activeIcon': Icons.add_circle,
      'label': 'إضافة',
    },
    {
      'icon': Icons.business_outlined,
      'activeIcon': Icons.business,
      'label': 'المنظمة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          ? Theme.of(context).primaryColor.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item['activeIcon'] : item['icon'],
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[500],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[500],
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
