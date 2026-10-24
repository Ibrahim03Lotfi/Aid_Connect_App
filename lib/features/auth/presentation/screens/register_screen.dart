import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../services/locator.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AuthBloc>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isButtonPressed = false;

  late AnimationController _headlineController;
  late AnimationController _formController;
  late Animation<double> _headlineFade;
  late Animation<Offset> _headlineSlide;
  late Animation<double> _formFade;

  // Base Light Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color sectionTint = Color(0xFFF3F8FC);
  static const Color friendlyBlue = Color(0xFF1E7ABF);
  static const Color softTeal = Color(0xFF3BB3A9);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF7FAFC);

  // Animation Timing
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration microDuration = Duration(milliseconds: 250);
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

    // Form entrance animation
    _formController = AnimationController(
      vsync: this,
      duration: entranceDuration,
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.2, 1.0, curve: entranceCurve),
      ),
    );

    _headlineController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _formController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(RegisterEvent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkScaffold : backgroundColor;
    final Color activePrimary = isDark ? AppColors.primaryLight : friendlyBlue;
    final Color cardBg = isDark ? AppColors.darkCard : surfaceColor;
    final Color cardBorder = isDark ? AppColors.darkBorder : borderLight;
    final Color titleColor = isDark ? AppColors.primaryLight : friendlyBlue;
    final Color subtitleColor = isDark ? AppColors.darkTextSecondary : textSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthFormState && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: activePrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HERO SECTION - Compact
                    FadeTransition(
                      opacity: _headlineFade,
                      child: SlideTransition(
                        position: _headlineSlide,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : sectionTint,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : activePrimary.withAlpha(30),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: activePrimary.withAlpha(isDark ? 25 : 15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_outlined,
                                size: 28,
                                color: activePrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'انضم إلى مجتمع الأثر',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'سجّل الآن وكن جزءًا من التغيير الإيجابي',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // FORM SECTION - Compact Card
                    FadeTransition(
                      opacity: _formFade,
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cardBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withAlpha(40)
                                    : activePrimary.withAlpha(8),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name Field
                              _buildSoftInputField(
                                controller: _nameController,
                                label: 'الاسم الكامل',
                                icon: Icons.person_outline,
                                isDark: isDark,
                                activePrimary: activePrimary,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return ValidationMessages.requiredField;
                                  }
                                  if (value!.length < 3) {
                                    return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Email Field
                              _buildSoftInputField(
                                controller: _emailController,
                                label: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                isDark: isDark,
                                activePrimary: activePrimary,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return ValidationMessages.requiredField;
                                  }
                                  if (!value!.contains('@')) {
                                    return ValidationMessages.invalidEmail;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Phone Field
                              _buildSoftInputField(
                                controller: _phoneController,
                                label: 'رقم الهاتف',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                suffixText: '09',
                                maxLength: 8,
                                isDark: isDark,
                                activePrimary: activePrimary,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return ValidationMessages.requiredField;
                                  }
                                  if (value!.length != 8) {
                                    return 'يجب إدخال 8 أرقام بعد 09';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password Field
                              _buildSoftPasswordField(
                                controller: _passwordController,
                                label: 'كلمة المرور',
                                isVisible: _isPasswordVisible,
                                isDark: isDark,
                                activePrimary: activePrimary,
                                onToggleVisibility: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return ValidationMessages.requiredField;
                                  }
                                  if (value!.length < 6) {
                                    return ValidationMessages.passwordTooShort;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Confirm Password Field
                              _buildSoftPasswordField(
                                controller: _confirmPasswordController,
                                label: 'تأكيد كلمة المرور',
                                isVisible: _isConfirmPasswordVisible,
                                isDark: isDark,
                                activePrimary: activePrimary,
                                onToggleVisibility: () {
                                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return ValidationMessages.requiredField;
                                  }
                                  if (value != _passwordController.text) {
                                    return ValidationMessages.passwordsNotMatch;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthFormState && state.isLoading;
                        return GestureDetector(
                          onTapDown: (_) => setState(() => _isButtonPressed = true),
                          onTapUp: (_) => setState(() => _isButtonPressed = false),
                          onTapCancel: () => setState(() => _isButtonPressed = false),
                          onTap: isLoading ? null : _onRegisterPressed,
                          child: AnimatedScale(
                            scale: _isButtonPressed ? 0.97 : 1.0,
                            duration: microDuration,
                            curve: microCurve,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
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
                                    blurRadius: _isButtonPressed ? 8 : 14,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'إنشاء حساب',
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Secondary Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
                          style: GoogleFonts.cairo(
                            color: subtitleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: activePrimary.withAlpha(isDark ? 25 : 10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              style: GoogleFonts.cairo(
                                color: activePrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SOFT MODERN INPUT FIELD
  Widget _buildSoftInputField({
    required TextEditingController controller,
    required String label,
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
    final Color borderNormal = isDark ? AppColors.darkBorder : borderLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textPrimary;
    final Color hintColor = isDark ? AppColors.darkTextHint : textSecondary.withAlpha(180);

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
                      label,
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
  Widget _buildSoftPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required bool isDark,
    required Color activePrimary,
  }) {
    final Color fieldFill = isDark ? AppColors.darkSurface : inputFill;
    final Color borderNormal = isDark ? AppColors.darkBorder : borderLight;
    final Color textColor = isDark ? AppColors.darkTextPrimary : textPrimary;
    final Color hintColor = isDark ? AppColors.darkTextHint : textSecondary.withAlpha(180);

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
              obscureText: !isVisible,
              textDirection: TextDirection.ltr,
              validator: validator,
              textAlign: TextAlign.left,
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
                      Icons.lock_outline,
                      size: 18,
                      color: hasFocus ? activePrimary : hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                    ),
                  ],
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: GestureDetector(
                  onTap: onToggleVisibility,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isVisible ? activePrimary.withAlpha(20) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                      color: isVisible ? activePrimary : hintColor,
                    ),
                  ),
                ),
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
}
