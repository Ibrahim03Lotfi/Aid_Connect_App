import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
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
import '../../features/volunteer/presentation/screens/nfc_aid_scanner_screen.dart';
import '../../features/volunteer/presentation/screens/field_assessment_screen.dart';
import '../../features/volunteer/presentation/screens/volunteer_passport_screen.dart';
import '../../features/volunteer/presentation/screens/emergency_missions_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/user/presentation/screens/request_aid_wizard_screen.dart';
import '../../features/user/presentation/screens/case_tracking_screen.dart';
import '../../features/user/presentation/screens/join_volunteer_screen.dart';
import '../../features/user/presentation/screens/field_reels_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String organizationRequest = '/organization-request';

  // User Routes
  static const String home = '/home';
  static const String reels = '/reels';
  static const String governorates = '/governorates';
  static const String caseDetails = '/case-details';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String requestAidWizard = '/request-aid-wizard';
  static const String caseTracking = '/case-tracking';
  static const String joinVolunteer = '/join-volunteer';

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
  static const String volunteerScanner = '/volunteer-scanner';
  static const String volunteerAssessment = '/volunteer-assessment';
  static const String volunteerPassport = '/volunteer-passport';
  static const String emergencyMissions = '/emergency-missions';

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

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case organizationRequest:
        return MaterialPageRoute(
          builder: (_) => const OrganizationRequestScreen(),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const UserMainScreen());

      case reels:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FieldReelsScreen(
            initialIndex: args?['initialIndex'] ?? 0,
            initialCases: args?['initialCases'],
            isStandalone: true,
          ),
        );

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

      case requestAidWizard:
        return MaterialPageRoute(builder: (_) => const RequestAidWizardScreen());

      case caseTracking:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CaseTrackingScreen(initialCode: args?['code']),
        );

      case joinVolunteer:
        return MaterialPageRoute(builder: (_) => const JoinVolunteerScreen());

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

      case volunteerScanner:
        return MaterialPageRoute(
          builder: (_) => const NfcAidScannerScreen(),
        );

      case volunteerAssessment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FieldAssessmentScreen(
            initialBeneficiaryId: args?['beneficiaryId'],
            initialBeneficiaryName: args?['beneficiaryName'],
            initialCaseId: args?['caseId'],
          ),
        );

      case volunteerPassport:
        return MaterialPageRoute(
          builder: (_) => const VolunteerPassportScreen(),
        );

      case emergencyMissions:
        return MaterialPageRoute(
          builder: (_) => const EmergencyMissionsScreen(),
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
