import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../shared/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _headlineController;
  late AnimationController _cardsController;
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

  // WARM HOPEFUL COLOR SYSTEM
  static const Color skyTop = Color(0xFFE8F4FC);
  static const Color warmBottom = Color(0xFFF9FAFB);
  static const Color friendlyBlue = Color(0xFF2B7A9F);
  static const Color softTeal = Color(0xFF4DB6AC);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMedium = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color inputFill = Color(0xFFF7FAFC);
  static const Color cardFill = Colors.white;

  // ANIMATION TIMING - COHESIVE FAMILY
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration cardStaggerDelay = Duration(milliseconds: 100);
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

    _headlineController.forward();
    _cardsController.forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _cardsController.dispose();
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
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _isLoading = false);
      final role = _getRoleFromIndex(_currentIndex);
      _navigateBasedOnRole(role);
    }
  }

  String _getRoleFromIndex(int index) {
    switch (index) {
      case 0: return UserRoles.user;
      case 1: return UserRoles.organization;
      case 2: return UserRoles.volunteer;
      default: return UserRoles.user;
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [skyTop, warmBottom],
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
                        Container(
                          width: double.infinity,
                          height: constraints.maxHeight * 0.35,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft decorative blob
                              Positioned(
                                top: 20,
                                right: -30,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: friendlyBlue.withAlpha(20),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: softTeal.withAlpha(15),
                                  ),
                                ),
                              ),
                              // Headline content
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: FadeTransition(
                                  opacity: _headlineFade,
                                  child: SlideTransition(
                                    position: _headlineSlide,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'معًا نصنع',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w700,
                                            color: textDark,
                                            height: 1.25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Text(
                                          'أثرًا حقيقيًا',
                                          style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w700,
                                            color: friendlyBlue,
                                            height: 1.25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'انضم لمجتمع يؤمن بقوة العطاء',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: textMedium,
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
                                _buildRoleSelector(),

                                // Form Section
                                _buildFormSection(),

                                // Primary Button
                                _buildPrimaryButton(),

                                // Secondary Action
                                _buildSecondaryAction(),
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
    );
  }

  // FLOATING CHIPS ROLE SELECTOR
  Widget _buildRoleSelector() {
    return Row(
      children: List.generate(_roles.length, (index) {
        final isSelected = _currentIndex == index;
        return Expanded(
          child: AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return FadeTransition(
                opacity: _cardAnimations[index],
                child: GestureDetector(
                  onTap: () => _onRoleSelected(index),
                  child: AnimatedContainer(
                    duration: microDuration,
                    curve: microCurve,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == 2 ? 0 : 8,
                    ),
                    transform: Matrix4.identity()..scale(
                      isSelected ? 1.04 : (1.0 + (_cardAnimations[index].value - 1.0) * 0.1),
                    ),
                    child: Container(
                      height: 88,
                      decoration: BoxDecoration(
                        color: cardFill,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? friendlyBlue : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? friendlyBlue.withAlpha(30)
                                : textDark.withAlpha(8),
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
                                  ? friendlyBlue.withAlpha(20)
                                  : inputFill,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected 
                                  ? _roles[index]['activeIcon'] as IconData
                                  : _roles[index]['icon'] as IconData,
                              size: 24,
                              color: isSelected ? friendlyBlue : textMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _roles[index]['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? friendlyBlue : textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // FORM SECTION - SOFT MODERN INPUTS
  Widget _buildFormSection() {
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
              ),
            if (_currentIndex == 1)
              _buildSoftInputField(
                controller: _orgNameController,
                hint: 'اسم المنظمة',
                icon: Icons.business_outlined,
                validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال اسم المنظمة' : null,
              ),
            if (_currentIndex == 2)
              _buildSoftInputField(
                controller: _volunteerNameController,
                hint: 'اسم المتطوع',
                icon: Icons.person_outline,
                validator: (v) => v?.isEmpty ?? true ? 'يرجى إدخال الاسم' : null,
              ),

            const SizedBox(height: 16),

            // Password Field
            _buildSoftPasswordField(),

            const SizedBox(height: 8),

            // Forgot Password
            if (_currentIndex != 2)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: friendlyBlue,
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
    TextInputType? keyboardType,
    TextDirection? textDirection,
    String? suffixText,
    int? maxLength,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? friendlyBlue.withAlpha(100) : textLight,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(20),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDark,
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
                      color: hasFocus ? friendlyBlue : textLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: textLight,
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
                            color: friendlyBlue.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            suffixText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: friendlyBlue,
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
  Widget _buildSoftPasswordField() {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: microDuration,
            curve: microCurve,
            height: 48,
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFocus ? friendlyBlue.withAlpha(100) : textLight,
                width: hasFocus ? 1.5 : 1,
              ),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: friendlyBlue.withAlpha(20),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
              decoration: InputDecoration(
                hintText: 'كلمة المرور',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textLight,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: hasFocus ? friendlyBlue : textLight,
                ),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: textLight,
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
  Widget _buildPrimaryButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) => setState(() => _isButtonPressed = false),
      onTapCancel: () => setState(() => _isButtonPressed = false),
      onTap: _isLoading ? null : _onLoginPressed,
      child: AnimatedContainer(
        duration: microDuration,
        curve: microCurve,
        transform: Matrix4.identity()..scale(_isButtonPressed ? 0.97 : 1.0),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [friendlyBlue, softTeal],
            ),
            boxShadow: [
              BoxShadow(
                color: friendlyBlue.withAlpha(_isButtonPressed ? 30 : 50),
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
                : const Text(
                    'نبدأ الرحلة',
                    style: TextStyle(
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
  Widget _buildSecondaryAction() {
    // Organization tab
    if (_currentIndex == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'منظمة جديدة؟',
            style: TextStyle(
              color: textMedium,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.organizationRequest),
            child: Text(
              'تقديم طلب',
              style: TextStyle(
                color: friendlyBlue,
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
          style: TextStyle(
            color: textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
          child: Text(
            'سجّل الآن',
            style: TextStyle(
              color: friendlyBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
