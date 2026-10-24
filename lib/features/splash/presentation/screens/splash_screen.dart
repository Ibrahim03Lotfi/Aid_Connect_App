import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/widgets/athar_logo_widget.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

// Animation Timing - Fast & Fluid
const Duration entranceDuration = Duration(milliseconds: 350);
const Curve entranceCurve = Curves.easeOutCubic;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: entranceDuration,
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: entranceCurve),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: entranceCurve),
    );

    _contentController = AnimationController(
      duration: entranceDuration,
      vsync: this,
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: entranceCurve),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: entranceCurve));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });

    // Start fast concurrent auth check
    _startFastAuthRouting();
  }

  Future<void> _startFastAuthRouting() async {
    // 600ms minimal duration for smooth branding visibility
    final minDelayFuture = Future.delayed(const Duration(milliseconds: 600));
    final routeFuture = _determineInitialRoute();

    final results = await Future.wait([minDelayFuture, routeFuture]);
    final targetRoute = results[1] as String;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  Future<String> _determineInitialRoute() async {
    try {
      final localStorage = locator<LocalStorageService>();
      final token = await localStorage.getToken();
      if (token == null || token.isEmpty) {
        return AppRoutes.login;
      }

      final authRepo = locator<AuthRepository>();
      final authResult = await authRepo.checkAuthStatus().timeout(
        const Duration(milliseconds: 2500),
        onTimeout: () => const Right(null),
      );

      return authResult.fold(
        (_) {
          // If network check failed, gracefully fall back to cached role
          final cachedRole = localStorage.getRole();
          if (cachedRole == UserRoles.volunteer) return AppRoutes.volunteerMain;
          if (cachedRole == UserRoles.user) return AppRoutes.home;
          if (cachedRole == UserRoles.organization) return AppRoutes.orgMain;
          return AppRoutes.login;
        },
        (user) {
          final role = user?.role ?? localStorage.getRole();
          switch (role) {
            case UserRoles.volunteer:
              return AppRoutes.volunteerMain;
            case UserRoles.user:
              return AppRoutes.home;
            case UserRoles.organization:
              return AppRoutes.orgMain;
            default:
              return AppRoutes.login;
          }
        },
      );
    } catch (_) {
      try {
        final localStorage = locator<LocalStorageService>();
        final cachedRole = localStorage.getRole();
        if (cachedRole == UserRoles.volunteer) return AppRoutes.volunteerMain;
        if (cachedRole == UserRoles.user) return AppRoutes.home;
        if (cachedRole == UserRoles.organization) return AppRoutes.orgMain;
      } catch (_) {}
      return AppRoutes.login;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgStart = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F6FB);
    final Color bgEnd = isDark ? AppColors.darkScaffold : const Color(0xFFF8FAFC);
    final Color textTitle = isDark ? Colors.white : const Color(0xFF0F2C59);
    final Color textSubtitle = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgStart, bgEnd],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bespoke Custom Athar Brand Logo
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AtharLogoWidget(
                        size: 96,
                        showGlow: true,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Brand Name and Humanitarian Purpose
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            'أثـــر',
                            style: GoogleFonts.cairo(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: textTitle,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المنظومة الوطنية الموحدة للإغاثة والعمل الميداني',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Minimal fast loading indicator
                  FadeTransition(
                    opacity: _contentFade,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E7ABF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
