import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/organization_request_screen.dart';
import '../../features/user/presentation/screens/user_main_screen.dart';
import '../../features/user/presentation/screens/governorates_screen.dart';
import '../../features/user/presentation/screens/case_details_screen.dart';
import '../../features/user/presentation/screens/profile_screen.dart';
import '../../features/user/presentation/screens/favorites_screen.dart';
import '../../features/user/presentation/screens/notifications_screen.dart';
import '../../features/organization/presentation/screens/org_dashboard_screen.dart';
import '../../features/organization/presentation/screens/create_case_screen.dart';
import '../../features/organization/presentation/screens/org_cases_screen.dart';
import '../../features/organization/presentation/screens/org_main_screen.dart';
import '../../features/organization/presentation/screens/org_profile_screen.dart';
import '../../features/volunteer/presentation/screens/volunteer_main_screen.dart';
import '../../features/volunteer/presentation/screens/volunteer_dashboard_screen.dart';
import '../../features/volunteer/presentation/screens/volunteer_create_my_case_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String organizationRequest = '/organization-request';

  // User Routes
  static const String home = '/home';
  static const String governorates = '/governorates';
  static const String caseDetails = '/case-details';
  static const String profile = '/profile';
  static const String favorites = '/favorites';

  // Organization Routes
  static const String orgMain = '/org-main';
  static const String orgDashboard = '/org-dashboard';
  static const String createCase = '/create-case';
  static const String orgCases = '/org-cases';
  static const String orgProfile = '/org-profile';

  // Volunteer Routes
  static const String volunteerMain = '/volunteer-main';
  static const String volunteerDashboard = '/volunteer-dashboard';
  static const String volunteerCases = '/volunteer-cases';
  static const String volunteerCreateMyCase = '/volunteer-create-my-case';

  // Notifications
  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case organizationRequest:
        return MaterialPageRoute(
          builder: (_) => const OrganizationRequestScreen(),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const UserMainScreen());

      case governorates:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GovernoratesScreen(categoryId: args?['categoryId']),
        );

      case caseDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CaseDetailsScreen(caseId: args?['caseId'] ?? 0),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case orgCases:
        return MaterialPageRoute(builder: (_) => const OrgCasesScreen());

      case orgMain:
        return MaterialPageRoute(builder: (_) => const OrgMainScreen());

      case orgDashboard:
        return MaterialPageRoute(builder: (_) => const OrgDashboardScreen());

      case createCase:
        return MaterialPageRoute(builder: (_) => const CreateCaseScreen());

      case orgProfile:
        return MaterialPageRoute(builder: (_) => const OrgProfileScreen());

      case volunteerMain:
        return MaterialPageRoute(builder: (_) => const VolunteerMainScreen());

      case volunteerDashboard:
        return MaterialPageRoute(
          builder: (_) => const VolunteerDashboardScreen(),
        );

      case volunteerCreateMyCase:
        return MaterialPageRoute(
          builder: (_) => const VolunteerCreateMyCaseScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
