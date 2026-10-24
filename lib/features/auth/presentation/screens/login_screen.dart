import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../services/locator.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _headlineController;
  late AnimationController _cardsController;
  late AnimationController _circleController1;
  late AnimationController _circleController2;
  late Animation<double> _headlineFade;
  late Animation<Offset> _headlineSlide;
  late List<Animation<double>> _cardAnimations;

  int _currentIndex = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isButtonPressed = false;

  final _emailController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _volunteerNameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _roles = [
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'مستخدم'},
    {'icon': Icons.business_outlined, 'activeIcon': Icons.business, 'label': 'منظمة'},
    {'icon': Icons.volunteer_activism_outlined, 'activeIcon': Icons.volunteer_activism, 'label': 'متطوع'},
  ];

  // Base Light Colors
  static const Color skyTop = Color(0xFFE8F4FC);
  static const Color warmBottom = Color(0xFFF9FAFB);
  static const Color friendlyBlue = Color(0xFF2B7A9F);
  static const Color softTeal = Color(0xFF4DB6AC);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMedium = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color inputFill = Color(0xFFF7FAFC);
  static const Color cardFill = Colors.white;

  // Animation Timings
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration microDuration = Duration(milliseconds: 200);
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve microCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();

    // Headline entrance animation
    _headlineController = AnimationController(
      vsync: this,
      duration: entranceDuration,
    );

    _headlineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headlineController, curve: entranceCurve),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headlineController, curve: entranceCurve));

    // Cards staggered entrance
    _cardsController = AnimationController(
      vsync: this,
      duration: entranceDuration + Duration(milliseconds: _roles.length * 100),
    );

    _cardAnimations = List.generate(_roles.length, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: entranceCurve),
        ),
      );
    });

    // Circle floating animations
    _circleController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _circleController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _headlineController.forward();
    _cardsController.forward();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _cardsController.dispose();
    _circleController1.dispose();
    _circleController2.dispose();
    _emailController.dispose();
    _orgNameController.dispose();
    _volunteerNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _onLoginPressed() async {
    final formKey = _formKeys[_currentIndex];
    if (formKey.currentState?.validate() ?? false) {
      setState(() => _isButtonPressed = true);
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _isButtonPressed = false);
      setState(() => _isLoading = true);

      // Actually perform login to persist auth data
      final authRepository = locator<AuthRepository>();
      final email = _currentIndex == 0
          ? _emailController.text
          : (_currentIndex == 1
              ? _orgNameController.text
              : _volunteerNameController.text);

      final result = await authRepository.login(
        email: email,
        password: _passwordController.text,
        role: _getRoleFromIndex(_currentIndex),
      );

      setState(() => _isLoading = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_mapFailureToMessage(failure))),
          );
        },
        (user) {
          _navigateBasedOnRole(user.role);
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure.message.isNotEmpty) {
      if (failure.message.toLowerCase().contains('credential') || failure.message.contains('Invalid')) {
        return 'بيانات الدخول غير صحيحة، يرجى التأكد من البريد وكلمة المرور';
      }
      return failure.message;
    }
    switch (failure.runtimeType.toString()) {
      case 'ServerFailure':
        return 'حدث خطأ في الخادم';
      case 'NetworkFailure':
        return 'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الهاتف والكمبيوتر بنفس الشبكة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  String _getRoleFromIndex(int index) {
    switch (index) {
      case 0:
        return UserRoles.user;
      case 1:
        return UserRoles.organization;
      case 2:
        return UserRoles.volunteer;
      default:
        return UserRoles.user;
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case UserRoles.user:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case UserRoles.organization:
        Navigator.pushReplacementNamed(context, AppRoutes.orgMain);
        break;
      case UserRoles.volunteer:
        Navigator.pushReplacementNamed(context, AppRoutes.volunteerMain);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgStart = isDark ? const Color(0xFF0F172A) : skyTop;
    final Color bgEnd = isDark ? AppColors.darkScaffold : warmBottom;
    final Color activePrimary = isDark ? AppColors.primaryLight : friendlyBlue;
    final Color mainText = isDark ? AppColors.darkTextPrimary : textDark;
    final Color subText = isDark ? AppColors.darkTextSecondary : textMedium;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // HERO SECTION - HOPE VISUAL (35%)
                          SizedBox(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.35,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Soft decorative blob 1 - Animated
                                AnimatedBuilder(
                                  animation: _circleController1,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 20 + (_circleController1.value * 50),
                                      right: -30 + (_circleController1.value * 30),
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: activePrimary.withAlpha(isDark ? 25 : 20),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Soft decorative blob 2 - Animated
                                AnimatedBuilder(
                                  animation: _circleController2,
                                  builder: (context, child) {
                                    return Positioned(
                                      bottom: 20 + (_circleController2.value * 40),
                                      left: -20 + (_circleController2.value * 25),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (isDark ? const Color(0xFF38BDF8) : softTeal)
                                              .withAlpha(isDark ? 20 : 15),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Headline content
                                FadeTransition(
                                  opacity: _headlineFade,
                                  child: SlideTransition(
                                    position: _headlineSlide,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'معًا نصنع',
                                            style: GoogleFonts.cairo(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w700,
                                              color: mainText,
                                              height: 1.25,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'أثرًا ',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w800,
                                                  color: activePrimary,
                                                  height: 1.25,
                                                ),
                                              ),
                                              Text(
                                                'حقيقيًا',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w700,
                                                  color: mainText,
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'انضم لمجتمع يؤمن بقوة العطاء',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: subText,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CONTENT SECTION
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Role Selector - Floating Chips
                                  _buildRoleSelector(isDark: isDark, activePrimary: activePrimary),

                                  // Form Section
                                  _buildFormSection(isDark: isDark, activePrimary: activePrimary),

                                  // Primary Button
                                  _buildPrimaryButton(isDark: isDark, activePrimary: activePrimary),

                                  // Secondary Action
                                  _buildSecondaryAction(isDark: isDark, activePrimary: activePrimary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // FLOATING CHIPS ROLE SELECTOR
  Widget _buildRoleSelector({required bool isDark, required Color activePrimary}) {
    return Row(
      children: List.generate(_roles.length, (index) {
        final isSelected = _currentIndex == index;
        return Expanded(
          child: FadeTransition(
            opacity: _cardAnimations[index],
            child: GestureDetector(
              onTap: () => _onRoleSelected(index),
              child: AnimatedScale(
                scale: isSelected ? 1.04 : 1.0,
                duration: microDuration,
                curve: microCurve,
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == 2 ? 0 : 8,
                  ),
                  height: 88,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : cardFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? activePrimary
                        : (isDark ? AppColors.darkBorder : Colors.transparent),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? activePrimary.withAlpha(isDark ? 35 : 30)
                          : (isDark ? Colors.black.withAlpha(30) : textDark.withAlpha(8)),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(0, 4),
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: microDuration,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activePrimary.withAlpha(isDark ? 25 : 20)
                            : (isDark ? AppColors.darkSurface : inputFill),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected
                            ? _roles[index]['activeIcon'] as IconData
                            : _roles[index]['icon'] as IconData,
                        size: 24,
                        color: isSelected
                            ? activePrimary
                            : (isDark ? AppColors.darkTextSecondary : textMedium),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _roles[index]['label'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? activePrimary
                            : (isDark ? AppColors.darkTextPrimary : textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
  }

  // FORM SECTION - SOFT MODERN INPUTS
  Widget _buildFormSection({required bool isDark, required Color activePrimary}) {
    return AnimatedSwitcher(
      duration: microDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Form(
        key: _formKeys[_currentIndex],
        child: Column(
          key: ValueKey<int>(_currentIndex),
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Input Field
            if (_currentIndex == 0)
              _buildSoftInputField(
                controller: _emailController,
                hint: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال البريد الإلكتروني' : null,
                isDark: isDark,
                activePrimary: activePrimary,
              ),
            if (_currentIndex == 1)
              _buildSoftInputField(
                controller: _orgNameController,
                hint: 'اسم المنظمة',
                icon: Icons.business_outlined,
                validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال اسم المنظمة' : null,
                isDark: isDark,
                activePrimary: activePrimary,
              ),
            if (_currentIndex == 2) ...[
              _buildSoftInputField(
                controller: _volunteerNameController,
                hint: 'البريد أو اسم المتطوع',
                icon: Icons.person_outline,
                validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال البريد أو اسم المتطوع' : null,
                isDark: isDark,
                activePrimary: activePrimary,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _volunteerNameController.text = 'volunteer@athar.sy';
                    _passwordController.text = 'password';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم ملء بيانات المتطوع المعتمد: volunteer@athar.sy'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          'تعبئة حساب متطوع تجريبي سريع',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: activePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Password Field
            _buildSoftPasswordField(isDark: isDark, activePrimary: activePrimary),

            const SizedBox(height: 8),

            // Forgot Password (wired to AppRoutes.forgotPassword)
            if (_currentIndex != 2)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: activePrimary,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // SOFT MODERN INPUT FIELD
  Widget _buildSoftInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDark,
    required Color activePrimary,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? suffixText,
    int? maxLength,
  }) {
    final Color fieldFill = isDark ? AppColors.darkSurface : inputFill;
    final Color borderNormal = isDark ? AppColors.darkBorder : textLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textDark;
    final Color hintColor = isDark ? AppColors.darkTextHint : textLight;

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? activePrimary : borderNormal,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: activePrimary.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textDirection: textDirection,
              validator: validator,
              maxLength: maxLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              textAlign: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: null,
                labelText: null,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      icon,
                      size: 18,
                      color: hasFocus ? activePrimary : hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                    ),
                  ],
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: suffixText != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: activePrimary.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suffixText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: activePrimary,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          );
        },
      ),
    );
  }

  // SOFT MODERN PASSWORD FIELD
  Widget _buildSoftPasswordField({required bool isDark, required Color activePrimary}) {
    final Color fieldFill = isDark ? AppColors.darkSurface : inputFill;
    final Color borderNormal = isDark ? AppColors.darkBorder : textLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textDark;
    final Color hintColor = isDark ? AppColors.darkTextHint : textLight;

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? activePrimary : borderNormal,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: activePrimary.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال كلمة المرور' : null,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'كلمة المرور',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: hasFocus ? activePrimary : hintColor,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : textLight,
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  // ENERGY BUTTON - GRADIENT PRIMARY
  Widget _buildPrimaryButton({required bool isDark, required Color activePrimary}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) => setState(() => _isButtonPressed = false),
      onTapCancel: () => setState(() => _isButtonPressed = false),
      onTap: _isLoading ? null : _onLoginPressed,
      child: AnimatedScale(
        scale: _isButtonPressed ? 0.97 : 1.0,
        duration: microDuration,
        curve: microCurve,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                activePrimary,
                isDark ? const Color(0xFF0284C7) : softTeal,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: activePrimary.withAlpha(_isButtonPressed ? 30 : 50),
                blurRadius: _isButtonPressed ? 8 : 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'نبدأ الرحلة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // SECONDARY ACTION
  Widget _buildSecondaryAction({required bool isDark, required Color activePrimary}) {
    final Color subColor = isDark ? AppColors.darkTextSecondary : textMedium;

    // Organization tab
    if (_currentIndex == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'منظمة جديدة؟',
            style: GoogleFonts.cairo(
              color: subColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.organizationRequest),
            child: Text(
              'تقديم طلب',
              style: GoogleFonts.cairo(
                color: activePrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    // Volunteer tab - No secondary action
    if (_currentIndex == 2) {
      return const SizedBox.shrink();
    }

    // User tab
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: GoogleFonts.cairo(
            color: subColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
          child: Text(
            'سجّل الآن',
            style: GoogleFonts.cairo(
              color: activePrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
